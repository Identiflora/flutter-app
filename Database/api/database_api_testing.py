#!/usr/bin/env python3
"""
Simple script to exercise the incorrect-identification endpoint locally.

Usage:
  python Database/api/database_api_testing.py --identification-id 1 --correct-species-id 2 --incorrect-species-id 3

Environment:
  API_URL: override base URL (default http://localhost:8000)
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any, Dict

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Test POST /incorrect-identifications")
    parser.add_argument("--identification-id", type=int, required=True, help="Existing identification_submission ID")
    parser.add_argument("--correct-species-id", type=int, required=True, help="Correct species_id")
    parser.add_argument("--incorrect-species-id", type=int, required=True, help="Incorrect/predicted species_id")
    parser.add_argument(
        "--api-url",
        default=os.getenv("API_URL", "http://localhost:8000"),
        help="Base URL for the API (default: http://localhost:8000 or $API_URL)",
    )
    return parser.parse_args()


def post_incorrect_identification(api_url: str, payload: Dict[str, Any]) -> None:
    url = api_url.rstrip("/") + "/incorrect-identifications"
    print(f"[info] POST {url} payload={payload}")
    try:
        resp = requests.post(url, json=payload, timeout=10)
    except Exception as exc:  # noqa: BLE001
        print(f"[error] Request failed: {exc}")
        sys.exit(1)

    print(f"[info] Status: {resp.status_code}")
    try:
        print("[info] Response JSON:")
        print(resp.json())
    except Exception:  # noqa: BLE001
        print("[warn] Non-JSON response body:")
        print(resp.text)

    if not resp.ok:
        sys.exit(1)


def main() -> None:
    args = parse_args()
    payload = {
        "identification_id": args.identification_id,
        "correct_species_id": args.correct_species_id,
        "incorrect_species_id": args.incorrect_species_id,
    }
    post_incorrect_identification(args.api_url, payload)


if __name__ == "__main__":
    main()
