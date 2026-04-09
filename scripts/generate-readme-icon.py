#!/usr/bin/env python3
"""
README 상단용 스쿼클(연속 곡률) 아이콘 생성.

GitHub는 README의 <img>에서 style(border-radius 등)을 제거하므로,
마스터 PNG에 알파 마스크를 입혀 docs/readme-app-icon.png 로 보냅니다.

마스크는 SwiftUI RoundedRectangle(cornerSize:style: .continuous) / UIKit 연속 코너와
동일한 베지어 구성(1024 기준 cornerRadius 비율)을 따릅니다. macOS 26(Tahoe) 포함
시스템 아이콘 크롬과 같은 계열입니다.

앱 아이콘을 바꾼 뒤: python3 scripts/generate-readme-icon.py
의존: pip install pillow

가장자리는 마스크를 고해상도로 그린 뒤 LANCZOS 축소해 부드럽게 합니다.
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
# Apple 연속 코너 아이콘 마스크에 맞춘 값: cornerRadius = min(side) * (45/200) (리암 로젠펠드 분석)
CORNER_PERCENT_OF_SIDE = 45.0
OUT_SIZE = 512
BEZIER_STEPS = 48
# polygon 마스크는 픽셀 격자에 딱 붙어 계단 현상이 나므로, 고해상도로 채운 뒤 축소해 안티앨리어싱
MASK_SUPERSAMPLE = 4


def _quad_point(which: str, x: float, y: float, w: int, h: int, r: float) -> tuple[float, float]:
    if which == "tl":
        return (x * r, y * r)
    if which == "tr":
        return (w - x * r, y * r)
    if which == "br":
        return (w - x * r, h - y * r)
    if which == "bl":
        return (x * r, h - y * r)
    raise ValueError(which)


def _cubic_samples(
    p0: tuple[float, float],
    p1: tuple[float, float],
    p2: tuple[float, float],
    p3: tuple[float, float],
    steps: int,
) -> list[tuple[float, float]]:
    out: list[tuple[float, float]] = []
    for i in range(steps):
        t = i / max(steps - 1, 1)
        u = 1.0 - t
        x = u**3 * p0[0] + 3 * u**2 * t * p1[0] + 3 * u * t**2 * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u**2 * t * p1[1] + 3 * u * t**2 * p2[1] + t**3 * p3[1]
        out.append((x, y))
    return out


def _continuous_squircle_outline(w: int, h: int, r: float) -> list[tuple[float, float]]:
    """UIBezierPath(roundedRect:cornerRadius:) continuous-style outline (CCW for y-down)."""

    def q(name: str, x: float, y: float) -> tuple[float, float]:
        return _quad_point(name, x, y, w, h, r)

    pts: list[tuple[float, float]] = []

    def move(p: tuple[float, float]) -> None:
        pts.append(p)

    def line(p: tuple[float, float]) -> None:
        pts.append(p)

    def curve(c1: tuple[float, float], c2: tuple[float, float], end: tuple[float, float]) -> None:
        start = pts[-1]
        seg = _cubic_samples(start, c1, c2, end, BEZIER_STEPS)
        pts.extend(seg[1:])

    move(q("tl", 1.528665, 0.0))
    line(q("tr", 1.528665, 0.0))
    curve(
        q("tr", 1.08849296, 0.0),
        q("tr", 0.86840694, 0.0),
        q("tr", 0.63149379, 0.07491139),
    )
    curve(
        q("tr", 0.37282383, 0.16905956),
        q("tr", 0.16905956, 0.37282383),
        q("tr", 0.07491139, 0.63149379),
    )
    curve(
        q("tr", 0.0, 0.86840694),
        q("tr", 0.0, 1.08849296),
        q("tr", 0.0, 1.52866498),
    )
    line(q("br", 0.0, 1.528665))
    curve(
        q("br", 0.0, 1.08849296),
        q("br", 0.0, 0.86840694),
        q("br", 0.07491139, 0.63149379),
    )
    curve(
        q("br", 0.16905956, 0.37282383),
        q("br", 0.37282383, 0.16905956),
        q("br", 0.63149379, 0.07491139),
    )
    curve(
        q("br", 0.86840694, 0.0),
        q("br", 1.08849296, 0.0),
        q("br", 1.52866498, 0.0),
    )
    line(q("bl", 1.528665, 0.0))
    curve(
        q("bl", 1.08849296, 0.0),
        q("bl", 0.86840694, 0.0),
        q("bl", 0.63149379, 0.07491139),
    )
    curve(
        q("bl", 0.37282383, 0.16905956),
        q("bl", 0.16905956, 0.37282383),
        q("bl", 0.07491139, 0.63149379),
    )
    curve(
        q("bl", 0.0, 0.86840694),
        q("bl", 0.0, 1.08849296),
        q("bl", 0.0, 1.52866498),
    )
    line(q("tl", 0.0, 1.528665))
    curve(
        q("tl", 0.0, 1.08849296),
        q("tl", 0.0, 0.86840694),
        q("tl", 0.07491139, 0.63149379),
    )
    curve(
        q("tl", 0.16905956, 0.37282383),
        q("tl", 0.37282383, 0.16905956),
        q("tl", 0.63149379, 0.07491139),
    )
    curve(
        q("tl", 0.86840694, 0.0),
        q("tl", 1.08849296, 0.0),
        q("tl", 1.52866498, 0.0),
    )
    return pts


def _raster_mask(size: tuple[int, int], supersample: int = MASK_SUPERSAMPLE) -> Image.Image:
    w, h = size
    w_ss, h_ss = w * supersample, h * supersample
    side = min(w_ss, h_ss)
    r = side * (CORNER_PERCENT_OF_SIDE / 200.0)
    outline = _continuous_squircle_outline(w_ss, h_ss, r)
    poly = [(int(round(x)), int(round(y))) for x, y in outline]
    mask_hires = Image.new("L", (w_ss, h_ss), 0)
    ImageDraw.Draw(mask_hires).polygon(poly, fill=255)
    return mask_hires.resize((w, h), Image.Resampling.LANCZOS)


def main() -> None:
    im = Image.open(SRC).convert("RGBA")
    w, h = im.size
    mask = _raster_mask((w, h))
    alpha = im.split()[3]
    im.putalpha(ImageChops.multiply(alpha, mask))
    im = im.resize((OUT_SIZE, OUT_SIZE), Image.Resampling.LANCZOS)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT, "PNG")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
