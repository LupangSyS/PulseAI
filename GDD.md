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

### Example roster (draft content, not final)

| id | Name | Rank | Deck bias | Hook |
|---|---|---|---|---|
| `mage_f` | Apprentice Mage | F | Spell | Found in a flooded lecture hall of the old mage school |
| `naga_mage_e` | Naga Mage | E (evolves from Mage) | Spell | Accidental river fall near the mage school |
| `hunter_f` | Rookie Hunter | F | Action | Tracks monsters across a collapsed transit line |
| `healer_f` | Field Medic | F | Power (building to heals/shields) | Whispered-about healer in the refugee towers |

Necromancer, other elemental mages (per the original brief), and higher
ranks are intentionally not built yet — see Roadmap.

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
  (`scenes/combat.tscn` / `scripts/combat/combat.gd`): Apprentice Mage vs.
  a placeholder "Flooded Ghoul," demonstrating the deck/hand/discard loop,
  resource costs, block, healing, the empower-next Power card, and the
  combo multiplier.
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
- More classes per the brief (elemental mage variants, Necromancer,
  additional hunter/healer branches), and higher-rank content (D through
  S).
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
- Full starting class roster and which manhwa-style archetypes to
  prioritize first (Hunter/Mage/Healer/Necromancer confirmed in the
  brief; anything else?).
