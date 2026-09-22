# Deluge Chronicles — Game Design Document (Draft v0.1)

Working title only — rename freely. This doc exists so the ideas from the
initial brainstorm have one place to live and grow, instead of being
re-derived from scratch each session.

## Logline

A turn-based card RPG set in Bangkok, 2035, nine years after a mega-flood
drowned the surface and cracked open something that had been sealed in the
mountains and glaciers since before history. Science hit a wall; the
survivors who rebuilt among the flooded skyscrapers are the ones who learned
to wield what came out.

## World

- **2026**: Catastrophic mega-flooding hits Bangkok. The surface is lost;
  skyscrapers become the new "ground" — bridges, zip-lines, and flooded
  lower floors connect a vertical city.
- **The Release**: The flood breaks a seal in the mountains/glaciers,
  releasing mystic power and monsters into the world. Nobody agrees on what
  it is or where it came from — myth, forgotten physics, or something that
  was always there and only now has a way in.
- **2035 (present)**: Most of humanity survived and is rebuilding a new
  civilization *among* these new powers, not in spite of them. Conventional
  science has plateaued — it can't explain or fully control the new forces,
  so society is a mix of scavenged tech, old science, and raw,
  half-understood power wielded by "awakened" individuals.
- **Tone touchstone**: recent hunter/awakening manhwa (Solo Leveling-style
  power fantasy) crossed with climate-collapse sci-fi. Mystery and
  discovery are a core feeling, not just flavor text.
- **The goal**: this is a save-the-world RPG, not an endless roguelike
  grind — see World Map below for how districts, dungeons, and the ten
  "extra dimensions" (unlocked step by step) build toward a literal
  climax at the source of the 2026 catastrophe.

## World Map

Three tiers of location, roughly escalating in danger and strangeness:

- **12 districts** — the flooded city itself. Grounded, explorable,
  low-to-mid danger, each with its own small monster ecosystem. This is
  where most class-evolution hooks live (see the Roster table above —
  Klong Toey Canals *is* where the Hunter finds the crocodile that makes
  them a Crocodile Warden, etc.), so districts double as both
  exploration content and the "environmental accident" discovery sites
  the class system needs.
- **10 dungeons** — harder, optional, better rewards. Instanced,
  thematically tied to a specific class family's mythology rather than
  to city geography, and a few are explicitly where a family's *later*
  evolutions (B rank and up) get proven or unlocked.
- **10 dimensions** — "beyond human sense," unlocked one at a time as
  the story progresses. Not places on the map so much as concepts made
  physical (time, debt, memory, sound, identity...). Even an S-rank
  avatar is meant to struggle here without real preparation — this is
  endgame content, and the tenth dimension is the literal source of the
  Release: the game's actual final destination.

Only **Sukhumvit Shallows** (district 1) is fully built right now — real
grid, real monsters, real mini-boss/boss with stage transitions, real
items and an event (see Exploration & Encounter System and Prototype
status below). Everything else in this section is a content *plan*,
following the exact same data shape (`DistrictData`/`MonsterData`), not
yet written to `data/districts.json`.

### Districts (1 built, 11 designed)

| # | District | Tier | Ecosystem / hook |
|---|---|---|---|
| 1 | **Sukhumvit Shallows** *(built)* | F | Flood rats, leeches, drowned strays, toads, wisps; mini-boss/boss are the "source" that bred the rest — see Prototype status |
| 2 | Chatuchak Ruins | F-E | Collapsed weekend market turned scavenger maze — market-dogs, stall-wraiths, trickster spirits |
| 3 | Klong Toey Canals | E | The Hunter's territory — crocodilians, canal eels, drowned dockworkers (Crocodile Warden's discovery site) |
| 4 | Wat Hualamphong Depths | E | The Necromancer's flooded temple basement — restless dead, bone-creatures, drowned monks (Bone Tide Necromancer's site) |
| 5 | Ratchaprasong Intersection | E-D | The Tank's shrine — stone-guardian remnants, riot-echo constructs, crowd-crush phantoms (Erawan Guardian's site) |
| 6 | Thonburi Drowned Temples | D | Guardian statues and spirit houses — temple spirits, vengeful stonework, Kuman Thong (Yaksha Blade + Kuman Thong Warden's shared site) |
| 7 | Rama IV Fuel Depots | D | The Pyromancer's origin — fire-touched mutants, combustion elementals (Garuda Ember Knight's site) |
| 8 | Skybridge Network | D-C | The Ranger's vertical territory — aerial predators, wind spirits, rooftop nomads (Hanuman-Blessed Ranger's site) |
| 9 | Bang Rak Underlevels | C | The Berserker's fight pits — pit-bred monsters, demon-touched brawlers (Rakshasa Fury's site) |
| 10 | The Drowned University | C-B | The Mage's original school — arcane escapees, naga broodlings, flooded-library horrors (Naga Mage's site, the very first lore hook) |
| 11 | Refugee Tower Cluster | C | The Healer's territory — plague-wraiths, survivors turned monstrous, ancestor-guardians; morally messier than the others, since it's inhabited, not just infested |
| 12 | The Grand Palace Shallows | B | Highest-tier district; royal/Garuda-adjacent mythic remnants — the first real sign that "something ancient is waking up," and the gateway toward dungeons |

### Dungeons (0 built, 10 designed)

| # | Dungeon | Tier | Hook |
|---|---|---|---|
| 1 | The Flooded Subway Line | D | Linear, claustrophobic collapsed BTS tunnels — blind cave-mutants, echo-hunters |
| 2 | The Sunken Cinema | D-C | A preserved theater; illusion-weaving spirits replay old films as traps |
| 3 | The Vertical Vault | C | A bank tower's vault floors — greed-touched guardian constructs, lock-puzzle mini-bosses |
| 4 | The Coiling Temple | C | A naga-worship temple — proving ground for the Mage → Naga Avatar chain |
| 5 | The Rakshasa's Arena | C-B | A literal demon-king's arena, gauntlet structure — Berserker chain's proving ground |
| 6 | The Garuda Spire | B | A half-collapsed skyscraper climbed floor by floor, fire/wind themed — Pyromancer/Ranger chains |
| 7 | The Hanging Gardens of Kuman Thong | B | A rooftop garden full of bonded child-spirits; heavier, grief-themed tone |
| 8 | The Court of the Drowned King | B-A | Necromancer endgame — a literal underworld court, Drowned King Avatar's proving ground |
| 9 | The Yaksha Vault | A | A sealed treasury guarded by a sequence of yaksha guardians; the game's best gear |
| 10 | The Erawan Bastion | A | The hardest dungeon: a three-headed fortress (architecture mirrors the myth), last proving ground before the dimensions |

### Dimensions (0 built, 10 designed, unlocked in order)

| # | Dimension | Concept | Hook |
|---|---|---|---|
| 1 | The Static Between Seconds | Time | Frozen/glitching moments; Psychic/Resonant chain's true test |
| 2 | The Weight of What's Owed | Gravity ↔ guilt | Gravity responds to karmic debt |
| 3 | The Unheard Frequency | Sound/signal | Pure broadcast-space; Bard/Signal chain's true test |
| 4 | The Space Between Names | Identity | Existential, disorienting — you can lose track of which class you are |
| 5 | The Undertow of Memory | Collective memory | Built from the flood's drowned recollections |
| 6 | The Marrow Depths | Structure | Literally beneath reality's "skeleton" — Necromancer-adjacent |
| 7 | The Mirror Current | Alternate choice | Reflects evolution paths *not* taken — a look at who you could have become |
| 8 | The Yantra Lattice | Sacred geometry | Reality organized as living sak yant ink — Monk chain's true test |
| 9 | The Court Beyond Court | Myth-above-myth | Where Naga/Garuda/Yaksha/etc. avatars answer to something bigger than themselves |
| 10 | The Source of the Release | Origin | The literal origin point of the 2026 catastrophe — the game's ending |

## Class System

- **Ranks**: F → E → D → C → B → A → S. Rank is a measure of power, not
  necessarily "how good the class is to play" — an F-rank class can be a
  complete, viable playstyle on its own; rank mostly gates raw stats and
  unlocks new evolution branches.
- **Evolution, not a skill tree**: a class evolves into a specific next
  class (e.g. `mage_f` → `naga_mage_e`), not a generic "pick a talent"
  system. Evolutions are discovered, not chosen from a menu: an NPC quest,
  an environmental accident, a specific choice in a specific location.
  Example already decided: an Apprentice Mage who falls into the river
  near the old mage school (rather than choosing to) becomes a Naga Mage.
- **Everything starts hidden.** This was explicit in the original brief:
  *even the first class is mysterious.* In data terms every
  `CharacterClass` has `is_hidden = true` and a `locked_description` (a
  cryptic in-world rumor) until discovered; only then does
  `unlocked_description` and the real name become visible to the player.
  The current prototype's main menu already reflects this — the class
  codex shows "???" for every entry.
- **Distinct playstyles by card-type bias, not bespoke mechanics per
  class.** Rather than hand-coding unique systems per class, each class's
  starting deck is skewed toward one card type (see Combat System below),
  which — combined with the shared combo system — naturally produces a
  different feel: the Mage's deck is mostly Spell, so Mage games are
  spell-chain focused; the Hunter's deck is mostly Action, so Hunter games
  are about stringing physical hits. This keeps the system scalable to
  many classes without an explosion of special-case code, while still
  leaving room for a class to break the pattern later (e.g. a class whose
  gimmick *is* mixing types).

### Roster (v0.3 — 15 class families, each a full F→S evolution chain)

All 105 entries (15 families × 7 ranks: F, E, D, C, B, A, S) are
implemented in `data/classes.json` / `data/cards.json` and have been
battle-tested (see Prototype status below). Each family evolves through
one continuous chain rather than branching, anchored to a Thai myth or
Bangkok place so it doesn't read as a generic fantasy reskin — Naga,
Yaksha, Erawan, Garuda, Hanuman, and Kuman Thong are figures most players
with any exposure to Thai culture will recognize. Every family's naming
follows the same escalation pattern end to end: F/E establish the base
identity (see the original 30-class table below), D/C refine and fuse it
with the myth, B is a `Half-<Anchor>` transformation, A is `Eternal
<Domain> <Anchor>`, and S is a full `<Anchor> Avatar` — the character
*becomes* the myth they started out surviving an encounter with.

| Family (anchor) | F/E identity | D | C | B | A | S |
|---|---|---|---|---|---|---|
| Mage (Naga) | Apprentice Mage → Naga Mage | Tide-Marked Sorcerer | Naga-Fang Mage | Half-Naga Warlock | Eternal Tide Naga | Naga Avatar |
| Hunter (Crocodile) | Rookie Hunter → Crocodile Warden | Canal Stalker | Crocodile-Fang Hunter | Half-Crocodile Ravager | Eternal Canal Predator | Crocodile Avatar |
| Healer (Ancestors) | Field Medic → Ancestral Medium | Ancestor-Touched Adept | Spirit-Bound Medium | Half-Ancestor Oracle | Eternal Vigil Medium | Ancestor Avatar |
| Necromancer (Bone Tide) | Grave-Diver → Bone Tide Necromancer | Deep Bone Warden | Drowned-Bone Necromancer | Half-Drowned Lich | Eternal Tide Lich | Drowned King Avatar |
| Assassin (Yaksha) | Alley Ghost → Yaksha Blade | Temple-Marked Blade | Yaksha-Fang Assassin | Half-Yaksha Reaver | Eternal Guardian Blade | Yaksha Avatar |
| Tank (Erawan) | Riot Warden → Erawan Guardian | Threefold Bulwark | Erawan-Bound Warden | Half-Erawan Colossus | Eternal Threefold Guardian | Erawan Avatar |
| Berserker (Rakshasa) | Scrap Brawler → Rakshasa Fury | Demon-Marked Brawler | Rakshasa-Fanged Berserker | Half-Rakshasa Ravager | Eternal Demon-King Fury | Rakshasa Avatar |
| Summoner (Kuman Thong) | Spirit-House Keeper → Kuman Thong Warden | Bonded Warden | Kuman-Marked Summoner | Half-Spirit Conjurer | Eternal Bond Warden | Kuman Thong Avatar |
| Pyromancer (Garuda) | Ember Diver → Garuda Ember Knight | Solar-Marked Pyromancer | Garuda-Wing Pyromancer | Half-Garuda Flamebearer | Eternal Sunfire Knight | Garuda Avatar |
| Ranger (Hanuman) | Skybridge Scout → Hanuman-Blessed Ranger | Windrunning Adept | Hanuman-Marked Ranger | Half-Hanuman Skyrunner | Eternal Windstep Ranger | Hanuman Avatar |
| Monk (Sak Yant) | Klong-side Boxer → Sak Yant Adept | Yantra-Bound Fighter | Sacred-Ink Adept | Half-Spirit Yantra Warrior | Eternal Yantra Master | Yantra Avatar |
| Alchemist (Current) | Salvage Chemist → Mutagen Alchemist | Current-Touched Alchemist | Catalyst-Bound Chemist | Half-Mutated Alchemist | Eternal Catalyst Alchemist | Current Avatar |
| Psychic (Resonance) | Static Touched → Resonant | Deep Resonant Adept | Current-Bound Psychic | Half-Resonant Oracle | Eternal Resonance Adept | Resonance Avatar |
| Exorcist (Boundary) | Novice Exorcist → Khru of the Drowned | Boundary-Marked Khru | Spirit-Bound Exorcist | Half-Spirit Khru | Eternal Boundary Khru | Boundary Avatar |
| Bard (Signal) | Signal Ghost → Broadcast Wraith | Deep Signal Adept | Frequency-Bound Wraith | Half-Signal Herald | Eternal Broadcast Herald | Signal Avatar |

Full flavor text (locked rumor at F rank, "???" at every rank after until
discovered, unlocked lore, playstyle blurb) lives in `data/classes.json`
— this table is just an index.

**Mechanical rank breakpoints.** Every rank has the base kit (damage /
heal / block / empower_next), but three ranks each introduce one new card
effect that every family gains a signature card for, so later ranks feel
like a real step up rather than the same kit with bigger numbers (see
Combat System below for what each effect does):
- **D rank**: a `dot` card — the power now lingers after the hit.
- **B rank**: an `aoe_damage` card — the power now radiates outward.
- **S rank**: an `execute` card — a signature finisher, the class's one
  true "ultimate."
- **C rank** has no new mechanic, but is the one rank where the deck
  composition itself shifts to roughly split between the class's primary
  and secondary card type — the "fusion" step, mechanically as well as
  narratively.
- **A rank** also has no new mechanic; it's a pure mastery breakpoint
  (bigger numbers across the board) between the C-rank fusion and the
  S-rank avatar transformation.

Stat growth (HP, resource pool, and card values for D through S) is
computed per rank from each family's own F/E baseline rather than
hand-tuned per class, so relative archetype identity holds all the way up
(e.g. the Tank stays the tankiest family at every rank). The formulas
(rank multipliers, HP-tier increments, resource-per-rank table) and the
per-family flavor data live in `tools/gen_ranks.py`, kept as a reference
for the design intent behind the numbers. It currently only appends new
content and asserts on duplicate IDs, so it is *not* safe to rerun as-is
against the current `data/*.json` — reusing it for a rebalance pass would
need a small change to overwrite existing entries instead of asserting
against them.

## Combat System

Card-based, turn-based, one player character vs. one or more enemies.

- **Card types**: `action`, `spell`, `power` — mirrors the brief's
  "action / spell / power" almost exactly, and is deliberately close to
  Slay the Spire's Attack/Skill/Power taxonomy, a proven pattern for this
  kind of game.
  - **Action**: direct, resource-cheap effects — typically damage.
  - **Spell**: the caster kit — damage, healing, and other resource-paid
    effects.
  - **Power**: setup cards — block, buffs, "empower the next card played."
- **Resource**: each class has its own named resource (Mana, Stamina,
  Faith, Tide, ...) that refills each turn and grows with rank (F=3 up to
  S=7). This is deliberately just a reskinned mana pool for now;
  class-specific resource *mechanics* (e.g. a resource that carries over,
  or costs HP) are a Phase 2 idea.
- **Deck / hand / discard loop**: each battle shuffles the class's deck
  into a draw pile, draws a hand each turn, discards played and
  end-of-turn leftover cards, and reshuffles the discard pile back in when
  the draw pile empties. Standard deckbuilder-roguelike structure.
  - **Combo system**: playing cards with the same `combo_tag`
    back-to-back stacks a counter that scales that card's value
    (currently +20% per consecutive same-tag card). This is the "combo"
    the brief asked for, implemented generically so every class gets it
    for free, biased by their deck's card-type mix.
- **Rank-gated mechanics** (added alongside the D-S rank content): three
  more card effects beyond the base kit, each targeting the enemy roster
  (`combat.gd`'s `enemies: Array[Combatant]`, always length 1 in the
  current single-enemy prototype, but real multi-target logic):
  - `dot` (D rank+): applies stacking lingering damage that **bypasses
    block** (`Combatant.apply_dot` / `tick_dot`) and ticks down (halving)
    at the start of the affected creature's next turn.
  - `aoe_damage` (B rank+): hits every living enemy for the card's value.
    In the current single-enemy encounter this behaves identically to
    `damage`; it's real multi-target logic waiting on multi-enemy
    encounters to matter (see Roadmap).
  - `execute` (S rank+): deals double damage if the target is at or below
    50% of its max HP — every class's signature "ultimate," gated to one
    card per class, cost 2.
  All three respect the same combo multiplier as `damage`/`heal`.

## Exploration & Encounter System

How districts/dungeons/dimensions actually work, built alongside
Sukhumvit Shallows as the vertical slice.

- **Grid overworld, not free movement.** Each location is a fixed-size
  grid (`DistrictData.grid_width/height`) with per-cell blocked/walkable
  state, walked one cell at a time (arrow keys). There's no hand-authored
  Godot TileMap/TileSet resource — that format is intricate enough that
  writing it by hand without the editor's visual tool would be a real
  correctness risk, so the grid is plain `ColorRect` cells positioned by
  a script instead. Functionally identical for a prototype; swapping in
  real tile art later doesn't touch the movement/collision logic.
- **RunState autoload bridges Overworld ↔ Combat.** Godot's
  `change_scene_to_file()` destroys the old scene tree, so anything that
  must survive a fight — the player's `Combatant` (HP carries between
  encounters; only resource/block/combo reset per battle, same as
  always), which district/spawn triggered it, and all per-district
  exploration progress (which spawns are dead-and-respawning vs.
  permanently gone, which items are collected, which events have fired)
  — lives on `RunState` instead of as a direct object reference.
- **Monsters are data now, not hardcoded.** `MonsterData` (loaded from
  `data/monsters.json`) replaces the old hardcoded "Flooded Ghoul": each
  monster has a weighted move list (AI picks one per turn) using the
  *exact same six effects* as player cards — a monster's "dot" or
  "execute" move resolves through the same code path, just with
  attacker/target swapped (`combat.gd`'s `_apply_monster_move`).
- **Multi-stage mini-bosses/bosses.** `MonsterData.stages` is an ordered
  list of `{trigger_hp_pct, display_name, moves, transition_text}`.
  Crossing a threshold swaps the active move list (and name) and logs
  the transition — checked in a loop each enemy turn, so a huge hit can't
  let a boss skip a phase. This is how "boss/mini-boss can have many
  stages" from the brief is implemented; Sukhumvit Shallows' boss has 3,
  its mini-boss has 2, and there's no cap on adding more per monster.
  Only bosses/mini-bosses use `aoe_damage`/`execute` in the district-1
  moveset design, kept as their "phase 2/3 feels different" tool.
- **Fixed spawns, real respawn timers, permanent bosses.** Regular
  monster spawn points respawn `respawn_seconds` after being cleared
  (`RunState`'s per-district `defeated_spawns` map stores an absolute
  respawn timestamp, checked both on scene load and every frame via
  `_check_respawns` so it fires even if the player just stands around).
  Mini-bosses and bosses are flagged permanently dead (`-1`) instead —
  this is the "number of monsters is fixed... except mini and boss"
  requirement from the brief. A *lost* fight doesn't clear or respawn
  anything; the player just recovers to 50% HP back at the overworld
  (no permadeath — consistent with the still-open roguelike-vs-persistent
  question below).
- **Items are simple by design** (`ItemData`): a rarity, a description,
  and an optional `effect` (`heal` or `restore_resource`) + `value`. No
  equipment/inventory-slots system yet — just a collected-count per item
  id on `RunState.inventory`, with a "Use" button in the overworld UI for
  anything with an effect. Monsters roll drops from their
  `drop_table` on death; districts can also place items directly on the
  map as pickups.
- **Events** are just a cell + text (+ `repeatable` flag) that logs a
  line when stepped on — no dialogue system, just environmental
  storytelling for now (Sukhumvit Shallows has one: a wall message
  hinting at the mage school).

## Prototype status (current build)

What exists right now, in `scenes/`, `scripts/`, and `data/`:

- A **data-driven** class/card pipeline: `data/classes.json` and
  `data/cards.json` are loaded at runtime by the `GameData` autoload —
  add a class or card by editing JSON, no code changes required.
- A **main menu** (`scenes/main_menu.tscn`) with two entry points: "Start
  Exploring" begins a real run (`RunState.begin_run`) as the Apprentice
  Mage and drops into Sukhumvit Shallows; "[DEV] Enter the Flood" is the
  original isolated-combat shortcut, kept for quick balance testing. The
  class codex now shows a count ("X of 105 known classes are still
  unresolved rumors") rather than one "???" line per class, since one
  line each stopped being readable at this roster size.
- A **fully playable district** (`scenes/overworld.tscn` /
  `scripts/overworld/overworld.gd`): Sukhumvit Shallows, grid movement,
  6 regular monster spawns (5 species) that respawn on a timer, a
  2-stage mini-boss and a 3-stage boss that are permanently removed once
  beaten, 2 item pickups + monster loot drops feeding a simple inventory
  with a usable healing item, and one environmental event. Walking into
  a live monster transitions into...
- **Combat** (`scenes/combat.tscn` / `scripts/combat/combat.gd`): the
  deck/hand/discard loop, resource costs, block, healing, empower-next,
  combo multiplier, plus monster AI (weighted move lists) and multi-stage
  boss transitions (see Exploration & Encounter System above). When
  entered from the overworld, the player's HP/state persists via
  `RunState` rather than resetting each fight; the standalone "[DEV]"
  shortcut still works too, defaulting to a fresh Apprentice Mage vs. the
  placeholder Flooded Ghoul (now itself a `MonsterData` entry, not
  hardcoded).
- **JRPG-style action menu, not an always-open hand.** Turn input is a
  Final Fantasy/Pokémon-style main menu (`Cards` / `Item` / `Guard`)
  rather than dumping the full hand on screen at once — `menu_state`
  (`"main"` / `"cards"` / `"items"`) gates which sub-panel is visible.
  `Cards` reveals the existing hand/discard system unchanged; `Guard`
  is a new free action (`_on_guard_pressed`) that grants flat block
  (`GUARD_BLOCK = 3`), resets the combo streak, and — like using an
  item — does **not** end the turn, consistent with the existing
  "multiple actions per turn, resource-permitting" design; `Item`
  lists usable consumables from `RunState.inventory` (heal /
  restore_resource effects only) and auto-closes back to `"main"` once
  the last one of a kind is consumed. The Item button disables itself
  when nothing usable is held. This replaced an earlier layout where
  the hand row and a newly-added portrait row were both always on
  screen at once, which on the original 480×270 viewport pushed
  `end_turn_button` off the visible area entirely (the "can't combat"
  bug — the UI wasn't broken, it was just rendering below the fold).
- **Fixed-height combat layout, not size-to-content.** Every panel in
  `combat.gd`'s `_build_ui()` — the arena, the log, the card/item tray —
  has a constant height; nothing uses `SIZE_EXPAND_FILL` to soak up
  leftover space or a plain `HBoxContainer` that grows without bound.
  The arena shows both combatants side by side with a portrait, a
  name/HP readout, and a `ProgressBar` HP bar each (closer to the
  Final Fantasy/Pokémon reference the player asked for than plain text
  status lines). The card/item tray is a 2-column `GridContainer`
  inside a fixed-size `ScrollContainer` — cards wrap to a new row
  instead of running off the right edge (the original bug report:
  cards "hard to read" and getting clipped), and if a future roster of
  items ever needs more rows than fit, it scrolls instead of pushing
  `end_turn_button` off-screen again. Each tray entry is a `Button`
  wrapping real `Label`s with `autowrap_mode` set, not the button's own
  text, so long descriptions word-wrap instead of overflowing — Godot's
  `Button` doesn't wrap its own `text` property. Headlessly verified:
  every visible control's global rect stays within the viewport bounds
  in the closed-menu, cards-open, and items-open states, with real
  pixel slack (not a zero-margin fit), including a stress case of
  more usable items than fit in one row.
- **105 classes fully defined and battle-tested** (15 families × F
  through S rank, see Roster below) — every one was run through a full
  headless combat simulation with zero errors and reaches victory. Turn
  counts drop monotonically by rank against the placeholder enemy (F rank
  averages ~4 turns, S rank ~1) since the single "Flooded Ghoul" doesn't
  scale with the player — expected given there's only one enemy in the
  game right now (see below), not a balance claim about rank power
  relative to *real* future encounters. No class-selection UI exists yet
  to pick between them in a real playthrough — a run always starts as
  the F-rank Apprentice Mage.
- **All of Exploration & Encounter System above is real and headlessly
  validated**, not just designed: targeted tests proved grid
  bounds/wall collision, item pickup (and no double-pickup), non-repeatable
  event firing, consumable use, victory vs. defeat handling (respawn
  timer vs. permanent boss removal vs. "nothing happens on a loss"), and
  mid-session respawn ticking, on top of a genuine end-to-end run through
  real `change_scene_to_file` transitions (menu-style start → overworld →
  walk into a monster → real scene change to combat → win → real scene
  change back → the fresh overworld correctly shows the spawn on cooldown).
- **Real pixel art for Sukhumvit Shallows' cast.** The Apprentice Mage and
  all 8 monsters that actually appear in the game (Flooded Ghoul plus the
  district's 5 mobs, mini-boss, and boss) have true 32×32 RGBA sprites in
  `assets/sprites/` — every pixel is an explicit color choice (region-fill
  generation, not an AI image model), so hard edges and real alpha
  transparency are guaranteed, not hoped for. Humanoid faces (Apprentice
  Mage, Flooded Ghoul) have explicit eye pixels, not blank skin-colored
  ovals. Each has a 2-frame idle animation. `scripts/util/sprite_loader.gd`
  renders them as
  `AnimatedSprite2D` in the overworld and as animated portraits in
  combat, and **falls back to the original colored-rectangle/text-only
  look for any id without art** — which is still 96+ of the 105 classes
  and all but 8 monsters, so that fallback path is the common case, not
  an edge case, and must keep working as more content is added.
- **Tile-based overworld rendering, piloted on Sukhumvit Shallows.**
  `tools/gen_tiles.py` generates an original 40×40 tileset
  (`assets/tiles/flood_tileset.png`: shallow water, deep water, wet
  pavement, rubble — same region-fill/real-alpha principle as the
  character generator, themed to *our* flooded Bangkok, not copied from
  any reference game's tile graphics) that `scripts/util/tile_loader.gd`
  turns into a real Godot `TileSet`/`TileMap`. A district opts in with a
  new `terrain` field (`DistrictData.terrain` — one legend string per
  row, purely cosmetic; collision always comes from `blocked_cells`
  regardless of the terrain character underneath). No `terrain` data
  (every one of the other 31 districts/dungeons/dimensions right now)
  falls back to the original flat colored-rect grid — same "safe
  fallback for content that hasn't been authored yet" pattern as
  sprites. The overworld HUD was rebuilt to match: a district
  name/description banner and a small live minimap (dot-grid, player
  marker, red mini-boss/boss markers while they're still up) top, an
  HP/resource bar readout, deck-size counter, message log, and inventory
  row bottom. `CELL_SIZE` grew 24→40 and the grid's screen position is
  now computed per-district (centered horizontally, anchored under the
  banner) rather than a fixed offset. **Known gap: no camera/scroll
  system yet** — a district's grid must fit entirely within the
  480×460 viewport minus the HUD bands (Sukhumvit Shallows' 10×8 does;
  a bigger district won't) — solving that comes before giving the other
  31 locations tile art. Headlessly verified: the tile-rendering path,
  the flat-grid fallback path, every HUD element's on-screen bounds, and
  that movement/encounters/item pickup are unaffected, on top of the
  existing overworld↔combat end-to-end flow.
- **Status/Items menu (Escape, from the overworld).**
  `scripts/menu/status_menu.gd` — a portrait, name, rank, HP/resource
  bars, and two tabs: Status (playstyle blurb + the full deck list with
  costs/descriptions, not shown anywhere else) and Items (held
  consumables). Deliberately has no Equipment/Formation/Config/Save
  commands like a typical FF-style menu — none of those systems exist
  yet (no equipment slots, no party, no settings, no save/load), and per
  the project's own conventions a menu command that does nothing is
  worse than no command. It's an overlay on the overworld scene (not a
  scene change), so opening/closing it can't disturb spawn/respawn
  state; movement input is guarded off while it's open.
- **No real unlock/evolution engine yet** — `evolves_to`,
  `evolution_hint`, and `unlock_type` exist as data fields, but nothing
  reads them yet to actually trigger a class change in-game.
- The project targets Godot 4.3+ (GL Compatibility renderer, pixel
  viewport at 480x460 — chosen for broad device/browser support), which
  exports to desktop, mobile, and web from one project. The viewport
  height grew from an original 270 to fit the combat screen's portrait
  row, log, and action menu without clipping (see the fixed-height
  combat layout note above). `window/stretch/scale_mode` is
  **`fractional`**, not `integer` — integer scale mode cannot scale
  below 1x, so on a real device/browser window smaller than 480×460 the
  content was getting cropped at the window edge instead of being
  letterboxed down to fit (this is the likely cause of "characters and
  enemies fly off screen" reported from real device testing — a device
  viewport narrower or shorter than the design resolution, not a layout
  bug per se). Fractional scaling always fits the full 480×460 canvas
  into whatever window is available (`window/stretch/aspect="keep"`
  preserves the aspect ratio via letterboxing rather than distorting
  it), at the cost of pixel art occasionally scaling to a non-integer
  ratio instead of always landing on a crisp 2x/3x — an intentional
  trade favoring "never cropped" over "always pixel-perfect" while the
  game is still being tested across unpredictable device sizes.

## Roadmap / Phase 2 ideas (not built)

- **The other 31 zones.** Only Sukhumvit Shallows is real; the other 11
  districts, all 10 dungeons, and all 10 dimensions are designed (World
  Map above) but have zero entries in `data/districts.json` /
  `data/monsters.json`. Filling these in is now mostly content work,
  following the exact pattern Sukhumvit Shallows already proved out
  (content + `terrain` tile art, now that the tile-rendering pilot is
  real). The full spawn-to-final-boss order is: the 12 districts in
  tier order, then the 10 dimensions in their documented order ending
  at *The Source of the Release* (the literal final boss); the 10
  dungeons are optional side content, not on the critical path.
- **Overworld camera/scroll system.** The tile-based renderer has no
  camera follow or viewport culling yet, so a district's grid must fit
  entirely on screen — fine for Sukhumvit Shallows (10×8), not for
  anything bigger. Needed before most of the other 31 locations can get
  real tile art.
- **Inter-zone progression/gating.** Right now the overworld only knows
  about one district; there's no world-map screen to travel between
  districts, no unlock gate stopping an F-rank player from walking into
  a B-rank district, and no logic tying dimension access to "unlocked
  step by step" story progress (per the brief). This is the main
  structural piece standing between "one working district" and "an
  actual game you play through."
- A data-driven "unlock condition" system (quest flag, item found,
  location + trigger) that reads `unlock_type` / `evolution_hint` and
  flips `is_hidden` / performs the class evolution — the *class* side of
  this is still unbuilt even though the *district* side (RunState's
  per-district event/item/spawn state) now has a working pattern it
  could plausibly reuse.
- NPC dialogue system for quest-given unlocks.
- A class-selection scene (pick from unlocked classes rather than every
  run hardcoding "mage_f").
- Enemy variety *within* a district beyond what Sukhumvit Shallows
  already has, and multi-enemy encounters (`aoe_damage` currently only
  ever hits one enemy in practice, since every encounter in the built
  content is 1-monster).
- A second evolution *branch* per family (right now each of the 15 chains
  is fully linear, one path F straight through to S; the original brief's
  "don't know how, maybe multiple paths" idea for branching evolutions
  isn't built).
- Art for everything outside Sukhumvit Shallows' 9 sprites: the other 14
  class families (and every non-F/E rank of all 15), monster/item icons
  for the other 31 planned districts/dungeons/dimensions, a real tileset
  for the overworld ground (currently plain `ColorRect`s — only the
  characters standing on it have real art now), and general UI skinning.
- Meta-progression / save system between runs — right now all state
  (`RunState`) lives in memory only and is lost when the game closes.
- Class-specific mechanical hooks beyond the shared combo system (e.g. the
  Naga Mage paying costs in HP instead of Tide, per its original pitch).

## Open questions for the project owner

- Working title — keep "Deluge Chronicles" or replace it?
- Run structure: is this a roguelike (per-run deck, permadeath-ish) like
  Slay the Spire, or a persistent RPG party you keep leveling? This
  changes a lot of downstream design (meta-progression, party size,
  overworld structure) and hasn't been decided yet.
- Which of the 15 classes (if any) should be the *actual* guaranteed
  starting class vs. purely accident-discovered, and whether the roster
  should grow further or this is enough for a first playable slice.
- How should players travel *between* districts — a literal world map
  screen, unlocked bridges/routes on the districts themselves, or
  something else? And what actually gates access to higher-tier
  districts/dungeons/dimensions (player rank? a story flag? both)?
