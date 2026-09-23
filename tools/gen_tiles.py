"""Generates the flooded-city overworld tileset as true native-size pixel
art, using the same explicit region-fill principle as tools/gen_sprites.py
(no AI image model - every pixel is a deliberate color choice, so hard
edges / a limited palette / real alpha are guaranteed). Original art,
themed to Deluge Chronicles' own setting (a flooded Bangkok) rather than
any existing game's tile graphics.

Design grid is fully addressable at native TILE_SIZE (N=TILE_SIZE, no
upscale factor) rather than the original chunky 20x20-units-at-2x-scale
approach, so there's room for finer ripple/crack/debris texture. TILE_SIZE
matches overworld.gd's CELL_SIZE (64, now that a camera/scroll system
means the on-screen tile size isn't constrained by needing an entire
district to fit on one screen).

Produces one atlas PNG (assets/tiles/flood_tileset.png), tiles laid out
left-to-right at TILE_SIZE each: shallow_water, deep_water, wet_pavement,
rubble. Godot's TileSet reads it with texture_region_size=(TILE_SIZE,
TILE_SIZE) and atlas coords (0,0)..(3,0) - see scripts/util/tile_loader.gd.

Run from anywhere: `python3 tools/gen_tiles.py`.
"""
from PIL import Image
import os

TILE_SIZE = 64  # matches overworld.gd's CELL_SIZE - do not change without updating that
N = TILE_SIZE   # design grid == native pixels, fully addressable
TILE_ORDER = ["shallow_water", "deep_water", "wet_pavement", "rubble"]

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
OUT_PATH = os.path.join(REPO_ROOT, "assets", "tiles", "flood_tileset.png")
os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)


def blank(color):
    return [[color] * N for _ in range(N)]


def dot(grid, r, c, color):
    if 0 <= r < N and 0 <= c < N:
        grid[r][c] = color


def fill(grid, r0, r1, c0, c1, color):
    for r in range(max(r0, 0), min(r1, N - 1) + 1):
        for c in range(max(c0, 0), min(c1, N - 1) + 1):
            grid[r][c] = color


def shallow_water():
    g = blank("#2f5c66")
    for r in (8, 9, 10, 11, 30, 31, 32, 33, 52, 53, 54, 55):
        for c in range(0, N, 8):
            dot(g, r, c, "#3f7686")
            dot(g, r, c + 1, "#3f7686")
    for (r, c) in [(5, 24), (20, 44), (38, 10), (48, 34), (14, 52), (44, 18), (58, 46)]:
        dot(g, r, c, "#5a94a1")
        dot(g, r, c + 1, "#5a94a1")
    for (r, c) in [(6, 26), (21, 46)]:
        dot(g, r, c, "#7cc0cb")
    return g


def deep_water():
    g = blank("#16323d")
    for r in (16, 17, 18, 19, 42, 43, 44, 45):
        for c in range(1, N, 11):
            dot(g, r, c, "#1f4552")
            dot(g, r, c + 1, "#1f4552")
    for (r, c) in [(9, 28), (28, 50), (48, 16), (54, 38)]:
        dot(g, r, c, "#0d2028")
        dot(g, r + 1, c, "#0d2028")
    for (r, c) in [(11, 30)]:
        dot(g, r, c, "#2c5c6e")
    return g


def wet_pavement():
    g = blank("#5b5f63")
    for i in range(20):
        dot(g, 12 + i, 10 + i, "#3a3d40")
    for i in range(16):
        dot(g, 48 - i, 38 + i, "#3a3d40")
    for i in range(10):
        dot(g, 32 + i, 48 - i // 2, "#3a3d40")
    for (r, c) in [(6, 48), (28, 20), (54, 6), (36, 54), (20, 36), (44, 26), (10, 56)]:
        fill(g, r, r + 1, c, c + 1, "#75797d")
    for (r, c) in [(7, 49), (29, 21)]:
        dot(g, r, c, "#8b8f92")
    return g


def rubble():
    g = blank("#332e2c")
    fill(g, 6, 22, 6, 28, "#5c534c")
    fill(g, 28, 44, 34, 54, "#4a423d")
    fill(g, 42, 58, 10, 26, "#5c534c")
    fill(g, 10, 20, 34, 48, "#4a423d")
    for (r, c) in [(12, 12), (34, 44), (48, 16), (18, 26), (24, 10), (50, 32), (40, 40)]:
        dot(g, r, c, "#221e1c")
        dot(g, r + 1, c, "#221e1c")
    # bent rebar flecks poking out of the debris
    for i in range(13):
        dot(g, 16 + i, 38 - i // 2, "#8a5a2a")
    for i in range(8):
        dot(g, 48 + i // 2, 48 + i, "#8a5a2a")
    return g


GENERATORS = {
    "shallow_water": shallow_water,
    "deep_water": deep_water,
    "wet_pavement": wet_pavement,
    "rubble": rubble,
}


def to_image(grid):
    img = Image.new("RGBA", (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    px = img.load()
    for r in range(N):
        for c in range(N):
            color = grid[r][c]
            rgb = tuple(int(color[i:i + 2], 16) for i in (1, 3, 5))
            px[c, r] = rgb + (255,)
    return img


def main():
    atlas = Image.new("RGBA", (TILE_SIZE * len(TILE_ORDER), TILE_SIZE), (0, 0, 0, 0))
    for i, name in enumerate(TILE_ORDER):
        tile_img = to_image(GENERATORS[name]())
        atlas.paste(tile_img, (i * TILE_SIZE, 0))
    atlas.save(OUT_PATH)
    print("Wrote %s (%dx%d, %d tiles at %dpx)" % (OUT_PATH, atlas.width, atlas.height, len(TILE_ORDER), TILE_SIZE))


if __name__ == "__main__":
    main()
