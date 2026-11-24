"""Draws the Feezer mark from exact geometry and writes every logo asset.

The geometry was measured on the original artwork (logo_original.png, 1024 px)
and snapped: every slanted edge is at exactly 60 degrees, the four soft
corners share one radius, the four sharp corners another, and the right ends
of the two bars are aligned. Shapes are rasterized 8x and averaged down, so
edges are clean at every size.

Usage (from the repository root):
    python3 -m pip install pillow numpy
    python3 tool/brand/make_logo.py
    dart run flutter_launcher_icons
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]

# Colors of the original artwork.
LIGHT = (44, 142, 255)  # top bar
MID = (33, 131, 255)  # middle bar
DARK = (0, 61, 197)  # folded leg

# Geometry, in the 1024 px space of the original artwork.
K = math.tan(math.radians(30))  # horizontal run per unit of height, 60 deg slant
SOFT = 120.0  # radius of the soft (120 degree) corners
SHARP = 3.5  # radius of the sharp (60 degree) corners
TOP_Y1, TOP_Y2 = 108.2, 297.2  # top bar
MID_Y1, MID_Y2 = 347.5, 534.2  # middle bar
LEFT_C = 174.4  # top bar left edge:   x = -K*y + LEFT_C
RIGHT_C = 1088.8  # right ends of both bars: x = -K*y + RIGHT_C
LEG_LEFT_C = -148.9  # leg left edge:  x = K*y + LEG_LEFT_C
LEG_UP_C = 88.7  # leg upper right edge:  x = K*y + LEG_UP_C
LEG_LOW_C = 1031.2  # leg lower right edge: x = -K*y + LEG_LOW_C
# Outer curve from the middle bar into the leg (cubic, tangent to both edges).
BIG_A1, BIG_A2, BIG_H1, BIG_H2 = 425.6, 400.5, 0.426, 0.356
# Fold between the middle bar and the leg (cubic, from the bar's lower edge).
FOLD_X0, FOLD_END = 380.1, (237.8, 557.8)
FOLD_H1, FOLD_H2, FOLD_ANGLE = 0.390, 0.444, 158.8


def slant_x(c, y, sign):
    return sign * K * y + c


def unit(v):
    v = np.asarray(v, float)
    return v / np.linalg.norm(v)


def corner(prev, vertex, nxt, radius, step=0.5):
    """Points of a rounded corner at [vertex] between the edges to [prev] and [nxt]."""
    vertex = np.asarray(vertex, float)
    if radius <= 0:
        return [vertex]
    d1, d2 = unit(np.asarray(prev) - vertex), unit(np.asarray(nxt) - vertex)
    phi = math.acos(np.clip(d1 @ d2, -1, 1))
    t = radius / math.tan(phi / 2)
    center = vertex + unit(d1 + d2) * radius / math.sin(phi / 2)
    p1, p2 = vertex + d1 * t, vertex + d2 * t
    a1 = math.atan2(p1[1] - center[1], p1[0] - center[0])
    a2 = math.atan2(p2[1] - center[1], p2[0] - center[0])
    sweep = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(sweep) * radius / step))
    angles = (a1 + sweep * i / n for i in range(n + 1))
    return [center + radius * np.array([math.cos(a), math.sin(a)]) for a in angles]


def cubic(p0, p1, p2, p3, n=800):
    t = np.linspace(0, 1, n)[:, None]
    p0, p1, p2, p3 = map(np.asarray, (p0, p1, p2, p3))
    u = 1 - t
    return list(u**3 * p0 + 3 * u**2 * t * p1 + 3 * u * t**2 * p2 + t**3 * p3)


def rounded(vertices, radii):
    pts = []
    n = len(vertices)
    for i in range(n):
        pts += corner(vertices[i - 1], vertices[i], vertices[(i + 1) % n], radii[i])
    return pts


def top_bar():
    vertices = [
        (slant_x(LEFT_C, TOP_Y2, -1), TOP_Y2),
        (slant_x(LEFT_C, TOP_Y1, -1), TOP_Y1),
        (slant_x(RIGHT_C, TOP_Y1, -1), TOP_Y1),
        (slant_x(RIGHT_C, TOP_Y2, -1), TOP_Y2),
    ]
    return rounded(vertices, [SHARP, SOFT, SHARP, SOFT])


def stem():
    """Middle bar and leg, as one outline."""
    v = np.array([slant_x(LEG_LEFT_C, MID_Y1, 1), MID_Y1])  # corner replaced by the big curve
    d_top, d_leg = np.array([1.0, 0.0]), np.array([0.5, math.sqrt(3) / 2])
    big_start = v + d_top * BIG_A1
    big_end = v + d_leg * BIG_A2
    chevron_y = (LEG_LOW_C - LEG_UP_C) / (2 * K)
    tip_y = (LEG_LOW_C - LEG_LEFT_C) / (2 * K)
    vertices = [
        big_start,
        (slant_x(RIGHT_C, MID_Y1, -1), MID_Y1),
        (slant_x(RIGHT_C, MID_Y2, -1), MID_Y2),
        (slant_x(LEG_UP_C, MID_Y2, 1), MID_Y2),
        (slant_x(LEG_UP_C, chevron_y, 1), chevron_y),
        (slant_x(LEG_LEFT_C, tip_y, 1), tip_y),
        big_end,
    ]
    radii = [0, SHARP, SOFT, 0, SOFT, SHARP, 0]
    pts = [np.asarray(vertices[0], float)]
    for i in range(1, len(vertices) - 1):
        pts += corner(vertices[i - 1], vertices[i], vertices[i + 1], radii[i])
    handle_leg = v + d_leg * BIG_A2 * (1 - BIG_H2)
    handle_top = v + d_top * BIG_A1 * (1 - BIG_H1)
    pts += cubic(big_end, handle_leg, handle_top, big_start)
    return pts


def upper_side():
    """Region above the fold: the middle bar is the stem inside this region."""
    y_low = MID_Y2 + 40
    p0 = np.array([FOLD_X0, MID_Y2])
    p3 = np.array(FOLD_END)
    dist = np.linalg.norm(p3 - p0)
    direction = np.array([math.cos(math.radians(FOLD_ANGLE)), math.sin(math.radians(FOLD_ANGLE))])
    fold = cubic(p0, p0 + np.array([-1, 0]) * dist * FOLD_H1, p3 - direction * dist * FOLD_H2, p3)
    beyond = p3 + direction * 60
    return [
        (-300, 0), (1400, 0), (1400, y_low),
        (slant_x(LEG_UP_C, y_low, 1) + 1, y_low),
        (slant_x(LEG_UP_C, MID_Y2, 1) + 1, MID_Y2),
        *fold, beyond, (-300, beyond[1]),
    ]


def render(size, transform, background=None, ss=8):
    """RGBA image of the mark; transform = (scale, dx, dy) from artwork space.

    Each part is rasterized [ss] times larger, then averaged down: parts share
    their edges exactly, so there is no seam and edges are smooth.
    """
    scale, dx, dy = transform

    def mask(poly):
        img = Image.new("1", (size[0] * ss, size[1] * ss), 0)
        points = [((x * scale + dx) * ss, (y * scale + dy) * ss) for x, y in poly]
        ImageDraw.Draw(img).polygon(points, fill=1)
        return np.asarray(img, bool)

    def down(m):
        img = Image.fromarray(m.astype(np.uint8) * 255).reduce(ss)
        return np.asarray(img, float) / 255.0

    stem_mask, upper = mask(stem()), mask(upper_side())
    parts = (
        (down(mask(top_bar())), LIGHT),
        (down(stem_mask & upper), MID),
        (down(stem_mask & ~upper), DARK),
    )
    alpha = np.clip(sum(cov for cov, _ in parts), 0, 1)
    rgb = sum(cov[..., None] * np.array(color, float) for cov, color in parts)
    with np.errstate(invalid="ignore", divide="ignore"):
        rgb = np.where(alpha[..., None] > 0, rgb / alpha[..., None], 0)
    if background is not None:
        rgb = rgb * alpha[..., None] + np.array(background, float) * (1 - alpha[..., None])
        alpha = np.ones_like(alpha)
    out = np.dstack([rgb, alpha * 255]).round().clip(0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def outline_points():
    return np.array(top_bar() + stem(), float)


def bounds():
    p = outline_points()
    return p[:, 0].min(), p[:, 1].min(), p[:, 0].max(), p[:, 1].max()


def placement(size, box_fraction=None, radius_fraction=None):
    """Transform centering the mark's bounding box on a [size] canvas.

    The mark's larger side fills [box_fraction] of the canvas, or its farthest
    point sits at [radius_fraction] * size from the center (for circular masks).
    """
    x0, y0, x1, y1 = bounds()
    center = np.array([(x0 + x1) / 2, (y0 + y1) / 2])
    if radius_fraction is not None:
        reach = np.sqrt(((outline_points() - center) ** 2).sum(1)).max()
        scale = radius_fraction * size / reach
    else:
        scale = box_fraction * size / max(x1 - x0, y1 - y0)
    return scale, size / 2 - center[0] * scale, size / 2 - center[1] * scale


def save(img, path):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, optimize=True)
    print("wrote", path.relative_to(ROOT), img.size)


def main():
    white = (255, 255, 255)
    # In-app logo: transparent, the mark fills the square.
    save(render((512, 512), placement(512, box_fraction=1.0)), "assets/images/logo.png")
    # App icon (iOS, legacy Android): white, margins for rounded masks.
    icon = placement(1024, box_fraction=0.64)
    save(render((1024, 1024), icon, background=white), "tool/brand/launcher/icon.png")
    # Android adaptive foreground: inside the 66/108 dp safe circle.
    adaptive = placement(1024, radius_fraction=0.29)
    save(render((1024, 1024), adaptive), "tool/brand/launcher/icon_foreground.png")
    # Android 13+ themed icon: same layout, one color.
    alpha = np.asarray(render((1024, 1024), adaptive))[..., 3]
    white_mark = np.dstack([np.full_like(alpha, 255)] * 3 + [alpha])
    save(Image.fromarray(white_mark, "RGBA"), "tool/brand/launcher/icon_monochrome.png")
    # Android splash: before Android 12 (centered bitmap) and 12+ (icon in a circle).
    res = "android/app/src/main/res/drawable-nodpi"
    save(render((512, 512), placement(512, box_fraction=1.0)), f"{res}/splash_logo.png")
    # Android 12+ splash icon: 288 dp canvas, content within a 192 dp circle.
    save(render((1152, 1152), placement(1152, radius_fraction=0.3)), f"{res}/splash_icon.png")
    # Master copy.
    save(render((1024, 1024), placement(1024, box_fraction=0.9)), "tool/brand/logo.png")


if __name__ == "__main__":
    main()
