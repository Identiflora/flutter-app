import argparse
import os
import shutil
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Flatten plant image subfolders and strip author from filenames."
    )
    parser.add_argument("folder", type=Path, help="Path to the folder to process")
    args = parser.parse_args()

    folder = args.folder.resolve()
    if not folder.is_dir():
        print(f"Error: {folder} is not a directory")
        return

    moved = 0
    skipped = 0

    for subfolder in sorted(folder.iterdir()):
        if not subfolder.is_dir():
            continue

        jpgs = list(subfolder.glob("*.jpg"))
        if len(jpgs) != 1:
            print(f"Warning: skipping {subfolder.name} ({len(jpgs)} .jpg files found)")
            skipped += 1
            continue

        src = jpgs[0]
        parts = src.stem.split("_")
        if len(parts) < 2:
            print(f"Warning: skipping {src.name} (cannot parse genus_species)")
            skipped += 1
            continue

        dest_name = f"{parts[0]}_{parts[1]}.jpg"
        dest = folder / dest_name

        if dest.exists():
            print(f"Warning: skipping {src.name} (destination {dest_name} already exists)")
            skipped += 1
            continue

        shutil.move(str(src), str(dest))
        os.rmdir(subfolder)
        moved += 1

    print(f"Done: {moved} images moved, {skipped} skipped.")


if __name__ == "__main__":
    main()
