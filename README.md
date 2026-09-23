# Deluge Chronicles (working title)

A turn-based card RPG built in [Godot 4](https://godotengine.org/) (4.3+).
Set in Bangkok, October 2025 onward — the immediate aftermath of a
mega-flood that drowned the surface and released mystic power and
monsters sealed since before history. Players take on hidden, evolvable
RPG classes (F-rank to S-rank) discovered through exploration and quests
rather than picked from a menu, exploring a world of districts, dungeons,
and dimensions toward a save-the-world climax. Full story bible in
GDD.md.

This repo previously hosted a different, unrelated project (a news/stocks
dashboard). That project has been retired; everything here now is the game.

Full design context — world map, class system, combat system, the
exploration/encounter system, and what's built vs. still on the roadmap —
lives in **[GDD.md](GDD.md)**. Read that first.

## Status

Early prototype, but with one fully playable vertical slice. What
currently exists:

- A data-driven class/card system (`data/classes.json`, `data/cards.json`)
  loaded at runtime by the `GameData` autoload.
- **105 classes** (15 families, each a full F→E→D→C→B→A→S evolution
  chain) fully defined with lore, stats, and decks — see GDD.md's roster
  table for the full list. Every chain culminates in the character
  becoming a full avatar of the Thai myth it's anchored to (Naga, Yaksha,
  Erawan, Garuda, Hanuman, Kuman Thong, Rakshasa, and more).
- **Three real, explorable districts**, each with grid movement, a
  mini-boss and boss (with stage transitions) permanently removed once
  beaten, item pickups + monster loot, and a cluster of events built on
  the same `requires_flag`/`sets_flag` puzzle mechanic:
  - **Sukhumvit Shallows** *(flagship depth pass — see below)*: a real
    28×20-cell map (up from the original 10×8), 14 regular monster
    spawns across 7 species, mini-boss **The Neon Strangler** (now 58
    HP, 2 stages) and boss **Phra Khanong Mother** (now 92 HP, 3
    stages), 16 events including two revisitable NPCs (Uncle Somchai,
    Sister Da), two chained puzzles (the **Breaker Pump Protocol** and
    the arcade's **High Score Relay**), and 3 locked areas (a
    keycard-gated survivor haven, a flag-gated deep-water zone the
    Breaker Pump Protocol actually unlocks, and a mini-boss-key-gated
    secret vault) — see "Bigger, harder Sukhumvit Shallows" below for
    the full rundown.
  - **Chatuchak Ruins**: mini-boss **The Scale Merchant** (2 stages),
    boss **The Chimera of the Drowned Aviary** (3 stages), 7 events
    including the Watchmaker (Kru Viroj) and the **Amulet Scale**
    puzzle (find a cursed weight, balance the scale, open the vault -
    each step fails cleanly if attempted out of order, so it can't
    softlock).
  - **Klong Toey Canals**: mini-boss **The Sluice Ripper** (2 stages),
    boss **Klong Toey Leviathan** (The Scum Matron, 3 stages), 7 events
    including Commander Lek and the **Crane Sluice Alignment** puzzle
    (align bridge alpha, then beta, then lock the crane).

  Walking into a monster transitions into a real combat encounter and
  back. There's no travel between districts yet, so each is its own
  standalone run picked from a "[DEV] <district>" main-menu button. 9
  more districts, 10 dungeons, and 10 "beyond human sense" dimensions
  are fully designed in GDD.md's World Map but not yet built as data.
- Monsters are now data-driven too (`data/monsters.json`) with weighted
  AI move lists and multi-stage boss/mini-boss transitions, using the
  same six card effects as the player (including the two newest,
  `dot`/`aoe_damage`/`execute`, all rank-gated D/B/S+).
- **Real save/load** (single slot): "Save Game" in the status menu
  (Escape from the overworld) writes everything - class, HP, resource,
  inventory, and every district's exploration progress (spawns, items,
  events, puzzle flags) - to `user://saves/slot1.json`. "Continue" on
  the main menu appears once a save exists and resumes at the exact
  saved district and cell.
- **Locked doors/gates**: a cell can require a specific item in
  inventory (a permanent key, not consumed) or a district flag (the same
  flag a puzzle event sets) before the player can cross it, distinct
  from a plain wall - it still renders as normal walkable ground, just
  refuses passage until the requirement's met. Powers Sukhumvit
  Shallows' keycard-gated survivor haven, its Breaker-Pump-Protocol-
  gated deep zone, and its mini-boss-key-gated secret vault.
- **Bigger, harder Sukhumvit Shallows** (the flagship depth pass): the
  district grew from a 10×8 pilot to a real 28×20 map, procedurally laid
  out with guaranteed full connectivity
  (`tools/gen_district_layout.py`'s carve-one-obstacle-at-a-time-and-
  BFS-verify generator, plus a room-carving helper for walled sub-areas
  with exactly one door) and then hand-zoned into a canal grind area, a
  transformer zone, the Soi 11 Drowned Arcade (now with its own second
  puzzle, the High Score Relay), the keycard-gated BTS Asok Haven, a
  walled-off Deep Flood Zone gated behind actually finishing the Breaker
  Pump Protocol, and a secret vault gated behind a mini-boss drop. Two
  new tougher monster species (Current Dragger, Voltaic Current-Eel)
  patrol the deep zone, and both the mini-boss and boss got real stat
  and phase increases rather than just more square footage. **Known
  issue**: scrolling far enough from a district's entrance can show a
  dark background instead of tiles - a pre-existing tile-rendering bug
  this depth pass made much easier to trigger (it also reproduces on the
  small original districts if you walk far enough), investigated at
  length but not yet root-caused; collision/spawns/events/locks are
  unaffected since they never depended on the visual tile layer.
- Main menu has two real entry points and two dev shortcuts: "Start
  Exploring" begins a real run and drops into Sukhumvit Shallows;
  "[DEV] Enter the Flood" is an isolated combat-only shortcut for
  balance testing; "[DEV] Chatuchak Ruins" / "[DEV] Klong Toey Canals"
  drop straight into districts 2/3 the same way, since there's no
  in-fiction travel between districts yet.
- **Real pixel art for all 105 classes** (not just the 15 F-rank
  starters) and all 24 monsters that actually appear across the three
  built districts (`assets/sprites/`), true 64×64 RGBA with 2-frame idle animation.
  E-through-S ranks aren't 90 hand-painted palettes — each family
  defines one base look (hair + a weapon or wraps, so no one's bald or
  empty-handed), and a rank-tier system (`tools/gen_sprites.py`)
  derives the rest via progressive color intensity, gear upgrades
  (pauldrons at C, a cape at B, a circlet at S), a glowing aura and
  forehead mark from C rank up, and — S rank only — a halo arc and two
  floating companion orbs, so the final evolution reads as a real apex
  tier. Uses each family's own accent color throughout so it stays
  family-distinct. Falls back to the original placeholder look for any
  monster beyond those 22.
- **All three built districts render as real tile-based maps with a
  scrolling camera**, not a flat colored grid: an original 64×64
  tileset (`tools/gen_tiles.py`, `assets/tiles/`) themed to our own
  flooded-Bangkok setting, plus a rebuilt HUD — a district
  name/description banner, a live minimap, HP/resource bars, deck
  count, and message log. The camera follows the player and clamps at
  the map's edges (or centers a district smaller than the screen), so a
  district is no longer limited to fitting on one screen. Any district
  without authored tile art (everything else right now) falls back to
  the original flat-grid look automatically.
- **Full story bible in GDD.md**: atmosphere, NPCs, puzzles, mini-boss/
  boss (with phases), and a narrative beat for every district and
  dimension, the 3-phase final boss, and three mutually exclusive
  endings.
- **Combat uses a JRPG-style action menu** (Cards / Item / Guard —
  Final Fantasy/Pokémon-style), not an always-visible hand. Guard grants
  block for free; usable consumables can be used mid-fight from the Item
  menu; both are free actions that don't end the turn. The layout is a
  fixed-height arena (portrait + name/HP + an HP bar per side), a fixed
  battle log, and a fixed-size scrolling card/item tray (a 2-column
  grid, so entries wrap instead of running off the right edge) — every
  panel has a known height, so nothing can grow unbounded and push
  End Turn off-screen. The project's stretch scale mode is `fractional`
  (not `integer`), so the full screen always letterboxes to fit a real
  device window instead of getting cropped at the edge on smaller
  screens.
- **The whole app has a real dark theme now, not stock Godot widgets** —
  main menu, overworld HUD, the status/items menu, and combat all share
  one `Theme` resource (`scripts/util/ui_theme.gd`'s `UITheme`, built
  once and reused rather than each scene re-deriving its own): bordered
  dark panels instead of flat default gray, HP bars colored per role
  (cyan player, rose enemy/danger, violet resource/mana), consistent
  button/label styling everywhere including nodes created at runtime
  (tray buttons, inventory buttons). Combat layers its own additions on
  top: every panel (arena, log, card tray) is a bordered dark
  PanelContainer, and mana is shown as filled/empty pips alongside the
  exact number. Damage/heal/
  block now spawn a floating number over the affected portrait and a
  brief screen-shake on hits — juice a static HP-bar tick alone doesn't
  give. **Enemies telegraph their next move** (Slay the Spire-style
  intent, icon + name + value) a full player turn in advance instead of
  attacking blind, re-rolling immediately if a mini-boss/boss stage
  transition swaps their move list mid-telegraph. Card borders are also
  tinted per type (action/spell/power), matching the existing icon
  tinting. Not ported: a real-time animated battle canvas (a different
  rendering architecture entirely) and new action-economy mechanics like
  a stagger gauge, a mana-generating basic attack, or a flee command —
  those are game-design calls, not a reskin.
- **Every card shows an icon for what it does**: seven small icons keyed
  to a card's effect (damage/heal/block/empower/lingering-damage/
  hits-everyone/execute), tinted red/blue/gold by its type
  (action/spell/power). Covers all 417 cards automatically — no
  per-card art needed (`tools/gen_card_icons.py`).
- **Status/Items menu** (press Escape from the overworld): portrait,
  name, rank, HP/resource bars, your full deck list with descriptions,
  and held items. No Equipment/Formation/Config/Save — those systems
  don't exist yet, so the menu doesn't pretend to have them.
- No class-selection UI, no inter-district travel/gating, no
  evolution-unlock engine yet. "Start Exploring" still only goes to
  Sukhumvit Shallows; Chatuchak Ruins and Klong Toey Canals are each
  reachable via their own "[DEV] <district>" main-menu shortcut (same
  pattern as "[DEV] Enter the Flood"), not through real in-fiction
  travel between districts. See GDD.md's roadmap section for the full,
  honest list.

## Opening the project

1. Install [Godot 4.3+](https://godotengine.org/download) (standard, not
   the .NET/Mono build — this project doesn't use C#).
2. Godot → Import → select this repo's `project.godot`.
3. Run the project (F5). It opens on the main menu. "Start Exploring"
   drops you into Sukhumvit Shallows (arrow keys to move, walk into a
   monster to fight it); "[DEV] Chatuchak Ruins" / "[DEV] Klong Toey
   Canals" drop you into districts 2/3 the same way; "[DEV] Enter the
   Flood" starts an isolated test
   battle as the Apprentice Mage.

This project was scaffolded without access to the Godot editor, so a
headless Godot 4.3 binary was used to verify it (`--import` to catch
parse errors, then scripted runs that play out full battles for all 105
classes, exercise every new combat mechanic, and drive the overworld
through real `change_scene_to_file` transitions — walking into a monster,
fighting it, and returning — to prove the whole loop actually works, not
just each piece in isolation). It has not been opened in the graphical
editor — if anything looks off visually, that's the first thing to check.

## Project structure

```
project.godot          # Engine config, autoloads, display/pixel-scaling settings
data/
  classes.json          # Class definitions (rank, hidden state, deck, evolution links)
  cards.json             # Card definitions (type, cost, effect, combo_tag)
  monsters.json           # Monster definitions (moves, stages, drop tables)
  items.json               # Item definitions (rarity, usable effect)
  districts.json             # District/dungeon/dimension grid layouts + spawn tables
assets/
  sprites/
    characters/           # mage_f_idle1/2.png - real 64x64 RGBA pixel art
    monsters/               # the 8 Sukhumvit Shallows monsters, same convention
scenes/
  main_menu.tscn
  overworld.tscn
  combat.tscn
scripts/
  autoload/
    game_data.gd          # Loads classes/cards/monsters/items/districts JSON at startup
    run_state.gd            # Bridges player/battle/exploration state across scene changes
  data/
    character_class.gd     # CharacterClass model
    card_data.gd             # CardData model
    monster_data.gd            # MonsterData model (moves, stages, drops)
    item_data.gd                 # ItemData model
    district_data.gd               # DistrictData model (grid layout, spawns)
  ui/
    main_menu.gd
  overworld/
    overworld.gd            # Grid movement, spawn/respawn, items, events
  combat/
    combat.gd                # Turn/combo engine + monster AI + UI (built in code)
    combatant.gd               # HP/resource/block/dot/moves/stages state
  util/
    sprite_loader.gd          # Loads generated art if it exists, else a colored-rect fallback
tools/
  gen_ranks.py            # Generator used to produce the D-S rank content (reference, not rerunnable as-is)
GDD.md                  # Design doc: world map, classes, combat, exploration system, roadmap
```

## Adding content

Classes, cards, monsters, items, and districts are all plain JSON — add
an entry to the relevant `data/*.json` file (pointing ids at each other
as needed: a class's `deck` at card ids, a district's `monster_spawns` at
monster ids, a monster's `drop_table` at item ids) and the `GameData`
autoload picks it up automatically. No code changes needed for new
content within the existing systems.
