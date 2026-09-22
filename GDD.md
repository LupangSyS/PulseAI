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

### Roster (v0.2 — 15 base classes, each with one F→E evolution)

All 30 entries (15 base + 15 evolutions) are implemented in
`data/classes.json` / `data/cards.json` and have been battle-tested (see
Prototype status below). Evolution hooks lean on Thai myth and Bangkok
geography specifically so they don't read as generic fantasy reskins —
Naga, Yaksha, Erawan, Garuda, Hanuman, and Kuman Thong are all figures
most players with any exposure to Thai culture will recognize, which
should make discovering an evolution feel like a "wait, *that's* what
this is" moment rather than an arbitrary stat upgrade.

| Base (F) | Deck bias | Evolves into (E) | Discovery hook |
|---|---|---|---|
| Apprentice Mage | Spell | Naga Mage | Accidental fall into the river by the old mage school |
| Rookie Hunter | Action | Crocodile Warden | Survives being mauled by something in a Klong Toey canal |
| Field Medic | Power | Ancestral Medium | Ancestors start answering prayers said over the dying |
| Grave-Diver | Spell | Bone Tide Necromancer | The flooded dead of Wat Hualamphong stop resisting |
| Alley Ghost | Action | Yaksha Blade | A drowned temple guardian statue chooses a new vessel |
| Riot Warden | Power | Erawan Guardian | A flooded shrine grants its three-headed guardian's will |
| Scrap Brawler | Action | Rakshasa Fury | A joke demon-king mask stops being a joke |
| Spirit-House Keeper | Power | Kuman Thong Warden | A tended spirit house starts tending back |
| Ember Diver | Spell | Garuda Ember Knight | Fire from a sunken fuel depot answers to a palace mural's myth |
| Skybridge Scout | Action | Hanuman-Blessed Ranger | Survives an impossible leap between towers |
| Klong-side Boxer | Action | Sak Yant Adept | Sacred tattoo ink finally takes |
| Salvage Chemist | Power/Spell | Mutagen Alchemist | A "failed" brew leaves something behind instead of killing them |
| Static Touched | Spell | Resonant | Psychic "noise" turns out to be the world's current talking back |
| Novice Exorcist | Spell | Khru of the Drowned | Unfinished monk training completes itself, somehow |
| Signal Ghost | Power | Broadcast Wraith | Stops needing the transmitter to broadcast |

Full flavor text (locked rumor + unlocked lore + playstyle blurb) lives in
`data/classes.json` — this table is just an index. Higher ranks (D through
S) and second-stage evolutions are intentionally not built yet — see
Roadmap.

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
  Faith, Tide, ...) that refills each turn. This is deliberately just a
  reskinned mana pool for now; class-specific resource *mechanics*
  (e.g. a resource that carries over, or costs HP) are a Phase 2 idea —
  the Naga Mage's bigger "Tide" pool is a first small step in that
  direction.
- **Deck / hand / discard loop**: each battle shuffles the class's deck
  into a draw pile, draws a hand each turn, discards played and
  end-of-turn leftover cards, and reshuffles the discard pile back in when
  the draw pile empties. Standard deckbuilder-roguelike structure.
  - **Combo system**: playing cards with the same `combo_tag`
    back-to-back stacks a counter that scales that card's value
    (currently +20% per consecutive same-tag card). This is the "combo"
    the brief asked for, implemented generically so every class gets it
    for free, biased by their deck's card-type mix.

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
- **30 classes fully defined and battle-tested** (15 base + 15
  evolutions, see Roster below) — every one was run through a full
  headless combat simulation with zero errors and reaches victory, with
  turn counts genuinely varying by playstyle (e.g. Berserker/Naga
  Mage/Resonant burst it down in ~2 turns; Tank/Healer grind it out over
  8-9). No class-selection UI exists yet to pick between them in a real
  playthrough — the prototype scene still only starts as the Mage.
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
  combat prototype hardcoding "mage_f"), and multiple/second-stage
  evolutions (D through S rank) beyond the current single F→E step.
- Multi-enemy encounters, enemy variety/AI patterns beyond a fixed attack.
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
