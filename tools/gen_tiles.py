"""Generates the flooded-city overworld tileset as true native-size pixel
art, using the same explicit region-fill principle as tools/gen_sprites.py
(no AI image model - every pixel is a deliberate color choice, so hard
edges / a limited palette / real alpha are guaranteed). Original art,
themed to Deluge Chronicles' own setting (a flooded 2035 Bangkok) rather
than any existing game's tile graphics.

Produces one atlas PNG (assets/tiles/flood_tileset.png), tiles laid out
left-to-right at TILE_SIZE each: shallow_water, deep_water, wet_pavement,
rubble. Godot's TileSet reads it with texture_region_size=(TILE_SIZE,
TILE_SIZE) and atlas coords (0,0)..(3,0) - see scripts/util/tile_loader.gd.

Run from anywhere: `python3 tools/gen_tiles.py`.
"""
from PIL import Image
import os

N = 20            # design grid (addressable units per tile)
SCALE = 2         # each unit -> SCALE physical pixels
TILE_SIZE = N * SCALE  # 40, matches overworld.gd's CELL_SIZE
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
    # gentle ripple bands
    for r in (3, 4, 10, 11, 16, 17):
        for c in range(0, N, 3):
            dot(g, r, c, "#3f7686")
    # a few brighter surface glints
    for (r, c) in [(2, 8), (7, 14), (13, 3), (18, 11)]:
        dot(g, r, c, "#5a94a1")
    return g


def deep_water():
    g = blank("#16323d")
    for r in (5, 6, 13, 14):
        for c in range(1, N, 4):
            dot(g, r, c, "#1f4552")
    for (r, c) in [(3, 9), (9, 16), (15, 5)]:
        dot(g, r, c, "#0d2028")
    return g


def wet_pavement():
    g = blank("#5b5f63")
    # a couple of crack lines
    for i in range(6):
        dot(g, 4 + i, 3 + i, "#3a3d40")
    for i in range(5):
        dot(g, 15 - i, 12 + i, "#3a3d40")
    # worn highlight chips
    for (r, c) in [(2, 15), (9, 6), (17, 2), (11, 17)]:
        dot(g, r, c, "#75797d")
    return g


def rubble():
    g = blank("#332e2c")
    fill(g, 2, 7, 2, 9, "#5c534c")
    fill(g, 9, 14, 11, 17, "#4a423d")
    fill(g, 13, 18, 3, 8, "#5c534c")
    for (r, c) in [(4, 4), (11, 14), (15, 5), (6, 8)]:
        dot(g, r, c, "#221e1c")
    # a bent rebar fleck poking out of the debris
    for i in range(4):
        dot(g, 5 + i, 12 - i // 2, "#8a5a2a")
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
            for dy in range(SCALE):
                for dx in range(SCALE):
                    px[c * SCALE + dx, r * SCALE + dy] = rgb + (255,)
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
