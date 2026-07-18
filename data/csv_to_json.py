#!/usr/bin/env python3
"""Convert every CSV in this directory to a separate JSON array safely."""

import csv
import json
import os
from pathlib import Path


SOURCE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SOURCE_DIR / "json"


def convert(source: Path, destination: Path) -> int:
    temporary = destination.with_suffix(destination.suffix + ".tmp")
    count = 0

    with source.open("r", encoding="utf-8-sig", newline="") as csv_file:
        reader = csv.DictReader(csv_file)
        if reader.fieldnames is None:
            raise ValueError(f"Başlık satırı bulunamadı: {source.name}")
        if len(reader.fieldnames) != len(set(reader.fieldnames)):
            raise ValueError(f"Tekrarlanan kolon adı bulundu: {source.name}")

        with temporary.open("w", encoding="utf-8", newline="\n") as json_file:
            json_file.write("[\n")
            for row in reader:
                if None in row:
                    raise ValueError(
                        f"Başlıktan fazla alan içeren satır bulundu: {source.name}"
                    )
                if count:
                    json_file.write(",\n")
                json.dump(row, json_file, ensure_ascii=False, separators=(",", ":"))
                count += 1
            json_file.write("\n]\n")

    os.replace(temporary, destination)
    return count


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    sources = sorted(SOURCE_DIR.glob("*.csv"))
    if not sources:
        raise SystemExit("CSV dosyası bulunamadı.")

    total = 0
    for source in sources:
        destination = OUTPUT_DIR / f"{source.stem}.json"
        rows = convert(source, destination)
        total += rows
        print(f"{source.name} -> json/{destination.name} ({rows} satır)")

    print(f"Tamamlandı: {len(sources)} dosya, {total} veri satırı")


if __name__ == "__main__":
    main()
