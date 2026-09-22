"""Generates in-game character sprites (idle + bob frame each) as true
32x32-native pixel art PNGs, using region-fill generators (same principle
as the Pixel Studio artifact - https://claude.ai/artifact/KW9UfmerkrK3gckV5ypriH)
rather than any AI image model: every pixel is an explicit color choice,
so hard edges / limited palette / real alpha transparency are guaranteed,
not hoped for.

Run from anywhere: `python3 tools/gen_sprites.py`. Writes straight into
assets/sprites/{characters,monsters}/, plus a contact-sheet PNG (all
characters on one image, for reviewing new additions at a glance) next to
this script. Safe to re-run - it always regenerates every character in
CHARACTERS, overwriting existing files for those ids.

To add a new character: add an entry to CHARACTERS below using one of the
existing generators (humanoid / quadruped / blob / squat / boss_mass) or a
new one, add its id -> "characters"|"monsters" to CHARACTER_KIND, then
re-run this script.
"""
from PIL import Image
import os

N = 32
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
OUT_DIR = SCRIPT_DIR
os.makedirs(OUT_DIR, exist_ok=True)


def blank():
    return [[None] * N for _ in range(N)]


def fill(grid, r0, r1, c0, c1, color):
    for r in range(max(r0, 0), min(r1, N - 1) + 1):
        for c in range(max(c0, 0), min(c1, N - 1) + 1):
            grid[r][c] = color


def to_image(grid, scale=1):
    img = Image.new("RGBA", (N * scale, N * scale), (0, 0, 0, 0))
    px = img.load()
    for r in range(N):
        for c in range(N):
            color = grid[r][c]
            if not color:
                continue
            rgb = tuple(int(color[i:i + 2], 16) for i in (1, 3, 5))
            for dy in range(scale):
                for dx in range(scale):
                    px[c * scale + dx, r * scale + dy] = rgb + (255,)
    return img


def bob(grid):
    g = blank()
    for r in range(N - 1):
        for c in range(N):
            g[r][c] = grid[r + 1][c]
    return g


# ---------------------------------------------------------------------------
# Humanoid (player classes, upright monsters)
# ---------------------------------------------------------------------------
def humanoid(colors, hood=False, robed=False, weapon=None, weapon_glow=False, weapon_side="right"):
    g = blank()
    if hood:
        fill(g, 3, 6, 11, 20, colors["primary"])
        fill(g, 6, 10, 13, 18, colors["skin"])
    else:
        fill(g, 4, 10, 13, 18, colors["skin"])

    eye_color = colors.get("eye", "#2a1f18")
    fill(g, 8, 8, 14, 14, eye_color)
    fill(g, 8, 8, 17, 17, eye_color)

    fill(g, 11, 20, 11, 20, colors["primary"])
    fill(g, 11, 19, 8, 10, colors["secondary"])
    fill(g, 18, 19, 8, 10, colors["skin"])
    fill(g, 11, 19, 21, 23, colors["secondary"])
    fill(g, 18, 19, 21, 23, colors["skin"])
    fill(g, 20, 20, 11, 20, colors["trim"])

    if robed:
        fill(g, 21, 28, 10, 21, colors["primary"])
        fill(g, 29, 29, 10, 21, colors["shadow"])
        fill(g, 30, 30, 14, 17, colors["boot"])
    else:
        fill(g, 21, 29, 11, 15, colors["secondary"])
        fill(g, 21, 29, 16, 20, colors["secondary"])
        fill(g, 30, 30, 11, 15, colors["boot"])
        fill(g, 30, 30, 16, 20, colors["boot"])

    if weapon == "staff":
        wc = 24 if weapon_side == "right" else 7
        fill(g, 9, 23, wc, wc, colors["weapon"])
        if weapon_glow:
            fill(g, 6, 8, wc - 1, wc + 1, colors["glow"])
    elif weapon == "shield":
        wc0 = 6 if weapon_side == "left" else 22
        fill(g, 12, 23, wc0, wc0 + 3, colors["weapon"])
        fill(g, 12, 12, wc0, wc0 + 3, colors["trim"])
    return g


# ---------------------------------------------------------------------------
# Quadruped (rat / dog / crocodile-like), size = 'small' | 'medium' | 'large'
# ---------------------------------------------------------------------------
def quadruped(colors, size="small", ridged=False, eye_color="#1a1a1a"):
    g = blank()
    if size == "small":
        fill(g, 15, 20, 10, 21, colors["body"])
        fill(g, 13, 18, 20, 26, colors["body"])
        fill(g, 12, 13, 21, 22, colors["accent"])
        fill(g, 12, 13, 24, 25, colors["accent"])
        fill(g, 16, 17, 5, 10, colors["accent"])
        fill(g, 20, 23, 12, 14, colors["accent"])
        fill(g, 20, 23, 18, 20, colors["accent"])
        fill(g, 15, 15, 24, 24, eye_color)
    elif size == "medium":
        fill(g, 13, 21, 8, 23, colors["body"])
        fill(g, 11, 18, 22, 29, colors["body"])
        fill(g, 10, 12, 23, 24, colors["accent"])
        fill(g, 10, 12, 27, 28, colors["accent"])
        fill(g, 14, 16, 3, 8, colors["accent"])
        fill(g, 21, 26, 10, 13, colors["accent"])
        fill(g, 21, 26, 18, 21, colors["accent"])
        fill(g, 14, 14, 26, 27, eye_color)
        if ridged:
            for cc in range(10, 22, 3):
                fill(g, 10, 11, cc, cc + 1, colors["accent"])
    else:  # large (mini-boss scale)
        fill(g, 13, 22, 6, 26, colors["body"])
        fill(g, 10, 16, 24, 31, colors["body"])
        fill(g, 9, 9, 25, 30, colors["accent"])
        fill(g, 12, 15, 0, 6, colors["accent"])
        fill(g, 22, 27, 8, 12, colors["accent"])
        fill(g, 22, 27, 20, 24, colors["accent"])
        fill(g, 13, 13, 28, 30, eye_color)
        if ridged:
            for cc in range(8, 24, 3):
                fill(g, 11, 12, cc, cc + 1, colors["accent"])
    return g


# ---------------------------------------------------------------------------
# Blob / amorphous (leech, wisp)
# ---------------------------------------------------------------------------
def blob(colors, shape="oval", eye=False):
    g = blank()
    if shape == "oval":
        fill(g, 15, 20, 6, 25, colors["primary"])
        fill(g, 13, 22, 9, 22, colors["primary"])
        fill(g, 16, 19, 8, 23, colors["secondary"])
        fill(g, 17, 18, 5, 8, colors["shadow"])
    else:  # round wisp
        fill(g, 11, 20, 11, 20, colors["primary"])
        fill(g, 9, 21, 13, 18, colors["primary"])
        fill(g, 13, 18, 13, 18, colors["secondary"])
    if eye:
        fill(g, 16, 17, 20, 21, colors.get("eye", "#1a1a1a"))
    return g


# ---------------------------------------------------------------------------
# Squat (toad)
# ---------------------------------------------------------------------------
def squat(colors):
    g = blank()
    fill(g, 18, 27, 7, 24, colors["body"])
    fill(g, 21, 25, 9, 22, colors["belly"])
    fill(g, 13, 17, 10, 14, colors["body"])
    fill(g, 13, 17, 17, 21, colors["body"])
    fill(g, 14, 15, 11, 13, colors["eye"])
    fill(g, 14, 15, 18, 20, colors["eye"])
    fill(g, 27, 29, 9, 12, colors["body"])
    fill(g, 27, 29, 19, 22, colors["body"])
    return g


# ---------------------------------------------------------------------------
# Boss (Tide Mother): large central mass + tendrils
# ---------------------------------------------------------------------------
def boss_mass(colors):
    g = blank()
    fill(g, 8, 25, 9, 23, colors["primary"])
    fill(g, 6, 27, 12, 20, colors["primary"])
    fill(g, 11, 20, 12, 20, colors["secondary"])
    for tx, ty in [(3, 12), (28, 10), (2, 22), (29, 24)]:
        if tx < 16:
            fill(g, ty, ty + 1, tx, 11, colors["tendril"])
        else:
            fill(g, ty, ty + 1, 21, tx, colors["tendril"])
    fill(g, 13, 14, 13, 14, colors["glow"])
    fill(g, 13, 14, 18, 19, colors["glow"])
    fill(g, 27, 28, 14, 18, colors["shadow"])
    return g


# ---------------------------------------------------------------------------
# Character configs
# ---------------------------------------------------------------------------
CHARACTERS = {}

CHARACTERS["mage_f"] = humanoid(
    {"skin": "#d9a066", "primary": "#2f6d64", "secondary": "#255a53",
     "shadow": "#1d4740", "trim": "#c98a3a", "boot": "#16302c",
     "weapon": "#8a7a63", "glow": "#f0b94d", "eye": "#241810"},
    hood=True, robed=True, weapon="staff", weapon_glow=True,
)

# --- Remaining 14 F-rank starting classes (one per family) ---------------

CHARACTERS["hunter_f"] = humanoid(
    {"skin": "#c48958", "primary": "#5c5233", "secondary": "#7a6f47",
     "shadow": "#3a3420", "trim": "#a85c2e", "boot": "#2e2a1c", "eye": "#2a1c10"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["healer_f"] = humanoid(
    {"skin": "#e0ab7a", "primary": "#d8d2c4", "secondary": "#c46a5e",
     "shadow": "#8a8477", "trim": "#c46a5e", "boot": "#5c574c", "eye": "#3a2a1e"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["necromancer_f"] = humanoid(
    {"skin": "#a68f8a", "primary": "#3a2a45", "secondary": "#2e2038",
     "shadow": "#1c1424", "trim": "#6b4a8a", "boot": "#180f1e",
     "weapon": "#5c4a4a", "glow": "#7de08a", "eye": "#7de08a"},
    hood=True, robed=True, weapon="staff", weapon_glow=True,
)

CHARACTERS["assassin_f"] = humanoid(
    {"skin": "#b98a6a", "primary": "#2c2c34", "secondary": "#22222a",
     "shadow": "#161619", "trim": "#5a1e1e", "boot": "#0e0e11", "eye": "#c9a23a"},
    hood=True, robed=False, weapon=None,
)

CHARACTERS["tank_f"] = humanoid(
    {"skin": "#c99566", "primary": "#3a4a5c", "secondary": "#2e3a48",
     "shadow": "#1e2730", "trim": "#8a9aa8", "boot": "#1a2228",
     "weapon": "#7a828a", "eye": "#1c1410"},
    hood=False, robed=False, weapon="shield", weapon_side="left",
)

CHARACTERS["berserker_f"] = humanoid(
    {"skin": "#b97a52", "primary": "#6b2620", "secondary": "#4a1c18",
     "shadow": "#301210", "trim": "#c9622e", "boot": "#241010", "eye": "#e8c23a"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["summoner_f"] = humanoid(
    {"skin": "#d9a874", "primary": "#7a1e2e", "secondary": "#c9a23a",
     "shadow": "#4a1420", "trim": "#e8c65a", "boot": "#3a1418", "eye": "#241810"},
    hood=False, robed=True, weapon=None,
)

CHARACTERS["pyromancer_f"] = humanoid(
    {"skin": "#c9855a", "primary": "#8a2e1e", "secondary": "#c94e26",
     "shadow": "#4a1810", "trim": "#e8a23a", "boot": "#241008",
     "weapon": "#4a3a30", "glow": "#f0782c", "eye": "#f0b23a"},
    hood=True, robed=True, weapon="staff", weapon_glow=True, weapon_side="left",
)

CHARACTERS["ranger_f"] = humanoid(
    {"skin": "#c48a5c", "primary": "#3d5c3a", "secondary": "#547a4e",
     "shadow": "#263a24", "trim": "#7a8a4a", "boot": "#22301e", "eye": "#1c2418"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["monk_f"] = humanoid(
    {"skin": "#a8734a", "primary": "#8a1e1e", "secondary": "#c9a23a",
     "shadow": "#4a1010", "trim": "#e8c65a", "boot": "#5c4028", "eye": "#241810"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["alchemist_f"] = humanoid(
    {"skin": "#cf9a68", "primary": "#5c6b2e", "secondary": "#8a9a3e",
     "shadow": "#343d1a", "trim": "#c9d454", "boot": "#2a3014",
     "weapon": "#5c6b6b", "glow": "#c9e854", "eye": "#241c10"},
    hood=False, robed=False, weapon="staff", weapon_glow=True,
)

CHARACTERS["psychic_f"] = humanoid(
    {"skin": "#c9a8b0", "primary": "#3a2c4a", "secondary": "#5c4a7a",
     "shadow": "#241c30", "trim": "#9a7ac9", "boot": "#1c1624", "eye": "#c9e8f0"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["exorcist_f"] = humanoid(
    {"skin": "#e0b888", "primary": "#e8e0c8", "secondary": "#c9a23a",
     "shadow": "#a89a6e", "trim": "#8a1e1e", "boot": "#6b5c3a", "eye": "#241810"},
    hood=False, robed=True, weapon=None,
)

CHARACTERS["bard_f"] = humanoid(
    {"skin": "#c9926a", "primary": "#2e5c5c", "secondary": "#4a8a8a",
     "shadow": "#1c3a3a", "trim": "#7ac9c9", "boot": "#162e2e", "eye": "#c9f0e8"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["flooded_ghoul"] = humanoid(
    {"skin": "#7c9481", "primary": "#4a5a4d", "secondary": "#3d4a3f",
     "shadow": "#2e3a31", "trim": "#3a4a3d", "boot": "#233026", "eye": "#c9d43a"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["silt_rat"] = quadruped(
    {"body": "#8a7a5c", "accent": "#5c4f3a"}, size="small", eye_color="#1a1a1a",
)

CHARACTERS["flood_leech"] = blob(
    {"primary": "#3a5c4a", "secondary": "#5c8a6e", "shadow": "#26382e", "eye": "#c1502e"},
    shape="oval", eye=True,
)

CHARACTERS["drowned_stray"] = quadruped(
    {"body": "#5a6b5f", "accent": "#3a4a3d"}, size="medium", eye_color="#8a3a2e",
)

CHARACTERS["waterlogged_wisp"] = blob(
    {"primary": "#5ba8a0", "secondary": "#9fe0d6", "shadow": "#3a7068"}, shape="round",
)

CHARACTERS["bloated_toad"] = squat(
    {"body": "#6b7a4a", "belly": "#8a9a6e", "eye": "#d4c14a"},
)

CHARACTERS["sukhumvit_stalker"] = quadruped(
    {"body": "#5c6b4a", "accent": "#3d4a30"}, size="large", ridged=True, eye_color="#e8d24a",
)

CHARACTERS["shallow_tide_mother"] = boss_mass(
    {"primary": "#2e4a4a", "secondary": "#4a6b6b", "shadow": "#1d3232",
     "tendril": "#3a5c5c", "glow": "#e8a23d"},
)

# ---------------------------------------------------------------------------
# Render contact sheet for review
# ---------------------------------------------------------------------------
names = list(CHARACTERS.keys())
cols = 4
rows = (len(names) + cols - 1) // cols
cell_px = 32 * 6 + 16
sheet = Image.new("RGBA", (cols * cell_px, rows * cell_px), (18, 20, 26, 255))
for i, name in enumerate(names):
    r, c = divmod(i, cols)
    img = to_image(CHARACTERS[name], scale=6)
    sheet.paste(img, (c * cell_px + 8, r * cell_px + 8), img)
sheet.save(os.path.join(OUT_DIR, "_contact_sheet.png"))
print("wrote contact sheet with", len(names), "characters")

# ---------------------------------------------------------------------------
# Final export: native 32x32 idle1 + idle2 (bob) frames per character
# ---------------------------------------------------------------------------
CHARACTER_KIND = {
    "mage_f": "characters",
    "hunter_f": "characters",
    "healer_f": "characters",
    "necromancer_f": "characters",
    "assassin_f": "characters",
    "tank_f": "characters",
    "berserker_f": "characters",
    "summoner_f": "characters",
    "pyromancer_f": "characters",
    "ranger_f": "characters",
    "monk_f": "characters",
    "alchemist_f": "characters",
    "psychic_f": "characters",
    "exorcist_f": "characters",
    "bard_f": "characters",
    "flooded_ghoul": "monsters",
    "silt_rat": "monsters",
    "flood_leech": "monsters",
    "drowned_stray": "monsters",
    "waterlogged_wisp": "monsters",
    "bloated_toad": "monsters",
    "sukhumvit_stalker": "monsters",
    "shallow_tide_mother": "monsters",
}

GODOT_ASSET_ROOT = os.path.join(REPO_ROOT, "assets", "sprites")

for name, grid in CHARACTERS.items():
    kind = CHARACTER_KIND[name]
    out_dir = os.path.join(GODOT_ASSET_ROOT, kind)
    os.makedirs(out_dir, exist_ok=True)
    to_image(grid, scale=1).save(os.path.join(out_dir, f"{name}_idle1.png"))
    to_image(bob(grid), scale=1).save(os.path.join(out_dir, f"{name}_idle2.png"))
    print(f"  {name}: {kind}/{name}_idle1.png, {kind}/{name}_idle2.png")

print("done: native 32x32 PNGs written to", GODOT_ASSET_ROOT)
