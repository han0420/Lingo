#!/usr/bin/env python3
"""Generate Lingo application and menu-bar brand assets."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Sources/Lingo/Resources/Brand"
MASTER = OUT / "brand-master.png"
ICONSET = OUT / "AppIcon.iconset"
ICON_SIZES = [16, 32, 64, 128, 256, 512]
MENU_PIXEL_SIZE = 44


def transparent_outer_canvas(image: Image.Image) -> Image.Image:
    """Keep the icon tile while making the surrounding square canvas transparent."""
    inset = round(image.width * 0.10)
    radius = round(image.width * 0.20)
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (inset, inset, image.width - inset, image.height - inset),
        radius=radius,
        fill=255,
    )
    result = image.copy()
    result.putalpha(ImageChops.multiply(result.getchannel("A"), mask))
    return result


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


def write_iconset(master: Image.Image) -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    # Remove the old, non-standard name used before Retina 512px output was fixed.
    (ICONSET / "icon_1024x1024.png").unlink(missing_ok=True)
    for size in ICON_SIZES:
        icon = master.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(ICONSET / f"icon_{size}x{size}.png")
        if size <= 512:
            retina = master.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
            retina.save(ICONSET / f"icon_{size}x{size}@2x.png")

    subprocess.run(
        ["iconutil", "-c", "icns", str(ICONSET), "-o", str(OUT / "AppIcon.icns")],
        check=True,
    )


def centered_text(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    text: str,
    text_font: ImageFont.ImageFont,
    fill: str | int = "black",
) -> None:
    bounds = draw.textbbox((0, 0), text, font=text_font)
    x = box[0] + (box[2] - box[0] - (bounds[2] - bounds[0])) / 2 - bounds[0]
    y = box[1] + (box[3] - box[1] - (bounds[3] - bounds[1])) / 2 - bounds[1]
    draw.text((x, y), text, fill=fill, font=text_font)


def base_keyboard(draw: ImageDraw.ImageDraw) -> None:
    draw.rounded_rectangle((3, 9, 30, 34), radius=5, outline="black", width=3)
    for y in (15, 21):
        for x in (9, 15, 21):
            draw.rounded_rectangle((x, y, x + 3, y + 3), radius=1, fill="black")
    draw.rounded_rectangle((10, 28, 23, 31), radius=1, fill="black")


def language_icon(label: str, badge: str | None = None) -> Image.Image:
    image = Image.new("RGBA", (MENU_PIXEL_SIZE, MENU_PIXEL_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    base_keyboard(draw)
    draw.rounded_rectangle((24, 15, 42, 35), radius=5, outline="black", width=3)
    centered_text(draw, (24, 14, 42, 35), label, font(14))
    if badge == "dot":
        draw.ellipse((35, 34, 43, 42), fill="black")
    elif badge == "pause":
        draw.ellipse((32, 31, 43, 42), fill="black")
        draw.rectangle((35, 34, 36, 39), fill=(0, 0, 0, 0))
        draw.rectangle((39, 34, 40, 39), fill=(0, 0, 0, 0))
    elif badge == "x":
        draw.ellipse((32, 31, 43, 42), fill="black")
        draw.line((35, 34, 40, 39), fill=(0, 0, 0, 0), width=2)
        draw.line((40, 34, 35, 39), fill=(0, 0, 0, 0), width=2)
    return image


def switching_icon() -> Image.Image:
    image = Image.new("RGBA", (MENU_PIXEL_SIZE, MENU_PIXEL_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.arc((6, 6, 38, 38), 205, 350, fill="black", width=4)
    draw.arc((6, 6, 38, 38), 25, 170, fill="black", width=4)
    draw.polygon([(35, 11), (42, 12), (38, 18)], fill="black")
    draw.polygon([(9, 33), (2, 32), (6, 26)], fill="black")
    centered_text(draw, (8, 11, 25, 31), "中", font(15))
    centered_text(draw, (23, 11, 39, 31), "A", font(15))
    return image


def main() -> None:
    master = Image.open(MASTER).convert("RGBA")
    app_icon = transparent_outer_canvas(master)
    app_icon = app_icon.resize((1024, 1024), Image.Resampling.LANCZOS)
    app_icon.save(OUT / "app-icon-source.png")
    write_iconset(app_icon)

    icons = {
        "menubar-chinese": language_icon("中"),
        "menubar-english": language_icon("A"),
        "menubar-switching": switching_icon(),
        "menubar-paused": language_icon("中", "pause"),
        "menubar-rule-active": language_icon("中", "dot"),
        "menubar-disabled": language_icon("中", "x"),
    }
    manifest: dict[str, str] = {"app-icon": "app-icon-source.png"}
    for name, image in icons.items():
        filename = f"{name}.png"
        image.save(OUT / filename)
        manifest[name] = filename
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Generated assets in {OUT}")


if __name__ == "__main__":
    main()
