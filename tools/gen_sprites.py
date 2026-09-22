"""Generates in-game character sprites (idle + bob frame each) as true
64x64-native pixel art PNGs, using region-fill generators (same principle
as the Pixel Studio artifact - https://claude.ai/artifact/KW9UfmerkrK3gckV5ypriH)
rather than any AI image model: every pixel is an explicit color choice,
so hard edges / limited palette / real alpha transparency are guaranteed,
not hoped for.

Native resolution was bumped from an original 32x32 to 64x64 (real added
detail - eye highlights, fabric-fold shading, finer weapon/shield shapes -
not just the old shapes blown up 2x with nearest-neighbor scaling, which
would look identical, just blockier) because 32x32 was reading as too low-
fidelity/"eyesore" once rendered at the sizes players actually see it at.
See combat.gd/status_menu.gd's portrait box sizes, which grew to match.

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

N = 64
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


def lighten(hex_color, amt=0.45):
    """Blends a hex color toward white - used for eye glints/highlights
    without requiring every character config to define an extra color."""
    r, g, b = (int(hex_color[i:i + 2], 16) for i in (1, 3, 5))
    r = int(r + (255 - r) * amt)
    g = int(g + (255 - g) * amt)
    b = int(b + (255 - b) * amt)
    return "#%02x%02x%02x" % (r, g, b)


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
    for r in range(N - 2):
        for c in range(N):
            g[r][c] = grid[r + 2][c]
    return g


# ---------------------------------------------------------------------------
# Humanoid (player classes, upright monsters)
# ---------------------------------------------------------------------------
def humanoid(colors, hood=False, robed=False, weapon=None, weapon_glow=False, weapon_side="right"):
    g = blank()
    skin = colors["skin"]
    primary = colors["primary"]
    secondary = colors["secondary"]
    shadow = colors["shadow"]
    trim = colors["trim"]
    boot = colors["boot"]
    eye = colors.get("eye", "#2a1f18")
    eye_glint = lighten(eye)

    # --- Head ---
    if hood:
        fill(g, 8, 8, 24, 40, primary)
        fill(g, 9, 17, 20, 44, primary)
        fill(g, 17, 26, 23, 41, skin)
    else:
        fill(g, 9, 9, 24, 40, skin)
        fill(g, 10, 26, 21, 43, skin)

    # Eyes: base color + a small lighter glint for a less "dead" look.
    fill(g, 19, 22, 27, 30, eye)
    fill(g, 19, 20, 27, 28, eye_glint)
    fill(g, 19, 22, 36, 39, eye)
    fill(g, 19, 20, 36, 37, eye_glint)

    # --- Neck / torso ---
    fill(g, 26, 28, 29, 35, skin)
    fill(g, 28, 52, 16, 48, primary)

    # Sleeves + hands
    fill(g, 28, 46, 8, 15, secondary)
    fill(g, 28, 46, 49, 56, secondary)
    fill(g, 42, 48, 8, 15, skin)
    fill(g, 42, 48, 49, 56, skin)

    # Fabric-fold shading (diagonal accents) for a less flat-block torso.
    for i in range(6):
        fill(g, 32 + i, 32 + i, 18 + i, 19 + i, shadow)
        fill(g, 32 + i, 32 + i, 45 - i, 46 - i, shadow)

    fill(g, 52, 52, 16, 48, trim)

    if robed:
        fill(g, 53, 60, 14, 50, primary)
        fill(g, 53, 60, 31, 32, shadow)
        fill(g, 61, 61, 14, 50, shadow)
        fill(g, 62, 63, 22, 28, boot)
        fill(g, 62, 63, 36, 42, boot)
    else:
        fill(g, 53, 60, 16, 29, secondary)
        fill(g, 53, 60, 35, 48, secondary)
        fill(g, 61, 63, 16, 29, boot)
        fill(g, 61, 63, 35, 48, boot)

    if weapon == "staff":
        weapon_light = lighten(colors.get("weapon", "#8a7a63"), 0.3)
        wc = 47 if weapon_side == "right" else 14
        fill(g, 18, 50, wc, wc + 2, colors["weapon"])
        fill(g, 18, 50, wc, wc, weapon_light)
        if weapon_glow:
            glow = colors["glow"]
            fill(g, 10, 17, wc - 3, wc + 5, glow)
            fill(g, 11, 14, wc - 1, wc + 3, lighten(glow, 0.35))
    elif weapon == "shield":
        wc0 = 9 if weapon_side == "left" else 45
        fill(g, 24, 48, wc0, wc0 + 8, colors["weapon"])
        fill(g, 24, 25, wc0, wc0 + 8, trim)
        fill(g, 47, 48, wc0, wc0 + 8, trim)
        fill(g, 33, 39, wc0 + 2, wc0 + 6, trim)
    return g


# ---------------------------------------------------------------------------
# Quadruped (rat / dog / crocodile-like), size = 'small' | 'medium' | 'large'
# ---------------------------------------------------------------------------
def quadruped(colors, size="small", ridged=False, eye_color="#1a1a1a"):
    g = blank()
    body = colors["body"]
    accent = colors["accent"]
    glint = lighten(eye_color)
    if size == "small":
        fill(g, 30, 40, 20, 42, body)
        fill(g, 26, 36, 40, 52, body)
        fill(g, 24, 26, 42, 44, accent)
        fill(g, 24, 26, 48, 50, accent)
        fill(g, 32, 34, 10, 20, accent)
        fill(g, 40, 46, 24, 28, accent)
        fill(g, 40, 46, 36, 40, accent)
        fill(g, 30, 31, 48, 49, eye_color)
        fill(g, 30, 30, 48, 48, glint)
    elif size == "medium":
        fill(g, 26, 42, 16, 46, body)
        fill(g, 22, 36, 44, 58, body)
        fill(g, 20, 24, 46, 48, accent)
        fill(g, 20, 24, 54, 56, accent)
        fill(g, 28, 32, 6, 16, accent)
        fill(g, 42, 52, 20, 26, accent)
        fill(g, 42, 52, 36, 42, accent)
        fill(g, 28, 29, 52, 53, eye_color)
        fill(g, 28, 28, 52, 52, glint)
        if ridged:
            for cc in range(20, 44, 6):
                fill(g, 20, 22, cc, cc + 2, accent)
    else:  # large (mini-boss scale)
        fill(g, 26, 44, 12, 52, body)
        fill(g, 20, 32, 48, 62, body)
        fill(g, 18, 18, 50, 60, accent)
        fill(g, 24, 30, 0, 12, accent)
        fill(g, 44, 54, 16, 24, accent)
        fill(g, 44, 54, 40, 48, accent)
        fill(g, 26, 27, 56, 58, eye_color)
        fill(g, 26, 26, 56, 56, glint)
        if ridged:
            for cc in range(16, 48, 6):
                fill(g, 22, 24, cc, cc + 2, accent)
    return g


# ---------------------------------------------------------------------------
# Blob / amorphous (leech, wisp)
# ---------------------------------------------------------------------------
def blob(colors, shape="oval", eye=False):
    g = blank()
    primary = colors["primary"]
    secondary = colors["secondary"]
    shadow = colors["shadow"]
    if shape == "oval":
        fill(g, 30, 40, 12, 50, primary)
        fill(g, 26, 44, 18, 44, primary)
        fill(g, 32, 38, 16, 46, secondary)
        fill(g, 34, 36, 10, 16, shadow)
        fill(g, 33, 34, 20, 40, lighten(secondary, 0.25))
    else:  # round wisp
        fill(g, 22, 40, 22, 40, primary)
        fill(g, 18, 42, 26, 36, primary)
        fill(g, 26, 36, 26, 36, secondary)
        fill(g, 27, 30, 28, 32, lighten(secondary, 0.3))
    if eye:
        eye_color = colors.get("eye", "#1a1a1a")
        fill(g, 32, 34, 40, 42, eye_color)
        fill(g, 32, 32, 40, 40, lighten(eye_color))
    return g


# ---------------------------------------------------------------------------
# Squat (toad)
# ---------------------------------------------------------------------------
def squat(colors):
    g = blank()
    body = colors["body"]
    belly = colors["belly"]
    eye = colors["eye"]
    fill(g, 36, 54, 14, 48, body)
    fill(g, 42, 50, 18, 44, belly)
    fill(g, 26, 34, 20, 28, body)
    fill(g, 26, 34, 34, 42, body)
    fill(g, 28, 30, 22, 26, eye)
    fill(g, 28, 28, 22, 24, lighten(eye))
    fill(g, 28, 30, 36, 40, eye)
    fill(g, 28, 28, 36, 38, lighten(eye))
    fill(g, 54, 58, 18, 24, body)
    fill(g, 54, 58, 38, 44, body)
    fill(g, 44, 46, 16, 46, lighten(belly, 0.2))
    return g


# ---------------------------------------------------------------------------
# Boss (Tide Mother): large central mass + tendrils
# ---------------------------------------------------------------------------
def boss_mass(colors):
    g = blank()
    primary = colors["primary"]
    secondary = colors["secondary"]
    shadow = colors["shadow"]
    tendril = colors["tendril"]
    glow = colors["glow"]
    fill(g, 16, 50, 18, 46, primary)
    fill(g, 12, 54, 24, 40, primary)
    fill(g, 22, 40, 24, 40, secondary)
    for tx, ty in [(6, 24), (56, 20), (4, 44), (58, 48)]:
        if tx < 32:
            fill(g, ty, ty + 2, tx, 22, tendril)
        else:
            fill(g, ty, ty + 2, 42, tx, tendril)
    fill(g, 26, 28, 26, 28, glow)
    fill(g, 26, 28, 36, 38, glow)
    fill(g, 26, 26, 26, 26, lighten(glow, 0.3))
    fill(g, 26, 26, 36, 36, lighten(glow, 0.3))
    fill(g, 54, 56, 28, 36, shadow)
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
cell_px = N * 3 + 16
sheet = Image.new("RGBA", (cols * cell_px, rows * cell_px), (18, 20, 26, 255))
for i, name in enumerate(names):
    r, c = divmod(i, cols)
    img = to_image(CHARACTERS[name], scale=3)
    sheet.paste(img, (c * cell_px + 8, r * cell_px + 8), img)
sheet.save(os.path.join(OUT_DIR, "_contact_sheet.png"))
print("wrote contact sheet with", len(names), "characters")

# ---------------------------------------------------------------------------
# Final export: native 64x64 idle1 + idle2 (bob) frames per character
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

print("done: native 64x64 PNGs written to", GODOT_ASSET_ROOT)
