#!/usr/bin/env python3
from __future__ import annotations

import os

import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from database_api_helpers import build_engine, IncorrectIdentificationRequest, record_incorrect_identification, get_plant_species

HOST = "localhost"

app = FastAPI(
    title="Identiflora Database API",
    version="0.1.0",
    description="Minimal API for interacting with the Identiflora MySQL database.",
)

engine = build_engine()


@app.post("/incorrect-identifications")
def add_incorrect_identification(payload: IncorrectIdentificationRequest):
    """Route handler that records an incorrect identification via helper logic."""
    return record_incorrect_identification(payload, engine)

@app.get("/plant-species")
def get_plant_species_router(sci_name: str):

    return get_plant_species_url()

app.mount(
    "/Classes",
    StaticFiles(directory='/Users/jackson/Classes')
)


if __name__ == "__main__":
    uvicorn.run(
        "database_api:app",
        host=HOST,
        port=int(os.getenv("PORT", "8000")),
        reload=False,
    )
