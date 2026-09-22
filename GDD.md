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
- **District hooks (seed ideas, not committed)**: flooded districts could
  each lean into a class family — a drowned temple district for
  water/naga magic, a collapsed BTS transit line for hunters, a refugee
  tower cluster for healers/faith classes, a submerged university for
  arcane mages. Useful for tying class discovery locations to the map
  later.

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

## Prototype status (current build)

What exists right now, in `scenes/`, `scripts/`, and `data/`:

- A **data-driven** class/card pipeline: `data/classes.json` and
  `data/cards.json` are loaded at runtime by the `GameData` autoload —
  add a class or card by editing JSON, no code changes required.
- A **main menu** (`scenes/main_menu.tscn`) that lists every class as
  "???" (since all are `is_hidden`) and has a developer-only button
  straight into a test battle.
- A **playable one-encounter combat prototype**
  (`scenes/combat.tscn` / `scripts/combat/combat.gd`): vs. a placeholder
  "Flooded Ghoul," demonstrating the deck/hand/discard loop, resource
  costs, block, healing, the empower-next Power card, and the combo
  multiplier. Hardcoded to start as the Apprentice Mage; swapping the
  class id in `_start_battle()` (or wiring up a class picker) is the
  natural next step.
- **105 classes fully defined and battle-tested** (15 families × F
  through S rank, see Roster below) — every one was run through a full
  headless combat simulation with zero errors and reaches victory. Turn
  counts drop monotonically by rank against the placeholder enemy (F rank
  averages ~4 turns, S rank ~1) since the single "Flooded Ghoul" doesn't
  scale with the player — expected given there's only one enemy in the
  game right now (see below), not a balance claim about rank power
  relative to *real* future encounters. No class-selection UI exists yet
  to pick between them in a real playthrough — the prototype scene still
  only starts as the F-rank Apprentice Mage.
- **No art yet** — pixel art was chosen as the target style, but the UI
  is currently built from plain Godot `Label`/`Button`/`RichTextLabel`
  nodes with no sprites, so the logic can be reviewed and iterated on
  without blocking on assets.
- **No real unlock/evolution engine yet** — `evolves_to`,
  `evolution_hint`, and `unlock_type` exist as data fields, but nothing
  reads them yet to actually trigger a class change in-game.
- The project targets Godot 4.3+ (GL Compatibility renderer, integer-scaled
  pixel viewport at 480x270 — chosen for broad device/browser support and
  crisp pixel scaling once real pixel art is added), which exports to
  desktop, mobile, and web from one project.

## Roadmap / Phase 2 ideas (not built)

- Overworld exploration scene(s) so class discovery can actually happen
  by walking somewhere, rather than only by ID in code.
- A data-driven "unlock condition" system (quest flag, item found,
  location + trigger) that reads `unlock_type` / `evolution_hint` and
  flips `is_hidden` / performs the evolution.
- NPC dialogue system for quest-given unlocks.
- A class-selection scene (pick from unlocked classes rather than the
  combat prototype hardcoding "mage_f").
- Multi-enemy encounters and enemy variety/AI patterns beyond a fixed
  attack — this is now the main thing making the `aoe_damage` effect and
  the rank-vs-turn-count numbers above look more dramatic than they'll
  actually be once there's a real bestiary to fight (a single scaling
  enemy roster, or several enemies at once, would make high-rank battles
  meaningfully harder again, not just faster).
- A second evolution *branch* per family (right now each of the 15 chains
  is fully linear, one path F straight through to S; the original brief's
  "don't know how, maybe multiple paths" idea for branching evolutions
  isn't built).
- Real pixel art: character/portrait sprites, card art, backgrounds, UI
  skin.
- Meta-progression / save system between runs.
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
