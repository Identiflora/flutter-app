#!/usr/bin/env python3
from __future__ import annotations

import os
from typing import Any, Dict
from urllib.parse import quote_plus

from fastapi import HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine, Row
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

DATABASE_PASSWORD_PATH = "Database/api/database_password.txt"
DATABASE_NAME = "identiflora_testing_db"

# Resolve password from file at import time; environment variable DB_PASSWORD still overrides in build_engine.
try:
    with open(DATABASE_PASSWORD_PATH) as file:
        db_password = file.read().strip()
except FileNotFoundError:
    db_password = ""


class IncorrectIdentificationRequest(BaseModel):
    """
    Request body for reporting an incorrect identification.
    """

    identification_id: int = Field(..., gt=0, description="FK to identification_submission")
    correct_species_id: int = Field(..., gt=0, description="Species that should have been returned")
    incorrect_species_id: int = Field(..., gt=0, description="Species the model predicted")

class UserRegistrationRequest(BaseModel):
    """
    Request body for reporting user registration. Ensures empty strings trigger invalid requests.
    """

    user_email: str = Field(..., min_length=1, description="Email from user input")
    username: str = Field(..., min_length=1, description="Username from user input")
    password_hash: str = Field(..., min_length=1, description="Password hash created by Flutter with user input")

def build_engine() -> Engine:
    """
    Create a SQLAlchemy engine using environment-driven configuration.

    Returns
    -------
    sqlalchemy.engine.Engine
        Engine configured for the target MySQL database.

    Raises
    ------
    HTTPException
        If engine creation fails.
    """
    try:
        user = quote_plus(os.getenv("DB_USER", "root"))
        password = quote_plus(os.getenv("DB_PASSWORD", db_password))
        host = os.getenv("DB_HOST", "localhost")
        port = os.getenv("DB_PORT", "3306")
        db_name = os.getenv("DB_NAME", DATABASE_NAME)
        # Using PyMySQL dialect for compatibility.
        url = f"mysql+pymysql://{user}:{password}@{host}:{port}/{db_name}"
        return create_engine(url, future=True, pool_pre_ping=True)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"Could not create database engine: {exc}") from exc


def ensure_row(conn, query: str, params: Dict[str, Any], missing_message: str, status: int = 404) -> Row:
    """
    Execute a query and ensure a single row exists.

    Parameters
    ----------
    conn : sqlalchemy.engine.Connection
        Active connection to run the query.
    query : str
        Query that should return exactly one row.
    params : dict
        Parameters for the query.
    missing_message : str
        Error message if no row is found.
    status : int, optional
        HTTP status code to use for the not-found case, by default 404.

    Returns
    -------
    sqlalchemy.engine.Row
        Row data accessible by column name.

    Raises
    ------
    HTTPException
        If the query returns no rows.
    """
    result = conn.execute(text(query), params)
    row = result.mappings().first()
    if row is None:
        raise HTTPException(status_code=status, detail=missing_message)
    return row


def record_incorrect_identification(payload: IncorrectIdentificationRequest, engine: Engine) -> Dict[str, Any]:
    """
    Persist an incorrect identification, validating referenced rows and constraints.

    Parameters
    ----------
    payload : IncorrectIdentificationRequest
        Request data containing identification, correct species, and incorrect species.

    Returns
    -------
    dict
        Confirmation payload mirroring the created row.

    Raises
    ------
    HTTPException
        If validation fails, referenced rows are missing, or database errors occur.
    """
    if payload.correct_species_id == payload.incorrect_species_id:
        raise HTTPException(status_code=400, detail="Correct and incorrect species IDs must differ.")

    try:
        with engine.begin() as conn:
            # Read-only validation of submission existence.
            ensure_row(
                conn,
                "CALL check_ident_id_exists(:id)",
                {"id": payload.identification_id},
                "Identification submission not found.",
            )
            # Read-only validation of species rows.
            ensure_row(
                conn,
                "CALL check_species_id_exists(:id)",
                {"id": payload.correct_species_id},
                "Correct species not found.",
            )
            ensure_row(
                conn,
                "CALL check_species_id_exists(:id)",
                {"id": payload.incorrect_species_id},
                "Incorrect species not found.",
            )

            # Read-only duplicate guard to avoid multiple incorrect records per submission.
            existing = conn.execute(
                text("CALL check_incorrect_sub_exists(:id)"),
                {"id": payload.identification_id},
            ).first()

            if existing is not None:
                raise HTTPException(
                    status_code=409,
                    detail="An incorrect identification has already been recorded for this submission.",
                )

            # Write: insert the incorrect identification record with timestamp.
            conn.execute(
                text("CALL add_incorrect_id(:ident_id_in, :correct_species_id_in, :inc_species_id_in)"),
                {
                    "ident_id_in": payload.identification_id,
                    "correct_species_id_in": payload.correct_species_id,
                    "inc_species_id_in": payload.incorrect_species_id,
                },
            )

            return {
                "identification_id": payload.identification_id,
                "correct_species_id": payload.correct_species_id,
                "incorrect_species_id": payload.incorrect_species_id,
                "message": "Incorrect identification recorded.",
            }

    except IntegrityError as exc:
        raise HTTPException(
            status_code=409,
            detail="An incorrect identification already exists for this submission.",
        ) from exc
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Database error while creating incorrect identification: {exc}",
        ) from exc
    
def record_user_registration(payload: UserRegistrationRequest, engine: Engine) -> Dict[str, Any]:
    """
    Persist a user registration, validating referenced rows and constraints.

    Parameters
    ----------
    payload : UserRegistrationRequest
        Request data containing username, email, and password hash.

    Returns
    -------
    dict
        Confirmation payload mirroring the created row.

    Raises
    ------
    HTTPException
        If validation fails, referenced rows are missing, or database errors occur.
    """
    try:
        with engine.begin() as conn:
            # Read-only duplicate guard to avoid duplicate emails for submissions.
            email_existing = conn.execute(
                text("CALL check_user_email_exists(:email)"),
                {"email": payload.user_email},
            ).first()

            if email_existing is not None:
                raise HTTPException(
                    status_code=409,
                    detail="This email has already been recorded.",
                )
            
            # Read-only duplicate guard to avoid duplicate usernames for submissions.
            username_existing = conn.execute(
                text("CALL check_username_exists(:username)"),
                {"username": payload.username},
            ).first()

            if username_existing is not None:
                raise HTTPException(
                    status_code=409,
                    detail="This username has already been recorded.",
                )

            # Write: insert the user account information with id and timestamp.
            conn.execute(
                text("CALL add_user(:user_email_in, :username_in, :user_password_in)"),
                {
                    "user_email_in": payload.user_email,
                    "username_in": payload.username,
                    "user_password_in": payload.password_hash
                },
            )

            return {
                "user_email_in": payload.user_email,
                "username_in": payload.username,
                "user_password_in": payload.password_hash,
                "message": "User registration recorded.",
            }

    except IntegrityError as exc:
        raise HTTPException(
            status_code=409,
            detail="Email or username already registered.",
        ) from exc
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Database error while creating user registration: {exc}",
        ) from exc