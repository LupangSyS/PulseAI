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


def boost_color(hex_color, sat_boost=0.0, val_boost=0.0):
    """HSV saturate+brighten - the mechanism behind the rank power
    progression below (F plain -> S radiant), without hand-tuning a new
    palette per rank."""
    import colorsys
    r, g, b = (int(hex_color[i:i + 2], 16) / 255.0 for i in (1, 3, 5))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = min(1.0, s + sat_boost)
    v = min(1.0, v + val_boost)
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    return "#%02x%02x%02x" % (int(r * 255), int(g * 255), int(b * 255))


def boost_colors(colors, sat_boost, val_boost, keys=("primary", "secondary", "trim", "weapon", "glow")):
    out = dict(colors)
    for k in keys:
        if k in out:
            out[k] = boost_color(out[k], sat_boost, val_boost)
    return out


def add_aura(grid, aura_color, thickness=1):
    """Dilates a colored ring of `thickness` pixels around the character's
    current silhouette (into currently-empty cells only) - a cheap, always-
    correct "power glow" that works on any finished shape/weapon regardless
    of body plan, used for the C-through-S rank progression."""
    g = [row[:] for row in grid]
    filled = [[grid[r][c] is not None for c in range(N)] for r in range(N)]
    for _ in range(thickness):
        newly = []
        for r in range(N):
            for c in range(N):
                if filled[r][c] or g[r][c] is not None:
                    continue
                neighbors = [(r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)]
                if any(0 <= nr < N and 0 <= nc < N and filled[nr][nc] for nr, nc in neighbors):
                    newly.append((r, c))
        for r, c in newly:
            g[r][c] = aura_color
        for r, c in newly:
            filled[r][c] = True
    return g


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
def humanoid(colors, hood=False, robed=False, weapon=None, weapon_glow=False, weapon_side="right",
             wraps=False, aura=None, aura_thickness=0, mark=False, eye_override=None,
             pauldrons=False, cape=False, crown=False, halo=False, orbs=False):
    g = blank()
    skin = colors["skin"]
    primary = colors["primary"]
    secondary = colors["secondary"]
    shadow = colors["shadow"]
    trim = colors["trim"]
    boot = colors["boot"]
    hair = colors.get("hair", "#2a1f18")
    eye = colors.get("eye", "#2a1f18")
    eye_glint = lighten(eye)

    # --- Head ---
    if hood:
        fill(g, 8, 8, 24, 40, primary)
        fill(g, 9, 17, 20, 44, primary)
        fill(g, 17, 26, 23, 41, skin)
    else:
        # Hair cap (top + a little volume past the face's sides) over a
        # skin face from the brow line down - a bald skin-colored dome
        # read as "hair missing" at the sizes players actually see this.
        fill(g, 8, 8, 24, 40, hair)
        fill(g, 9, 13, 20, 44, hair)
        fill(g, 14, 26, 21, 43, skin)
        fill(g, 14, 19, 19, 20, hair)
        fill(g, 14, 19, 45, 46, hair)

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

    _draw_weapon(g, colors, weapon, weapon_side, weapon_glow)
    if wraps:
        wrap_color = colors.get("trim", secondary)
        fill(g, 44, 46, 9, 14, wrap_color)
        fill(g, 44, 46, 50, 55, wrap_color)

    # --- Rank-tier power progression: visible gear upgrades, not just a
    # brighter recolor - class evolution is meant to be hard-won, so the
    # payoff should read as genuinely more elegant/powerful, not just
    # "growing". C rank+ adds shoulder pauldrons; B rank+ adds a flowing
    # cape past the shoulders; S rank adds a circlet. Plus the existing
    # sak-yant-style forehead mark and glowing aura outline (add_aura),
    # and S rank overrides the eyes to a fully luminous color.
    if pauldrons:
        pauldron_light = lighten(trim, 0.3)
        fill(g, 27, 31, 6, 16, trim)
        fill(g, 27, 31, 48, 58, trim)
        fill(g, 27, 27, 6, 16, pauldron_light)
        fill(g, 27, 27, 48, 58, pauldron_light)
    if cape:
        cape_color = shadow
        fill(g, 26, 35, 4, 7, cape_color)
        fill(g, 35, 44, 3, 6, cape_color)
        fill(g, 44, 53, 2, 5, cape_color)
        fill(g, 26, 35, 57, 60, cape_color)
        fill(g, 35, 44, 58, 61, cape_color)
        fill(g, 44, 53, 59, 62, cape_color)
    if mark:
        mark_color = lighten(trim, 0.55)
        fill(g, 11, 12, 31, 32, mark_color)
    if crown:
        crown_color = lighten(trim, 0.4)
        fill(g, 8, 9, 22, 42, crown_color)
        fill(g, 6, 8, 30, 34, lighten(crown_color, 0.3))
    if eye_override:
        fill(g, 19, 22, 27, 30, eye_override)
        fill(g, 19, 22, 36, 39, eye_override)
    # S-rank-only apex flourishes: a halo arc hovering above the head and
    # two small companion orbs at the shoulders - reserved for the final
    # evolution so it reads as a genuinely different tier, not just this
    # family's usual color/aura scaled up one more notch.
    if halo:
        halo_color = lighten(colors.get("glow", trim), 0.3)
        cx, cy = 32.0, 6.0
        for r in range(0, 8):
            for c in range(14, 51):
                dx = (c - cx) / 2.2
                dy = r - cy
                dist = (dx * dx + dy * dy) ** 0.5
                if 3.0 <= dist <= 4.0:
                    g[r][c] = halo_color
    if orbs:
        orb_color = colors.get("glow", trim)
        orb_core = lighten(orb_color, 0.45)
        for ox in (3, 60):
            fill(g, 13, 17, ox - 2, ox + 2, orb_color)
            fill(g, 14, 16, ox - 1, ox + 1, orb_core)
    if aura and aura_thickness > 0:
        g = add_aura(g, aura, aura_thickness)
    return g


def _draw_weapon(g, colors, weapon, side, glow):
    """Every class carries something - a weapon is part of reading as a
    powerful Hunter, not an accessory. wc is the held-hand reference
    column; shapes are built out from there. `colors["weapon"]` is the
    primary material color; `colors.get("glow")` (falling back to trim)
    is the enchantment-glow accent used when `glow` is True."""
    if not weapon:
        return
    w = colors.get("weapon", colors["trim"])
    accent = colors.get("glow", colors["trim"])
    grip = colors.get("boot", "#3a2a1a")
    wc = 47 if side == "right" else 14

    if weapon == "staff":
        fill(g, 18, 50, wc, wc + 2, w)
        fill(g, 18, 50, wc, wc, lighten(w, 0.3))
        if glow:
            fill(g, 10, 17, wc - 3, wc + 5, accent)
            fill(g, 11, 14, wc - 1, wc + 3, lighten(accent, 0.35))
    elif weapon == "shield":
        wc0 = 9 if side == "left" else 45
        fill(g, 24, 48, wc0, wc0 + 8, w)
        fill(g, 24, 25, wc0, wc0 + 8, colors["trim"])
        fill(g, 47, 48, wc0, wc0 + 8, colors["trim"])
        fill(g, 33, 39, wc0 + 2, wc0 + 6, colors["trim"])
        if glow:
            fill(g, 34, 38, wc0 + 3, wc0 + 5, accent)
    elif weapon == "sword":
        fill(g, 14, 44, wc, wc + 2, w)
        fill(g, 14, 44, wc, wc, lighten(w, 0.3))
        fill(g, 43, 45, wc - 2, wc + 4, colors["trim"])
        fill(g, 45, 50, wc, wc + 2, grip)
        fill(g, 50, 52, wc - 1, wc + 3, colors["trim"])
        if glow:
            fill(g, 12, 15, wc - 1, wc + 3, accent)
    elif weapon == "spear":
        haft_c = 48 if side == "right" else 13
        fill(g, 8, 52, haft_c, haft_c + 2, grip)
        fill(g, 6, 9, haft_c - 1, haft_c + 3, w)
        fill(g, 3, 6, haft_c, haft_c + 2, w)
        if glow:
            fill(g, 2, 5, haft_c - 1, haft_c + 3, accent)
    elif weapon == "axe":
        fill(g, 20, 52, wc, wc + 2, grip)
        fill(g, 16, 18, wc - 5, wc + 2, w)
        fill(g, 18, 23, wc - 8, wc + 2, w)
        fill(g, 23, 27, wc - 5, wc + 2, w)
        fill(g, 16, 27, wc + 2, wc + 2, lighten(w, 0.3))
        if glow:
            fill(g, 20, 23, wc - 7, wc - 6, accent)
    elif weapon == "bow":
        fill(g, 14, 16, wc, wc + 2, w)
        fill(g, 16, 19, wc + 2, wc + 4, w)
        fill(g, 19, 26, wc + 3, wc + 5, w)
        fill(g, 26, 33, wc + 3, wc + 5, w)
        fill(g, 33, 36, wc + 2, wc + 4, w)
        fill(g, 36, 38, wc, wc + 2, w)
        for r in range(15, 38):
            fill(g, r, r, wc, wc, colors.get("secondary", "#cccccc"))
        if glow:
            fill(g, 24, 27, wc + 4, wc + 6, accent)
    elif weapon == "dagger":
        fill(g, 30, 44, wc, wc + 2, w)
        fill(g, 29, 30, wc - 1, wc + 3, colors["trim"])
        fill(g, 44, 48, wc, wc + 2, grip)
        if glow:
            fill(g, 27, 29, wc, wc + 2, accent)
    elif weapon == "orb":
        fill(g, 32, 39, wc - 2, wc + 5, accent)
        fill(g, 33, 36, wc - 1, wc + 2, lighten(accent, 0.4))
        if glow:
            fill(g, 30, 31, wc, wc + 3, lighten(accent, 0.2))
    elif weapon == "wand":
        # A short rod held at hand height, not a towering staff - the
        # ornament sits just above the hand/shoulder, not up near the head.
        fill(g, 24, 46, wc, wc + 2, w)
        fill(g, 20, 24, wc - 2, wc + 4, accent)
        fill(g, 21, 23, wc - 1, wc + 3, lighten(accent, 0.3))
        if glow:
            fill(g, 18, 20, wc - 1, wc + 3, lighten(accent, 0.35))


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

# Each of the 15 class families' base look (F-rank) - the single source of
# truth for that family's silhouette/palette. Every other rank (E-S) is
# generated from this same config via RANK_TIERS below, not hand-authored
# separately - see _generate_rank_chain.
FAMILY_BASE = {
    "mage": dict(
        colors={"skin": "#d9a066", "primary": "#2f6d64", "secondary": "#255a53",
                "shadow": "#1d4740", "trim": "#c98a3a", "boot": "#16302c", "hair": "#4a3528",
                "weapon": "#8a7a63", "glow": "#f0b94d", "eye": "#241810"},
        hood=True, robed=True, weapon="staff", weapon_glow=True,
    ),
    "hunter": dict(
        colors={"skin": "#c48958", "primary": "#5c5233", "secondary": "#7a6f47",
                "shadow": "#3a3420", "trim": "#a85c2e", "boot": "#2e2a1c", "hair": "#2e2013", "eye": "#2a1c10"},
        hood=False, robed=False, weapon="spear",
    ),
    "healer": dict(
        colors={"skin": "#e0ab7a", "primary": "#d8d2c4", "secondary": "#c46a5e",
                "shadow": "#8a8477", "trim": "#c46a5e", "boot": "#5c574c", "hair": "#8a5a3a",
                "weapon": "#b8875a", "glow": "#f0d8c0", "eye": "#3a2a1e"},
        hood=False, robed=False, weapon="wand",
    ),
    "necromancer": dict(
        colors={"skin": "#a68f8a", "primary": "#3a2a45", "secondary": "#2e2038",
                "shadow": "#1c1424", "trim": "#6b4a8a", "boot": "#180f1e", "hair": "#241a2e",
                "weapon": "#5c4a4a", "glow": "#7de08a", "eye": "#7de08a"},
        hood=True, robed=True, weapon="staff", weapon_glow=True,
    ),
    "assassin": dict(
        colors={"skin": "#b98a6a", "primary": "#2c2c34", "secondary": "#22222a",
                "shadow": "#161619", "trim": "#5a1e1e", "boot": "#0e0e11", "hair": "#141414",
                "weapon": "#c8ccd4", "glow": "#c9a23a", "eye": "#c9a23a"},
        hood=True, robed=False, weapon="dagger",
    ),
    "tank": dict(
        colors={"skin": "#c99566", "primary": "#3a4a5c", "secondary": "#2e3a48",
                "shadow": "#1e2730", "trim": "#8a9aa8", "boot": "#1a2228", "hair": "#4a4a52",
                "weapon": "#7a828a", "glow": "#c8d4dc", "eye": "#1c1410"},
        hood=False, robed=False, weapon="shield", weapon_side="left",
    ),
    "berserker": dict(
        colors={"skin": "#b97a52", "primary": "#6b2620", "secondary": "#4a1c18",
                "shadow": "#301210", "trim": "#c9622e", "boot": "#241010", "hair": "#2e1610",
                "weapon": "#5c5c5c", "glow": "#f0782c", "eye": "#e8c23a"},
        hood=False, robed=False, weapon="axe",
    ),
    "summoner": dict(
        colors={"skin": "#d9a874", "primary": "#7a1e2e", "secondary": "#c9a23a",
                "shadow": "#4a1420", "trim": "#e8c65a", "boot": "#3a1418", "hair": "#241010",
                "weapon": "#8a5a3a", "glow": "#e8c65a", "eye": "#241810"},
        hood=False, robed=True, weapon="wand",
    ),
    "pyromancer": dict(
        colors={"skin": "#c9855a", "primary": "#8a2e1e", "secondary": "#c94e26",
                "shadow": "#4a1810", "trim": "#e8a23a", "boot": "#241008", "hair": "#5a2a1a",
                "weapon": "#4a3a30", "glow": "#f0782c", "eye": "#f0b23a"},
        hood=True, robed=True, weapon="staff", weapon_glow=True, weapon_side="left",
    ),
    "ranger": dict(
        colors={"skin": "#c48a5c", "primary": "#3d5c3a", "secondary": "#547a4e",
                "shadow": "#263a24", "trim": "#7a8a4a", "boot": "#22301e", "hair": "#3a2c1a",
                "weapon": "#5c4530", "glow": "#c9d454", "eye": "#1c2418"},
        hood=False, robed=False, weapon="bow",
    ),
    "monk": dict(
        colors={"skin": "#a8734a", "primary": "#8a1e1e", "secondary": "#c9a23a",
                "shadow": "#4a1010", "trim": "#e8c65a", "boot": "#5c4028", "hair": "#1a1410", "eye": "#241810"},
        hood=False, robed=False, wraps=True,
    ),
    "alchemist": dict(
        colors={"skin": "#cf9a68", "primary": "#5c6b2e", "secondary": "#8a9a3e",
                "shadow": "#343d1a", "trim": "#c9d454", "boot": "#2a3014", "hair": "#8a6a3a",
                "weapon": "#5c6b6b", "glow": "#c9e854", "eye": "#241c10"},
        hood=False, robed=False, weapon="staff", weapon_glow=True,
    ),
    "psychic": dict(
        colors={"skin": "#c9a8b0", "primary": "#3a2c4a", "secondary": "#5c4a7a",
                "shadow": "#241c30", "trim": "#9a7ac9", "boot": "#1c1624", "hair": "#d8c8e0",
                "weapon": "#5c4a7a", "glow": "#c9e8f0", "eye": "#c9e8f0"},
        hood=False, robed=False, weapon="orb",
    ),
    "exorcist": dict(
        colors={"skin": "#e0b888", "primary": "#e8e0c8", "secondary": "#c9a23a",
                "shadow": "#a89a6e", "trim": "#8a1e1e", "boot": "#6b5c3a", "hair": "#e8e0c8",
                "weapon": "#a8843a", "glow": "#f0d878", "eye": "#241810"},
        hood=False, robed=True, weapon="wand",
    ),
    "bard": dict(
        colors={"skin": "#c9926a", "primary": "#2e5c5c", "secondary": "#4a8a8a",
                "shadow": "#1c3a3a", "trim": "#7ac9c9", "boot": "#162e2e", "hair": "#1c2a2a",
                "weapon": "#3a2818", "glow": "#c9f0e8", "eye": "#c9f0e8"},
        hood=False, robed=False, weapon="wand",
    ),
}

# Rank power progression: F is the family's plain base look (no entry
# needed - handled separately below); each tier after that layers on a
# color-intensity boost, and from C rank up, a forehead mark + a glowing
# aura outline that thickens with rank. S rank also gets fully luminous
# eyes. Uniform across all 15 families - it's about *rank*, not myth-
# specific iconography (which would need bespoke art per family to do
# justice to; this is the sustainable alternative for 90 classes at once).
RANK_TIERS = {
    "E": dict(sat=0.05, val=0.03, aura=None, aura_t=0, mark=False, eye=False,
              pauldrons=False, cape=False, crown=False, halo=False, orbs=False),
    "D": dict(sat=0.10, val=0.06, aura=None, aura_t=0, mark=False, eye=False,
              pauldrons=False, cape=False, crown=False, halo=False, orbs=False),
    "C": dict(sat=0.15, val=0.10, aura="trim", aura_t=1, mark=True, eye=False,
              pauldrons=True, cape=False, crown=False, halo=False, orbs=False),
    "B": dict(sat=0.20, val=0.14, aura="trim", aura_t=1, mark=True, eye=False,
              pauldrons=True, cape=True, crown=False, halo=False, orbs=False),
    "A": dict(sat=0.25, val=0.18, aura="glow", aura_t=2, mark=True, eye=False,
              pauldrons=True, cape=True, crown=False, halo=False, orbs=False),
    "S": dict(sat=0.32, val=0.22, aura="glow", aura_t=2, mark=True, eye=True,
              pauldrons=True, cape=True, crown=True, halo=True, orbs=True),
}


def _generate_rank_chain(family: str, base: dict, chain_ids: list) -> None:
    """chain_ids is [(rank, class_id), ...] from F to S, in order, read
    straight from classes.json (see the bottom of this file) - ranks don't
    follow a simple id naming pattern (E-rank especially), so this never
    guesses ids, only uses what the real roster data says."""
    for rank, class_id in chain_ids:
        if rank == "F":
            CHARACTERS[class_id] = humanoid(dict(base["colors"]), hood=base["hood"], robed=base["robed"],
                                             weapon=base.get("weapon"), weapon_glow=base.get("weapon_glow", False),
                                             weapon_side=base.get("weapon_side", "right"),
                                             wraps=base.get("wraps", False))
            continue
        tier = RANK_TIERS[rank]
        colors = boost_colors(base["colors"], tier["sat"], tier["val"])
        aura_color = None
        if tier["aura"]:
            aura_color = lighten(colors.get(tier["aura"], colors["primary"]), 0.4)
        eye_override = None
        if tier["eye"]:
            eye_override = lighten(colors.get("glow", colors["eye"]), 0.55)
        CHARACTERS[class_id] = humanoid(
            colors, hood=base["hood"], robed=base["robed"],
            weapon=base.get("weapon"), weapon_glow=base.get("weapon_glow", False) or bool(tier["aura"]),
            weapon_side=base.get("weapon_side", "right"), wraps=base.get("wraps", False),
            aura=aura_color, aura_thickness=tier["aura_t"], mark=tier["mark"], eye_override=eye_override,
            pauldrons=tier["pauldrons"], cape=tier["cape"], crown=tier["crown"],
            halo=tier["halo"], orbs=tier["orbs"],
        )


# --- Generate all 105 playable-class portraits (F through S, all 15
# families) by walking each family's real evolves_to chain in
# data/classes.json - never guessing rank->id naming (E-rank ids
# especially don't follow "family_e", e.g. mage's E rank is
# "naga_mage_e", not "mage_e").
import json as _json
_CLASSES_PATH = os.path.join(REPO_ROOT, "data", "classes.json")
with open(_CLASSES_PATH) as _f:
    _all_classes = _json.load(_f)
_by_id = {c["id"]: c for c in _all_classes}

for _family, _base in FAMILY_BASE.items():
    _f_rank = _by_id.get("%s_f" % _family)
    if _f_rank is None:
        raise SystemExit("FAMILY_BASE has '%s' but no %s_f in classes.json" % (_family, _family))
    _chain = [("F", _f_rank["id"])]
    _cur = _f_rank
    while _cur.get("evolves_to"):
        _next_id = _cur["evolves_to"][0]
        if _next_id not in _by_id:
            break
        _cur = _by_id[_next_id]
        _chain.append((_cur["rank"], _cur["id"]))
    if len(_chain) != 7:
        raise SystemExit("expected a 7-rank chain (F-S) for '%s', got %d: %s" % (_family, len(_chain), _chain))
    _generate_rank_chain(_family, _base, _chain)

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

CHARACTERS["current_dragger"] = quadruped(
    {"body": "#3a4a52", "accent": "#6b8a8a"}, size="large", ridged=True, eye_color="#e85a2e",
)

CHARACTERS["voltaic_current_eel"] = blob(
    {"primary": "#1a3a4a", "secondary": "#3ad4e8", "shadow": "#0e2028", "eye": "#e8f43a"},
    shape="oval", eye=True,
)

# --- District 2: Chatuchak Ruins ---------------------------------------
CHARACTERS["market_dog"] = quadruped(
    {"body": "#8a6b4a", "accent": "#c9622e"}, size="medium", eye_color="#e8c23a",
)

CHARACTERS["stall_wraith"] = blob(
    {"primary": "#6b6558", "secondary": "#9a9284", "shadow": "#4a453c", "eye": "#c9e854"},
    shape="round", eye=True,
)

CHARACTERS["trickster_imp"] = blob(
    {"primary": "#5c3a6b", "secondary": "#8a5ba8", "shadow": "#3a2445", "eye": "#e8c23a"},
    shape="oval", eye=True,
)

CHARACTERS["caged_songbird"] = blob(
    {"primary": "#c9622e", "secondary": "#e8a23a", "shadow": "#8a3e18", "eye": "#241810"},
    shape="round", eye=True,
)

CHARACTERS["talisman_husk"] = squat(
    {"body": "#a8734a", "belly": "#c9a26e", "eye": "#e8843a"},
)

CHARACTERS["scale_merchant"] = humanoid(
    {"skin": "#a8845c", "primary": "#3a4a3e", "secondary": "#5c7a5e",
     "shadow": "#242e26", "trim": "#8a9a54", "boot": "#1a221c", "hair": "#241a10",
     "weapon": "#5c8a6e", "glow": "#c9e854", "eye": "#e8c23a"},
    hood=False, robed=True, weapon="orb", weapon_glow=True,
)

CHARACTERS["chimera_of_drowned_aviary"] = boss_mass(
    {"primary": "#4a4436", "secondary": "#8a7a54", "shadow": "#2e2a20",
     "tendril": "#6b5c3a", "glow": "#c9e854"},
)

CHARACTERS["feral_mannequin"] = humanoid(
    {"skin": "#d8cfc0", "primary": "#8a3e4a", "secondary": "#6b2e38",
     "shadow": "#3e1a20", "trim": "#c9622e", "boot": "#4a2418", "eye": "#1a1a1a"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["vivarium_stalker"] = quadruped(
    {"body": "#5c7a3a", "accent": "#8aa354"}, size="medium", eye_color="#e8c23a",
)

# --- District 3: Klong Toey Canals ---------------------------------------
CHARACTERS["canal_crocodile"] = quadruped(
    {"body": "#4a5c3a", "accent": "#8a9a54"}, size="large", ridged=True, eye_color="#e8c23a",
)

CHARACTERS["canal_eel"] = blob(
    {"primary": "#1c2024", "secondary": "#3a4550", "shadow": "#0e1114", "eye": "#c9e854"},
    shape="oval", eye=True,
)

CHARACTERS["drowned_dockworker"] = humanoid(
    {"skin": "#8a9484", "primary": "#8a7a3a", "secondary": "#6b5e2e",
     "shadow": "#3a3418", "trim": "#c9a23a", "boot": "#241f10", "eye": "#c9d43a"},
    hood=False, robed=False, weapon=None,
)

CHARACTERS["rusted_stevedore"] = squat(
    {"body": "#8a5a3a", "belly": "#c9843a", "eye": "#e85a2e"},
)

CHARACTERS["oil_slick_wisp"] = blob(
    {"primary": "#4a3d5c", "secondary": "#7a5ba8", "shadow": "#241c30"}, shape="round",
)

CHARACTERS["sluice_ripper"] = humanoid(
    {"skin": "#a8845c", "primary": "#3a3428", "secondary": "#c9a23a",
     "shadow": "#241f18", "trim": "#1a1a1a", "boot": "#141414", "hair": "#1a1410",
     "weapon": "#7a828a", "glow": "#e85a2e", "eye": "#e8c23a"},
    hood=False, robed=False, weapon="axe", weapon_glow=True,
)

CHARACTERS["klong_toey_leviathan"] = boss_mass(
    {"primary": "#1a1c14", "secondary": "#3a3424", "shadow": "#0d0e0a",
     "tendril": "#2e2818", "glow": "#e85a2e"},
)

# ---------------------------------------------------------------------------
# Render contact sheet for review
# ---------------------------------------------------------------------------
names = list(CHARACTERS.keys())
# 7 columns = one row per family's full F->S chain, since CHARACTERS is
# populated in that order (monsters trail off ragged at the bottom, fine).
cols = 7
rows = (len(names) + cols - 1) // cols
cell_px = N * 2 + 10
sheet = Image.new("RGBA", (cols * cell_px, rows * cell_px), (18, 20, 26, 255))
for i, name in enumerate(names):
    r, c = divmod(i, cols)
    img = to_image(CHARACTERS[name], scale=2)
    sheet.paste(img, (c * cell_px + 8, r * cell_px + 8), img)
sheet.save(os.path.join(OUT_DIR, "_contact_sheet.png"))
print("wrote contact sheet with", len(names), "characters")

# ---------------------------------------------------------------------------
# Final export: native 64x64 idle1 + idle2 (bob) frames per character
# ---------------------------------------------------------------------------
# Every class id from classes.json is a "characters" sprite; the fixed
# set of monster ids below are "monsters". Built this way (not hardcoded
# per class) so it can never drift out of sync with the 105-class roster.
CHARACTER_KIND = {c["id"]: "characters" for c in _all_classes}
CHARACTER_KIND.update({
    "flooded_ghoul": "monsters",
    "silt_rat": "monsters",
    "flood_leech": "monsters",
    "drowned_stray": "monsters",
    "waterlogged_wisp": "monsters",
    "bloated_toad": "monsters",
    "sukhumvit_stalker": "monsters",
    "shallow_tide_mother": "monsters",
    "current_dragger": "monsters",
    "voltaic_current_eel": "monsters",
    "feral_mannequin": "monsters",
    "vivarium_stalker": "monsters",
    "market_dog": "monsters",
    "stall_wraith": "monsters",
    "trickster_imp": "monsters",
    "caged_songbird": "monsters",
    "talisman_husk": "monsters",
    "scale_merchant": "monsters",
    "chimera_of_drowned_aviary": "monsters",
    "canal_crocodile": "monsters",
    "canal_eel": "monsters",
    "drowned_dockworker": "monsters",
    "rusted_stevedore": "monsters",
    "oil_slick_wisp": "monsters",
    "sluice_ripper": "monsters",
    "klong_toey_leviathan": "monsters",
})

GODOT_ASSET_ROOT = os.path.join(REPO_ROOT, "assets", "sprites")

for name, grid in CHARACTERS.items():
    kind = CHARACTER_KIND[name]
    out_dir = os.path.join(GODOT_ASSET_ROOT, kind)
    os.makedirs(out_dir, exist_ok=True)
    to_image(grid, scale=1).save(os.path.join(out_dir, f"{name}_idle1.png"))
    to_image(bob(grid), scale=1).save(os.path.join(out_dir, f"{name}_idle2.png"))
    print(f"  {name}: {kind}/{name}_idle1.png, {kind}/{name}_idle2.png")

print("done: native 64x64 PNGs written to", GODOT_ASSET_ROOT)
