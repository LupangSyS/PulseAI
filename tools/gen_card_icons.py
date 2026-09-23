"""Generates one small icon per card *effect* (damage/heal/block/
empower_next/dot/aoe_damage/execute - card_data.gd's full effect list),
covering all 417 cards in data/cards.json automatically since every card
already has one of these seven effects - no per-card art needed.

Icons are plain white silhouettes with real alpha, same region-fill/no-
AI-model principle as tools/gen_sprites.py. They're meant to be tinted at
runtime via Godot's TextureRect.modulate, keyed by the card's *type*
(action/spell/power) - see combat.gd's TYPE_TINT - rather than baking
7 effects x 3 types = 21 separate images.

Run from anywhere: `python3 tools/gen_card_icons.py`.
"""
from PIL import Image
import os

N = 24
WHITE = "#ffffff"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
OUT_DIR = os.path.join(REPO_ROOT, "assets", "icons")
os.makedirs(OUT_DIR, exist_ok=True)


def blank():
    return [[None] * N for _ in range(N)]


def fill(grid, r0, r1, c0, c1, color=WHITE):
    for r in range(max(r0, 0), min(r1, N - 1) + 1):
        for c in range(max(c0, 0), min(c1, N - 1) + 1):
            grid[r][c] = color


def dot(grid, r, c, color=WHITE):
    if 0 <= r < N and 0 <= c < N:
        grid[r][c] = color


def to_image(grid):
    img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    px = img.load()
    for r in range(N):
        for c in range(N):
            color = grid[r][c]
            if not color:
                continue
            rgb = tuple(int(color[i:i + 2], 16) for i in (1, 3, 5))
            px[c, r] = rgb + (255,)
    return img


def damage():
    """A diagonal blade with a crossguard - the base "Attack" glyph."""
    g = blank()
    for i in range(14):
        fill(g, 3 + i, 3 + i, 17 - i, 18 - i)
    fill(g, 15, 16, 3, 8)
    fill(g, 16, 20, 5, 6)
    return g


def heal():
    """A plus/cross."""
    g = blank()
    fill(g, 4, 19, 10, 13)
    fill(g, 10, 13, 4, 19)
    return g


def block():
    """A shield: wide rounded top narrowing to a point."""
    g = blank()
    fill(g, 3, 3, 7, 16)
    fill(g, 4, 6, 5, 18)
    fill(g, 7, 12, 4, 19)
    fill(g, 13, 16, 6, 17)
    fill(g, 17, 18, 8, 15)
    fill(g, 19, 20, 10, 13)
    return g


def empower_next():
    """A rising double-chevron - "power building up"."""
    g = blank()
    for i in range(7):
        fill(g, 14 - i, 15 - i, 5 + i, 6 + i)
        fill(g, 14 - i, 15 - i, 18 - i, 19 - i)
    for i in range(7):
        fill(g, 21 - i, 22 - i, 5 + i, 6 + i)
        fill(g, 21 - i, 22 - i, 18 - i, 19 - i)
    return g


def dot_icon():
    """A dripping droplet - lingering/poison damage."""
    g = blank()
    fill(g, 3, 3, 11, 12)
    fill(g, 4, 5, 10, 13)
    fill(g, 6, 8, 9, 14)
    fill(g, 9, 12, 8, 15)
    fill(g, 13, 13, 9, 14)
    fill(g, 14, 14, 10, 13)
    # drip trail
    dot(g, 17, 11)
    dot(g, 18, 11)
    dot(g, 20, 12)
    return g


def aoe_damage():
    """An 8-point burst radiating from the center - hits everything."""
    g = blank()
    fill(g, 10, 13, 10, 13)
    # straight rays (up/down/left/right)
    fill(g, 0, 8, 11, 12)
    fill(g, 15, 23, 11, 12)
    fill(g, 11, 12, 0, 8)
    fill(g, 11, 12, 15, 23)
    # diagonal rays (stepped)
    for i in range(6):
        fill(g, 8 - i, 9 - i, 8 - i, 9 - i)
        fill(g, 8 - i, 9 - i, 14 + i, 15 + i)
        fill(g, 14 + i, 15 + i, 8 - i, 9 - i)
        fill(g, 14 + i, 15 + i, 14 + i, 15 + i)
    return g


def execute():
    """A crosshair / target - "finish it"."""
    g = blank()
    for r in range(N):
        for c in range(N):
            dx, dy = c - 11.5, r - 11.5
            dist = (dx * dx + dy * dy) ** 0.5
            if 9.0 <= dist <= 10.5:
                g[r][c] = WHITE
    fill(g, 1, 4, 11, 12)
    fill(g, 19, 22, 11, 12)
    fill(g, 11, 12, 1, 4)
    fill(g, 11, 12, 19, 22)
    fill(g, 10, 13, 10, 13)
    return g


GENERATORS = {
    "damage": damage,
    "heal": heal,
    "block": block,
    "empower_next": empower_next,
    "dot": dot_icon,
    "aoe_damage": aoe_damage,
    "execute": execute,
}


def main():
    cols = len(GENERATORS)
    sheet = Image.new("RGBA", (cols * (N * 4 + 8), N * 4 + 16), (18, 20, 26, 255))
    for i, (name, gen) in enumerate(GENERATORS.items()):
        img = to_image(gen())
        img.save(os.path.join(OUT_DIR, "effect_%s.png" % name))
        big = img.resize((N * 4, N * 4), Image.NEAREST)
        sheet.paste(big, (i * (N * 4 + 8) + 4, 8), big)
        print("wrote assets/icons/effect_%s.png" % name)
    sheet.save(os.path.join(SCRIPT_DIR, "_card_icon_sheet.png"))
    print("done")


if __name__ == "__main__":
    main()
