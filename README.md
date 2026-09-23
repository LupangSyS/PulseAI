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
- **A real, explorable district** — Sukhumvit Shallows: grid movement,
  6 respawning monster spawns (5 species), a 2-stage mini-boss (**The
  Neon Strangler**) and a 3-stage boss (**Phra Khanong Mother**, Mae Nak
  reflected) that are permanently removed once beaten, item pickups +
  monster loot, and 9 events — two revisitable NPCs (Uncle Somchai,
  Sister Da), two landmark flavor beats, a narrative reveal, and the
  **Breaker Pump Protocol**: a real sequential 3-step puzzle (attempting
  a step out of order fails it without consuming it, so it can't
  softlock) that pays out a reward item on completion. Walking into a monster
  transitions into a real combat encounter and back. 11 more districts,
  10 dungeons, and 10 "beyond human sense" dimensions are fully designed
  in GDD.md's World Map but not yet built as data.
- Monsters are now data-driven too (`data/monsters.json`) with weighted
  AI move lists and multi-stage boss/mini-boss transitions, using the
  same six card effects as the player (including the two newest,
  `dot`/`aoe_damage`/`execute`, all rank-gated D/B/S+).
- Main menu has two entry points: "Start Exploring" begins a real run and
  drops into Sukhumvit Shallows; "[DEV] Enter the Flood" is an isolated
  combat-only shortcut for balance testing.
- **Real pixel art for all 105 classes** (not just the 15 F-rank
  starters) and all 8 monsters that actually appear
  (`assets/sprites/`), true 64×64 RGBA with 2-frame idle animation.
  E-through-S ranks aren't 90 hand-painted palettes — each family
  defines one base look (hair + a weapon or wraps, so no one's bald or
  empty-handed), and a rank-tier system (`tools/gen_sprites.py`)
  derives the rest via progressive color intensity, gear upgrades
  (pauldrons at C, a cape at B, a circlet at S), a glowing aura and
  forehead mark from C rank up, and — S rank only — a halo arc and two
  floating companion orbs, so the final evolution reads as a real apex
  tier. Uses each family's own accent color throughout so it stays
  family-distinct. Falls back to the original placeholder look for any
  monster beyond Sukhumvit Shallows' 8.
- **Sukhumvit Shallows now renders as a real tile-based map with a
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
  evolution-unlock engine yet, no art beyond Sukhumvit Shallows' 9
  sprites — see GDD.md's roadmap section for the full, honest list.

## Opening the project

1. Install [Godot 4.3+](https://godotengine.org/download) (standard, not
   the .NET/Mono build — this project doesn't use C#).
2. Godot → Import → select this repo's `project.godot`.
3. Run the project (F5). It opens on the main menu. "Start Exploring"
   drops you into Sukhumvit Shallows (arrow keys to move, walk into a
   monster to fight it); "[DEV] Enter the Flood" starts an isolated test
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
