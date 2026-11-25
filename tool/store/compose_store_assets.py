"""Builds the Google Play images from the rendered screens.

    flutter test tool/store_screenshots_test.dart     # raw screens
    python3 tool/store/compose_store_assets.py         # this script

Writes, for each language, in fastlane/metadata/android/<locale>/images/:
- icon.png              512 x 512, 32-bit PNG
- featureGraphic.png    1024 x 500, 24-bit PNG (no alpha)
- phoneScreenshots/*.png 1080 x 1920, 24-bit PNG, caption on a flat background

Needs Pillow and NumPy (for the logo).
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool" / "brand"))
import make_logo  # noqa: E402

FONT = ROOT / "assets/fonts/Inter/Inter-VariableFont_opsz,wght.ttf"
RAW = ROOT / "build/store/raw"
OUT = ROOT / "fastlane/metadata/android"

BLUE = (30, 107, 255)
INK = (16, 24, 40)
BACKGROUND = (236, 241, 249)
OUTLINE = (213, 220, 232)
WHITE = (255, 255, 255)

LOCALES = {"fr": "fr-FR", "en": "en-US"}

CAPTIONS = {
    "fr": {
        "1_choose": "Choisissez l'opérateur et l'opération",
        "2_withdrawal": "Retirez plus, payez moins de frais",
        "3_transfer": "Envoyez plus pour le même montant",
        "4_compare": "Comparez avec la méthode habituelle",
        "5_operators": "Les frais officiels des opérateurs",
        "6_grid": "Chaque grille, palier par palier",
        "7_dark": "En thème clair ou sombre",
    },
    "en": {
        "1_choose": "Pick the operator and the operation",
        "2_withdrawal": "Withdraw more, pay less in fees",
        "3_transfer": "Send more for the same amount",
        "4_compare": "Compare with the usual way",
        "5_operators": "The operators' official fees",
        "6_grid": "Every grid, tier by tier",
        "7_dark": "In light or dark theme",
    },
}

TAGLINES = {
    "fr": "Payez moins de frais sur vos retraits et transferts mobile money",
    "en": "Pay less in fees on your mobile money withdrawals and transfers",
}


def font(size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    result = ImageFont.truetype(str(FONT), size)
    result.set_variation_by_name(weight)
    return result


def wrap(draw: ImageDraw.ImageDraw, text: str, face, width: int) -> list[str]:
    lines, line = [], ""
    for word in text.split():
        candidate = f"{line} {word}".strip()
        if draw.textlength(candidate, font=face) <= width or not line:
            line = candidate
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def rounded(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, image.width - 1, image.height - 1), radius=radius, fill=255
    )
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def screenshot(raw: Path, caption: str, target: Path) -> None:
    canvas = Image.new("RGB", (1080, 1920), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    # Caption: at most two lines, within the top 17% of the image.
    face = font(62)
    lines = wrap(draw, caption, face, 900)
    line_height = 76
    top = 96 if len(lines) == 1 else 70
    for i, line in enumerate(lines[:2]):
        width = draw.textlength(line, font=face)
        draw.text(((1080 - width) / 2, top + i * line_height), line, font=face, fill=INK)
    # The screen, scaled, with rounded corners and a thin outline.
    screen = Image.open(raw).convert("RGB")
    width = 860
    height = round(screen.height * width / screen.width)
    screen = rounded(screen.resize((width, height), Image.LANCZOS), 44)
    left, y = (1080 - width) // 2, 330
    outline = Image.new("RGBA", (width + 6, height + 6), (0, 0, 0, 0))
    ImageDraw.Draw(outline).rounded_rectangle(
        (0, 0, width + 5, height + 5), radius=47, fill=OUTLINE
    )
    canvas.paste(outline, (left - 3, y - 3), outline)
    canvas.paste(screen, (left, y), screen)
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target, optimize=True)


def logo(size: int, box_fraction: float, background=None) -> Image.Image:
    return make_logo.render(
        (size, size),
        make_logo.placement(size, box_fraction=box_fraction),
        background=background,
    )


def feature_graphic(tagline: str, target: Path) -> None:
    canvas = Image.new("RGB", (1024, 500), BLUE)
    draw = ImageDraw.Draw(canvas)
    tile = 210
    tile_left, tile_top = 104, (500 - tile) // 2
    draw.rounded_rectangle(
        (tile_left, tile_top, tile_left + tile, tile_top + tile), radius=50, fill=WHITE
    )
    mark = logo(tile, 0.62)
    canvas.paste(mark, (tile_left, tile_top), mark)
    text_left = tile_left + tile + 56
    title = font(92)
    body = font(34, "Medium")
    lines = wrap(draw, tagline, body, 1024 - text_left - 70)
    block = 104 + 12 + len(lines) * 46
    y = (500 - block) / 2
    draw.text((text_left, y - 8), "Feezer", font=title, fill=WHITE)
    for i, line in enumerate(lines):
        draw.text((text_left, y + 116 + i * 46), line, font=body, fill=(226, 236, 255))
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target, optimize=True)


def main() -> None:
    for short, locale in LOCALES.items():
        images = OUT / locale / "images"
        shots = sorted((RAW / short).glob("*.png"))
        if not shots:
            sys.exit(f"No raw screens in {RAW / short}: run the Flutter test first.")
        for index, raw in enumerate(shots, start=1):
            screenshot(raw, CAPTIONS[short][raw.stem], images / "phoneScreenshots" / f"{index}.png")
        feature_graphic(TAGLINES[short], images / "featureGraphic.png")
        icon = logo(512, 0.64, background=(255, 255, 255))
        icon.save(images / "icon.png", optimize=True)
        print(f"{locale}: {len(shots)} screenshots, feature graphic, icon")


if __name__ == "__main__":
    main()
