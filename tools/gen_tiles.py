"""Generates the flooded-city overworld tileset as true native-size pixel
art, using the same explicit region-fill principle as tools/gen_sprites.py
(no AI image model - every pixel is a deliberate color choice, so hard
edges / a limited palette / real alpha are guaranteed). Original art,
themed to Deluge Chronicles' own setting (a flooded Bangkok) rather than
any existing game's tile graphics.

Design grid is fully addressable at native TILE_SIZE (N=TILE_SIZE, no
upscale factor) rather than the original chunky 20x20-units-at-2x-scale
approach, so there's room for finer ripple/crack/debris texture without
changing TILE_SIZE itself - TILE_SIZE stays 40 to match overworld.gd's
CELL_SIZE (bumping that would overflow the viewport; needs a camera/
scroll system first, see GDD.md's roadmap).

Produces one atlas PNG (assets/tiles/flood_tileset.png), tiles laid out
left-to-right at TILE_SIZE each: shallow_water, deep_water, wet_pavement,
rubble. Godot's TileSet reads it with texture_region_size=(TILE_SIZE,
TILE_SIZE) and atlas coords (0,0)..(3,0) - see scripts/util/tile_loader.gd.

Run from anywhere: `python3 tools/gen_tiles.py`.
"""
from PIL import Image
import os

TILE_SIZE = 40  # matches overworld.gd's CELL_SIZE - do not change without updating that
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
    for r in (5, 6, 7, 19, 20, 21, 32, 33, 34):
        for c in range(0, N, 5):
            dot(g, r, c, "#3f7686")
            dot(g, r, c + 1, "#3f7686")
    for (r, c) in [(3, 16), (14, 28), (26, 6), (36, 22), (9, 34), (30, 12)]:
        dot(g, r, c, "#5a94a1")
        dot(g, r, c + 1, "#5a94a1")
    for (r, c) in [(4, 17), (15, 29)]:
        dot(g, r, c, "#7cc0cb")
    return g


def deep_water():
    g = blank("#16323d")
    for r in (10, 11, 12, 26, 27, 28):
        for c in range(1, N, 7):
            dot(g, r, c, "#1f4552")
            dot(g, r, c + 1, "#1f4552")
    for (r, c) in [(6, 18), (18, 32), (30, 10), (34, 24)]:
        dot(g, r, c, "#0d2028")
        dot(g, r + 1, c, "#0d2028")
    for (r, c) in [(7, 19)]:
        dot(g, r, c, "#2c5c6e")
    return g


def wet_pavement():
    g = blank("#5b5f63")
    for i in range(12):
        dot(g, 8 + i, 6 + i, "#3a3d40")
    for i in range(10):
        dot(g, 30 - i, 24 + i, "#3a3d40")
    for i in range(6):
        dot(g, 20 + i, 30 - i // 2, "#3a3d40")
    for (r, c) in [(4, 30), (18, 12), (34, 4), (22, 34), (12, 22), (28, 16)]:
        fill(g, r, r + 1, c, c + 1, "#75797d")
    for (r, c) in [(5, 31), (19, 13)]:
        dot(g, r, c, "#8b8f92")
    return g


def rubble():
    g = blank("#332e2c")
    fill(g, 4, 14, 4, 18, "#5c534c")
    fill(g, 18, 28, 22, 34, "#4a423d")
    fill(g, 26, 36, 6, 16, "#5c534c")
    fill(g, 6, 12, 22, 30, "#4a423d")
    for (r, c) in [(8, 8), (22, 28), (30, 10), (12, 16), (16, 6), (32, 20)]:
        dot(g, r, c, "#221e1c")
        dot(g, r + 1, c, "#221e1c")
    # bent rebar flecks poking out of the debris
    for i in range(8):
        dot(g, 10 + i, 24 - i // 2, "#8a5a2a")
    for i in range(5):
        dot(g, 30 + i // 2, 30 + i, "#8a5a2a")
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
