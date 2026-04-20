#!/usr/bin/env python3
"""
find_common_names.py

Reads scientific plant names from scientific_names.txt, queries the PlantNet API
for each species' common name, and writes results to common_names.txt.

Usage:
    python find_common_names.py --api-key YOUR_PLANTNET_KEY
    # or
    PLANTNET_API_KEY=YOUR_KEY python find_common_names.py

Get a free API key at: https://my.plantnet.org/account/doc

Optional flags:
    --input   Path to input file  (default: scientific_names.txt next to this script)
    --output  Path to output file (default: common_names.txt next to this script)
    --lang    Language code for common names (default: en)
    --delay   Seconds between requests (default: 0.25)
"""

import argparse
import os
import sys
import time

import requests

BASE_URL = "https://my-api.plantnet.org/v2/species"
MAX_RETRIES = 3


def parse_args():
    parser = argparse.ArgumentParser(description="Fetch common names from PlantNet API.")
    parser.add_argument("--api-key", default=os.environ.get("PLANTNET_API_KEY", ""),
                        help="PlantNet API key (or set PLANTNET_API_KEY env var)")
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parser.add_argument("--input", default=os.path.join(script_dir, "scientific_names.txt"))
    parser.add_argument("--output", default=os.path.join(script_dir, "common_names.txt"))
    parser.add_argument("--lang", default="en")
    parser.add_argument("--delay", type=float, default=0.25,
                        help="Seconds between API requests (default: 0.25)")
    return parser.parse_args()


def parse_scientific_name(raw_line: str) -> str:
    """Extract 'Genus species' from 'Genus_species_Author' format."""
    tokens = raw_line.strip().split("_")
    if len(tokens) < 2:
        return tokens[0].strip()
    return f"{tokens[0]} {tokens[1]}"


def fetch_common_name(query: str, api_key: str, lang: str) -> str:
    """
    Query PlantNet /v2/species with a prefix and return the first common name
    for the exact species match, or "" if not found.
    Raises SystemExit on auth failure (401/403).
    Retries up to MAX_RETRIES times on rate-limit or server errors.
    """
    params = {"api-key": api_key, "lang": lang, "prefix": query}
    backoff = 1.0

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = requests.get(BASE_URL, params=params, timeout=10)
        except requests.RequestException as exc:
            if attempt == MAX_RETRIES:
                print(f"  [WARN] Network error for '{query}': {exc}", file=sys.stderr)
                return ""
            time.sleep(backoff)
            backoff *= 2
            continue

        if resp.status_code in (401, 403):
            sys.exit(
                f"ERROR: API key rejected (HTTP {resp.status_code}). "
                "Check your --api-key or PLANTNET_API_KEY."
            )

        if resp.status_code == 429 or resp.status_code >= 500:
            if attempt == MAX_RETRIES:
                print(
                    f"  [WARN] HTTP {resp.status_code} for '{query}' after {MAX_RETRIES} retries.",
                    file=sys.stderr,
                )
                return ""
            print(f"  [RETRY {attempt}/{MAX_RETRIES}] HTTP {resp.status_code} for '{query}', "
                  f"waiting {backoff:.1f}s…", file=sys.stderr)
            time.sleep(backoff)
            backoff *= 2
            continue

        if resp.status_code != 200:
            print(f"  [WARN] Unexpected HTTP {resp.status_code} for '{query}'.", file=sys.stderr)
            return ""

        # Successful response — find exact match
        try:
            data = resp.json()
        except ValueError:
            print(f"  [WARN] Invalid JSON response for '{query}'.", file=sys.stderr)
            return ""

        query_lower = query.lower()
        for entry in data:
            name_field = entry.get("scientificNameWithoutAuthor", "")
            if name_field.lower() == query_lower:
                common_names = entry.get("commonNames", [])
                return common_names[0] if common_names else ""

        # No exact match found
        return ""

    return ""


def main():
    args = parse_args()

    if not args.api_key:
        sys.exit(
            "ERROR: No API key provided. Use --api-key YOUR_KEY or set PLANTNET_API_KEY.\n"
            "Get a free key at: https://my.plantnet.org/account/doc"
        )

    # Read all input names
    with open(args.input, "r", encoding="utf-8") as f:
        raw_lines = [line.rstrip("\n") for line in f if line.strip()]

    total = len(raw_lines)

    # Load already-written output to support resuming
    already_done = 0
    if os.path.exists(args.output):
        with open(args.output, "r", encoding="utf-8") as f:
            existing = f.read().splitlines()
        already_done = len(existing)
        if already_done >= total:
            print(f"Output already complete ({already_done} lines). Nothing to do.")
            return
        if already_done > 0:
            print(f"Resuming from line {already_done + 1} / {total}.")

    with open(args.output, "a", encoding="utf-8") as out_f:
        for i, raw in enumerate(raw_lines):
            idx = i + 1  # 1-based line number

            if idx <= already_done:
                continue  # already resolved

            query = parse_scientific_name(raw)
            common = fetch_common_name(query, args.api_key, args.lang)

            out_f.write(common + "\n")
            out_f.flush()

            label = f'"{common}"' if common else "(none)"
            print(f"[{idx}/{total}] {query} → {label}")

            if idx < total:
                time.sleep(args.delay)

    print(f"\nDone. Results written to: {args.output}")


if __name__ == "__main__":
    main()
