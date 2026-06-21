from pathlib import Path
from PIL import Image
import argparse


def trim_png(path: Path, output_path: Path, padding: int) -> bool:
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        alpha = rgba.getchannel("A")
        bbox = alpha.getbbox()

        if bbox is None:
            print(f"Skipped fully transparent image: {path.name}")
            return False

        left, top, right, bottom = bbox

        if padding > 0:
            left = max(0, left - padding)
            top = max(0, top - padding)
            right = min(image.width, right + padding)
            bottom = min(image.height, bottom + padding)

        if (left, top, right, bottom) == (0, 0, image.width, image.height):
            print(f"No trim needed: {path.name}")
            return False

        cropped = image.crop((left, top, right, bottom))

        output_path.parent.mkdir(parents=True, exist_ok=True)
        cropped.save(output_path)

        print(f"Trimmed: {path.name} -> {cropped.width}x{cropped.height}")
        return True


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Trim transparent space around PNG files."
    )

    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory containing PNG files. Defaults to current directory."
    )

    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Process PNG files in subdirectories too."
    )

    parser.add_argument(
        "--in-place",
        action="store_true",
        help="Overwrite the original PNG files."
    )

    parser.add_argument(
        "--padding",
        type=int,
        default=0,
        help="Pixels of transparent padding to keep around the image."
    )

    args = parser.parse_args()

    directory = Path(args.directory)

    if not directory.is_dir():
        raise SystemExit(f"Not a directory: {directory}")

    if args.recursive:
        png_files = directory.rglob("*.png")
    else:
        png_files = directory.glob("*.png")

    count = 0

    for path in png_files:
        if args.in_place:
            output_path = path
        else:
            relative_path = path.relative_to(directory)
            output_path = directory / "trimmed" / relative_path

        if trim_png(path, output_path, args.padding):
            count += 1

    print(f"\nDone. Trimmed {count} file(s).")


if __name__ == "__main__":
    main()