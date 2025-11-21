#!/usr/bin/env python3
"""
Prepare a balanced GBIF/Pl@ntNet sample for model training.

This script:

1. Loads subsets of ``occurrence.txt`` and ``multimedia.txt`` using pandas.
2. Merges the tables on ``gbifID``.
3. Filters down to plausible image records.
4. Selects a balanced subset where each species appears exactly once in
   train, validation and test (3 images per species).
5. Downloads the selected images into a ``model_training_data`` folder
   with ``train/``, ``val/``, and ``test/`` subfolders.
"""

import os
import re
import argparse
from typing import Optional

import pandas as pd
import requests


def extension_from_format(format_str: str) -> str:
    """Return a file extension inferred from a MIME-type-like string.

    Parameters
    ----------
    format_str : str
        Value from the ``format`` column of ``multimedia.txt``. Typical
        examples include ``"image/jpeg"`` and ``"image/png"``.

    Returns
    -------
    str
        File extension beginning with a dot, such as ``".jpg"`` or
        ``".png"``. If the format string is missing or unrecognized,
        ``".jpg"`` is returned by default.
    """
    if not isinstance(format_str, str):
        return ".jpg"

    # Remove any parameters, keep the main MIME type.
    main = format_str.split(";", 1)[0].strip().lower()

    mapping = {
        "image/jpeg": ".jpg",
        "image/jpg": ".jpg",
        "image/pjpeg": ".jpg",
        "image/png": ".png",
        "image/x-png": ".png",
        "image/gif": ".gif",
        "image/tiff": ".tif",
        "image/x-tiff": ".tif",
    }

    return mapping.get(main, ".jpg")


def sanitize_species_name(name: str) -> str:
    """Sanitize a scientific name so it can be used as a folder name.

    Parameters
    ----------
    name : str
        Scientific name, for example ``"Quercus robur L."``.

    Returns
    -------
    str
        Lowercase, filesystem-friendly name with whitespace replaced by
        underscores and non-alphanumeric characters removed. If the
        input is empty or not a string, ``"unknown_species"`` is
        returned.
    """
    if not isinstance(name, str):
        return "unknown_species"

    cleaned = name.strip().lower()
    cleaned = re.sub(r"\s+", "_", cleaned)
    cleaned = re.sub(r"[^a-z0-9_]", "", cleaned)
    return cleaned or "unknown_species"


def load_occurrence_and_multimedia(dwca_dir: str,
                                   max_multimedia_rows: Optional[int] = None,
                                   max_occurrence_rows: Optional[int] = None,
                                  ) -> pd.DataFrame:
    """Load and merge ``occurrence.txt`` and ``multimedia.txt`` using pandas.

    The two GBIF Darwin Core Archive tables are merged on the ``gbifID``
    column so that each multimedia record is associated with its
    corresponding scientific name.

    Parameters
    ----------
    dwca_dir : str
        Path to the directory containing ``occurrence.txt`` and
        ``multimedia.txt``.
#must make these match: 
{
    max_multimedia_rows : int, optional
        Maximum number of rows to read from ``multimedia.txt`` using the
        ``nrows`` argument of :func:`pandas.read_csv`. If ``None``, all
        rows are read.
    max_occurrence_rows : int, optional
        Maximum number of rows to read from ``occurrence.txt`` using the
        ``nrows`` argument of :func:`pandas.read_csv`. If ``None``, all
        rows are read.
}

    Returns
    -------
    pandas.DataFrame
        DataFrame containing the merged subset with at least the
        columns ``gbifID``, ``identifier``, ``format``, ``type`` and
        ``scientificName``.

    Raises
    ------
    FileNotFoundError
        If either ``occurrence.txt`` or ``multimedia.txt`` cannot be
        found in ``dwca_dir``.
    RuntimeError
        If the merged DataFrame is empty (e.g., due to too strict
        ``nrows`` limits or mismatched ``gbifID`` values).
    """
    occ_path = os.path.join(dwca_dir, "occurrence.txt")
    mm_path = os.path.join(dwca_dir, "multimedia.txt")

    if not os.path.exists(occ_path):
        raise FileNotFoundError(f"Could not find occurrence file: {occ_path}")
    if not os.path.exists(mm_path):
        raise FileNotFoundError(f"Could not find multimedia file: {mm_path}")

    print("[info] Reading multimedia.txt with pandas...")
    mm_df = pd.read_csv(
        mm_path,
        sep="\t",
        dtype=str,
        low_memory=False,
        usecols=["gbifID", "type", "format", "identifier"],
        nrows=max_multimedia_rows,
    )

    print("[info] Reading occurrence.txt with pandas...")
    occ_df = pd.read_csv(
        occ_path,
        sep="\t",
        dtype=str,
        low_memory=False,
        usecols=["gbifID", "scientificName"],
        nrows=max_occurrence_rows,
    )

    print("[info] Merging multimedia and occurrence on gbifID...")
    merged = pd.merge(mm_df, occ_df, on="gbifID", how="inner")

    if merged.empty:
        raise RuntimeError(
            "Merged DataFrame is empty. Check that the 'gbifID' column "
            "exists in both files and that the nrows limits are not too strict."
        )

    print(f"[info] Merged dataframe has {len(merged)} rows.")
    return merged


def filter_image_records(df: pd.DataFrame) -> pd.DataFrame:
    """Filter merged records down to rows that look like valid images.

    This function keeps only rows that satisfy all of the following:

    * The ``identifier`` column starts with ``"http"``.
    * The ``format`` column starts with ``"image/"`` (e.g., ``"image/jpeg"``).
    * The ``type`` column is one of ``"stillimage"``, ``"image"`` or empty.

    Parameters
    ----------
    df : pandas.DataFrame
        Merged DataFrame containing, at minimum, the columns
        ``identifier``, ``format`` and ``type``.

    Returns
    -------
    pandas.DataFrame
        New DataFrame containing only rows considered valid image
        records. The index is reset to be contiguous from zero.

    Raises
    ------
    ValueError
        If required columns are missing, or if the resulting filtered
        DataFrame is empty.
    """
    required_cols = {"identifier", "format", "type"}
    missing = required_cols.difference(df.columns)
    if missing:
        raise ValueError(f"Input DataFrame is missing required columns: {missing}")

    df = df.copy()
    df = df.fillna("")

    mask_has_url = df["identifier"].str.startswith("http")
    mask_image_format = df["format"].str.lower().str.startswith("image/")
    type_lower = df["type"].str.lower()
    mask_type = (type_lower == "stillimage") | (type_lower == "image") | (type_lower == "")

    filtered = df[mask_has_url & mask_image_format & mask_type].reset_index(drop=True)

    if filtered.empty:
        raise ValueError(
            "No valid image records found after filtering. "
            "Check the format of the multimedia file or the filtering criteria."
        )

    print(f"[info] Filtered to {len(filtered)} valid image records.")
    return filtered


def select_balanced_subset(df: pd.DataFrame, max_images: int) -> pd.DataFrame:
    """Select a subset where all species have enough images for splitting.

    The goal of this function is to construct a subset of the data in
    which:

    * Every selected species has **at least three images**, so it can be
      split across train, validation and test (e.g., at least one image
      per split).
    * The **set of species** is the same for all future splits.
    * The total number of images in the subset does not exceed
      ``max_images``.

    Unlike earlier versions, this function does *not* enforce that each
    species contributes the same number of images, nor that each species
    has exactly three images. Some species may have more images than
    others, as long as they have at least three.

    Parameters
    ----------
    df : pandas.DataFrame
        Filtered image DataFrame containing at least the columns
        ``gbifID``, ``identifier``, ``format`` and ``scientificName``.
    max_images : int
        Maximum total number of images to include in the final subset.
        Because each species must contribute at least three images,
        the function can include at most ``max_images // 3`` species.

    Returns
    -------
    pandas.DataFrame
        DataFrame containing all selected rows. Each selected species
        appears at least three times, and the total number of rows is
        less than or equal to ``max_images``.

    Raises
    ------
    ValueError
        If ``max_images`` is less than 3 or if no species have at least
        three images.
    ValueError
        If input df does not contain a ``"scientificName"`` column.
    """
    if max_images < 3:
        raise ValueError(
            "max_images must be at least 3 so each selected species can "
            "contribute one image to train, val, and test."
        )

    if "scientificName" not in df.columns:
        raise ValueError("Input DataFrame must contain a 'scientificName' column.")

    df = df.copy()
    # Global shuffle for reproducibility and to avoid always picking
    # the same rows when you change nrows or max_images.
    df = df.sample(frac=1.0, random_state=42).reset_index(drop=True)

    # Count how many images each species has.
    species_counts = df["scientificName"].value_counts()
    # Only species with at least 3 images are eligible.
    # eligible_species is a list of the scientific names of plants with >=3 occurences with images
    eligible_species = species_counts[species_counts >= 3].index.tolist()

    if not eligible_species:
        raise ValueError(
            "No species have at least three images. Cannot create splits "
            "where every species appears in train/val/test."
        )

    selected_groups = []
    total_selected = 0

    # Iterate deterministically by sorted species name.
    for species in sorted(eligible_species):
        # All rows for this species in the shuffled df.
        group = df[df["scientificName"] == species]

        remaining_capacity = max_images - total_selected
        # If we can't fit at least 3 more images, we can't add a new species.
        if remaining_capacity < 3:
            break

        # We can take up to all images for this species, but we must
        # not exceed remaining_capacity.
        take_n = min(len(group), remaining_capacity)
        if take_n < 3:
            # This shouldn't happen given species_counts >= 3 and
            # remaining_capacity >= 3, but guard just in case.
            continue

        # Shuffle within the species to avoid always picking the
        # same first N rows.
        group_shuffled = group.sample(frac=1.0, random_state=42)
        selected_groups.append(group_shuffled.head(take_n))
        total_selected += take_n

        if total_selected >= max_images:
            break

    if not selected_groups:
        raise ValueError(
            "Could not select any species under the given max_images "
            "constraint. Try increasing max_images or nrows."
        )

    subset = pd.concat(selected_groups, ignore_index=True)
    num_species = subset["scientificName"].nunique()

    print(
        f"[info] Selected {num_species} species with a total of "
        f"{len(subset)} images (max_images={max_images})."
    )
    return subset



def assign_splits_per_species(df: pd.DataFrame) -> pd.DataFrame:
    """Assign train/validation/test splits for each species.

    This function ensures that:

    * Every species appears in all three splits (``"train"``, ``"val"``,
      and ``"test"``).
    * The set of species is identical across the three splits.
    * The number of images per species and per split may vary, as long
      as each species has at least three images in total.

    The function assumes that the input DataFrame contains at least
    three rows for every species. If any species has fewer than three
    rows, a :class:`ValueError` is raised.

    Parameters
    ----------
    df : pandas.DataFrame
        DataFrame containing at least the column ``"scientificName"``.
        Typically this is the subset returned by
        :func:`select_balanced_subset`.

    Returns
    -------
    pandas.DataFrame
        Copy of the input DataFrame with an additional column
        ``"split"`` whose values are one of ``"train"``, ``"val"`` or
        ``"test"``.

    Raises
    ------
    ValueError
        If any species has fewer than three rows.
    RuntimeError
        If any row fails to receive a split label (indicating a logic
        error in the implementation).
    """
    if "scientificName" not in df.columns:
        raise ValueError("Input DataFrame must contain a 'scientificName' column.")

    df = df.copy()
    df["split"] = ""

    # We will assign splits species by species.
    for species, group in df.groupby("scientificName"):
        idxs = list(group.index)
        n = len(idxs)

        if n < 3:
            raise ValueError(
                f"Species '{species}' has only {n} rows; at least 3 are required "
                "to allocate one image to each of train, val, and test."
            )

        # Shuffle indices for this species so we don't always pick the same
        # rows for each split.
        group_shuffled = group.sample(frac=1.0, random_state=42)
        shuffled_idxs = list(group_shuffled.index)

        # Start by guaranteeing one image per split.
        splits_for_group = ["train", "val", "test"]

        # Distribute remaining images (if any) in a round-robin fashion
        # across the three splits to keep things roughly balanced.
        remaining = n - 3
        extra_cycle = ["train", "val", "test"]
        for i in range(remaining):
            splits_for_group.append(extra_cycle[i % 3])

        # Now assign the computed split labels to the shuffled indices.
        for idx, split_label in zip(shuffled_idxs, splits_for_group):
            df.loc[idx, "split"] = split_label

    # Safety check: no row should be left unlabeled.
    if (df["split"] == "").any():
        raise RuntimeError(
            "One or more rows did not receive a split assignment. "
            "This indicates an internal logic error."
        )

    return df



def download_and_save_images(
    df: pd.DataFrame,
    output_dir: str,
    timeout: int = 30,
) -> None:
    """Download images and save them in a ``model_training_data`` folder structure.

    Given a DataFrame with assigned splits and species names, this
    function downloads each image and writes it under::

        <output_dir>/model_training_data/<split>/<species_folder>/<filename>

    where ``<split>`` is one of ``"train"``, ``"val"`` or ``"test"``
    and ``<species_folder>`` is derived from the scientific name.

    Parameters
    ----------
    df : pandas.DataFrame
        DataFrame that must contain the columns ``gbifID``,
        ``scientificName``, ``identifier``, ``format`` and ``split``.
    output_dir : str
        Base directory under which the ``model_training_data`` folder
        will be created.
    timeout : int, optional
        Timeout (in seconds) for HTTP requests when downloading images.
        The default is 30 seconds.

    Returns
    -------
    None

    Notes
    -----
    Network errors during download are reported as warnings and the
    corresponding images are skipped. As a result, it is possible for a
    species to be missing from one or more splits if all downloads for
    that species/split combination fail. The script prints the total
    number of successful downloads at the end.
    """
    required_cols = {"gbifID", "scientificName", "identifier", "format", "split"}
    missing = required_cols.difference(df.columns)
    if missing:
        raise ValueError(f"Input DataFrame is missing required columns: {missing}")

    base_root = os.path.join(output_dir, "model_training_data")
    splits = ["train", "val", "test"]

    for split in splits:
        split_dir = os.path.join(base_root, split)
        os.makedirs(split_dir, exist_ok=True)

    success_count = 0
    total_rows = len(df)

    for idx, row in df.iterrows():
        gbif_id = str(row["gbifID"])
        species = row["scientificName"]
        url = row["identifier"]
        fmt = row["format"]
        split = row["split"]

        species_folder = sanitize_species_name(species)
        split_dir = os.path.join(base_root, split, species_folder)
        os.makedirs(split_dir, exist_ok=True)

        ext = extension_from_format(fmt)
        filename = f"{gbif_id}_{split}_{idx}{ext}"
        out_path = os.path.join(split_dir, filename)

        if os.path.exists(out_path):
            print(f"[skip] File already exists, skipping: {out_path}")
            continue

        try:
            print(f"[download] ({idx + 1}/{total_rows}) [{split}] {url}")
            response = requests.get(url, timeout=timeout)
            response.raise_for_status()
        except Exception as exc:  # noqa: BLE001
            print(f"[warning] Failed to download {url}: {exc}")
            continue

        with open(out_path, "wb") as f:
            f.write(response.content)

        success_count += 1

    print(
        f"[done] Successfully downloaded {success_count} images "
        f"into {base_root}."
    )


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for the data preparation script.

    Returns
    -------
    argparse.Namespace
        Namespace containing the parsed command-line options.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Prepare a small, balanced GBIF/Pl@ntNet sample for model training. "
            "The script merges occurrence and multimedia tables, filters image "
            "records, selects a balanced subset with equal species across "
            "train/val/test splits, and downloads the corresponding images."
        )
    )
    parser.add_argument(
        "--dwca_dir",
        required=True,
        help=(
            "Path to the directory containing 'occurrence.txt' and "
            "'multimedia.txt'."
        ),
    )
    parser.add_argument(
        "--output_dir",
        default=".",
        help=(
            "Base directory where the 'model_training_data' folder will "
            "be created. Default is the current directory."
        ),
    )
    parser.add_argument(
        "--max_images",
        type=int,
        default=100,
        help=(
            "Maximum total number of images to include. Because each species "
            "contributes exactly three images (one per split), the script can "
            "include at most floor(max_images / 3) species."
        ),
    )
    parser.add_argument(
        "--max_multimedia_rows",
        type=int,
        default=50000,
        help=(
            "Maximum number of rows to read from 'multimedia.txt' using the "
            "nrows argument of pandas.read_csv. Use a smaller value for quick "
            "testing or a larger value to see more of the dataset."
        ),
    )
    parser.add_argument(
        "--max_occurrence_rows",
        type=int,
        default=50000,
        help=(
            "Maximum number of rows to read from 'occurrence.txt' using the "
            "nrows argument of pandas.read_csv."
        ),
    )
    return parser.parse_args()


def main() -> None:
    """Run the data preparation pipeline.

    This high-level function performs the following steps:

    1. Load and merge the occurrence and multimedia tables.
    2. Filter the merged table to keep only plausible image records.
    3. Select a balanced subset with one image per split for each species.
    4. Assign explicit train/validation/test split labels.
    5. Download all selected images into a ``model_training_data`` folder
       structure under the requested output directory.

    Returns
    -------
    None
    """
    args = parse_args()

    merged = load_occurrence_and_multimedia(
        dwca_dir=args.dwca_dir,
        max_multimedia_rows=args.max_multimedia_rows,
        max_occurrence_rows=args.max_occurrence_rows,
    )
    image_records = filter_image_records(merged)
    balanced_subset = select_balanced_subset(image_records, max_images=args.max_images)
    labeled_subset = assign_splits_per_species(balanced_subset)
    download_and_save_images(labeled_subset, output_dir=args.output_dir)


if __name__ == "__main__":
    main()
