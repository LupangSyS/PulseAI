# Deluge Chronicles (working title)

A turn-based card RPG built in [Godot 4](https://godotengine.org/) (4.3+).
Set in Bangkok, 2035 — nine years after a mega-flood drowned the surface
and released mystic power and monsters sealed since before history.
Players take on hidden, evolvable RPG classes (F-rank to S-rank) discovered
through exploration and quests rather than picked from a menu.

This repo previously hosted a different, unrelated project (a news/stocks
dashboard). That project has been retired; everything here now is the game.

Full design context — world setting, class system, combat system, and
what's built vs. still on the roadmap — lives in **[GDD.md](GDD.md)**.
Read that first.

## Status

Early prototype. What currently exists:

- A data-driven class/card system (`data/classes.json`, `data/cards.json`)
  loaded at runtime by the `GameData` autoload.
- **30 classes** (15 base + 15 evolutions) fully defined with lore,
  stats, and decks — see GDD.md's roster table for the full list.
- A main menu that lists every class as "???" (all classes start hidden
  by design) with a developer shortcut into a test battle.
- A single playable combat encounter demonstrating the deck/hand/discard
  loop, the Action/Spell/Power card system, and the combo mechanic. It's
  hardcoded to start as the Apprentice Mage; there's no class-picker UI
  yet.
- No art yet, no unlock/evolution engine yet, no class-selection UI yet
  — see GDD.md's roadmap section.

## Opening the project

1. Install [Godot 4.3+](https://godotengine.org/download) (standard, not
   the .NET/Mono build — this project doesn't use C#).
2. Godot → Import → select this repo's `project.godot`.
3. Run the project (F5). It opens on the main menu; the "[DEV] Enter the
   Flood" button starts a test battle as the Apprentice Mage.

This project was scaffolded without access to the Godot editor, so a
headless Godot 4.3 binary was used to verify it (`--import` to catch
parse errors, then a scripted run that plays out a full battle for all
30 classes). It has not been opened in the graphical editor — if
anything looks off visually, that's the first thing to check.

## Project structure

```
project.godot          # Engine config, autoloads, display/pixel-scaling settings
data/
  classes.json          # Class definitions (rank, hidden state, deck, evolution links)
  cards.json             # Card definitions (type, cost, effect, combo_tag)
scenes/
  main_menu.tscn
  combat.tscn
scripts/
  autoload/
    game_data.gd          # Loads classes.json/cards.json at startup
  data/
    character_class.gd     # CharacterClass model
    card_data.gd             # CardData model
  ui/
    main_menu.gd
  combat/
    combat.gd                # Turn/combo engine + UI (built in code, no hand-authored layout)
    combatant.gd               # HP/resource/block state
GDD.md                  # Design doc: world, classes, combat system, roadmap, open questions
```

## Adding content

Classes and cards are plain JSON — add a class by adding an object to
`data/classes.json` (and pointing its `deck` at card ids), and add cards
the same way in `data/cards.json`. No code changes needed for new
content; the `GameData` autoload picks them up automatically.
