#!/usr/bin/env python3
"""
README 상단용 라운딩 아이콘 생성.

GitHub는 README의 <img>에서 style(예: border-radius)을 제거하므로,
앱 아이콘 마스터 PNG에 알파 마스크를 입혀 docs/readme-app-icon.png 로보냅니다.

앱 아이콘을 바꾼 뒤: python3 scripts/generate-readme-icon.py
의존: pip install pillow (또는 brew 등으로 Pillow 설치)
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SRC = (
    ROOT
    / "KillEverybodyApp/KillEverybodyApp/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png"
)
OUT = ROOT / "docs/readme-app-icon.png"
# macOS 앱 아이콘과 맞추기 위한 CSS-style 근사 (정사각 기준 22.37%)
RATIO = 0.2237
OUT_SIZE = 512


def main() -> None:
    im = Image.open(SRC).convert("RGBA")
    w, h = im.size
    r = int(RATIO * min(w, h))
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w, h), radius=r, fill=255)
    alpha = im.split()[3]
    im.putalpha(ImageChops.multiply(alpha, mask))
    im = im.resize((OUT_SIZE, OUT_SIZE), Image.Resampling.LANCZOS)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT, "PNG")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
