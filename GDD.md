# Deluge Chronicles — Game Design Document (Draft v0.1)

Working title only — rename freely. This doc exists so the ideas from the
initial brainstorm have one place to live and grow, instead of being
re-derived from scratch each session.

## Logline

A turn-based card RPG set in Bangkok, October 2025 onward, in the immediate
aftermath of a mega-flood that drowned the surface and cracked open
something that had been sealed in the mountains and glaciers since before
history. Science hit a wall; the survivors clawing out a foothold among the
flooded skyscrapers are the ones who learned
to wield what came out.

## World

*Canonical timeline as of the Story Bible (see the Story Bible section
below) — this supersedes an earlier draft that set the flood in 2026 with
the game nine years later in 2035. The compressed timeline (flood, then
almost immediately playable) fits a save-the-world urgency better than a
"society already rebuilt" framing.*

- **October 2025, The Inundation**: the water did not fall or rise from
  the Gulf — it pushed up from beneath the foundations, black and
  vibrating at a sub-bass hum that resonated structural steel. Bangkok
  didn't just flood; it sank into ancient sediment of human sorrow, guilt,
  and suppressed mythological mass.
- **The Release**: with the brackish surge came a warp in human
  neuro-chemistry. Those who nearly drowned emerged with anomalous
  nervous systems — the Hunters, indexed Rank F to Rank S by the makeshift
  remnants of the Department of Disaster Prevention. The water also
  carried things that had spent millennia calcifying beneath the Chao
  Phraya basin: skin-stealers, karmic parasites, conceptual abominations
  that feed on human regret.
- **2025–2026 (present)**: the game takes place in the immediate
  aftermath, not a settled-in future — survival is raw, the social order
  is still collapsing/reforming (opportunists, militias, cults, and
  genuine communities all forming in real time), and nobody yet fully
  understands what the Release actually is: myth, forgotten physics, or
  something that was always there and only now has a way in.
- **Tone touchstone**: gritty survival body-horror (district-tier content)
  escalating into cosmic/metaphysical dread (dimension-tier content),
  crossed with a hunter/awakening power fantasy (Solo Leveling-style rank
  progression). Mystery and discovery are a core feeling, not just flavor
  text.
- **The goal**: this is a save-the-world RPG, not an endless roguelike
  grind — see World Map and the Story Bible below for how districts,
  dungeons, and the ten dimensions (unlocked step by step) build toward a
  literal climax at the Source of the Release.

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

**Sukhumvit Shallows, Chatuchak Ruins, and Klong Toey Canals** (districts
1-3) are fully built right now — real grids, real monsters, real
mini-boss/boss with stage transitions, real items, NPCs, and puzzle
events (see Exploration & Encounter System and Prototype status below).
Everything else in this section is a content *plan*, following the exact
same data shape (`DistrictData`/`MonsterData`), not yet written to
`data/districts.json`. There is no inter-district travel yet — each is
reachable only as its own standalone run (a "[DEV] <district>" main-menu
button per built district), same as when Sukhumvit Shallows was the
only one.

### Districts (3 built, 9 designed)

| # | District | Tier | Ecosystem / hook |
|---|---|---|---|
| 1 | **Sukhumvit Shallows** *(built)* | F | Flood rats, leeches, drowned strays, toads, wisps; mini-boss/boss are the "source" that bred the rest — see Prototype status |
| 2 | **Chatuchak Ruins** *(built)* | F-E | Collapsed weekend market turned scavenger maze — market-dogs, stall-wraiths, trickster imps, caged songbirds, talisman husks |
| 3 | **Klong Toey Canals** *(built)* | E | The Hunter's territory — crocodilians, canal eels, drowned dockworkers, rusted stevedores, oil-slick wisps (Crocodile Warden's discovery site) |
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
| 10 | The Source of the Release | Origin | The literal origin point of the October 2025 catastrophe — the game's ending |

## Story Bible: The Drowned Chronicles

*Written by the project owner against the World Map above — district and
dimension names/order match exactly, so this is the canonical narrative
layer for every location. Everything here is **designed content**, not
built: no NPC-dialogue, puzzle, or multi-phase-boss engine exists yet (see
Roadmap) except where a district is already implemented in code, noted
inline below. Five reconciliation notes before the content itself:*

1. **Timeline** — adopted as canonical; the World section above now reads
   October 2025 Inundation / immediate aftermath, not the earlier "2035,
   nine years later" draft.
2. **District 1 (Sukhumvit Shallows) is now aligned with this bible.**
   The built mini-boss (`sukhumvit_stalker`) and boss (`shallow_tide_mother`)
   keep their original ids (sprite/asset filenames and all district-data
   references key off the id, not the display name), but their
   `display_name`/`description`/move flavor text now read as "The Neon
   Strangler" and "Phra Khanong Mother (Mae Nak Reflected)" respectively,
   matching this bible exactly - effect/value/weight/HP untouched, this
   was wording only. The district itself also now carries the rest of
   this section's *(built)* content: both NPCs (Uncle Somchai, Sister Da)
   as revisitable dialogue events, the Soi 11 Drowned Arcade and BTS Asok
   Concourse Haven sub-map landmarks as flavor events, the emergency
   broadcast narrative beat, and the Breaker Pump Protocol puzzle as a
   real sequential 3-step gate (`requires_flag`/`sets_flag` on
   `data/districts.json` events, resolved by `overworld.gd`'s
   `_maybe_fire_event` - out-of-order attempts fail with their own text
   and don't consume the step, so it can't softlock). See
   `data/districts.json`'s `sukhumvit_shallows` entry for all of it.
3. **The 10 dungeons' unlockable evolutions** used placeholder base-class
   names (Warrior, Fighter, Scout, Druid, Shaman, Acolyte) that aren't in
   the actual 15-family roster. Each is mapped below to the closest real
   family — first-pass, easy to revise, since the unlock-condition engine
   that would actually wire these doesn't exist yet regardless.
4. **District 2 (Chatuchak Ruins) is now built**, matching this bible's
   section for it below exactly: the mini-boss is `scale_merchant` ("The
   Scale Merchant," 1 stage) and the boss is `chimera_of_drowned_aviary`
   ("The Chimera of the Drowned Aviary," 2 stages), both new monster ids
   with their own sprites (`tools/gen_sprites.py`) rather than a reused
   District 1 id, since District 2 needed genuinely new species anyway
   (market-dogs, stall-wraiths, trickster imps, caged songbirds, talisman
   husks). Kru Viroj (the Watchmaker) is a revisitable NPC event, Section
   7/the Amulet Vault and the Vivarium Drains are landmark flavor events,
   the trade-manifest narrative beat is in, and the Amulet Scale puzzle
   is a real 3-step sequential gate (corpse weight -> scale -> vault
   door) built on the same `requires_flag`/`sets_flag` event mechanic
   note 2 describes. See `data/districts.json`'s `chatuchak_ruins` entry.
5. **District 3 (Klong Toey Canals) is now built**, same pattern again:
   the mini-boss is `sluice_ripper` ("The Sluice Ripper," 1 stage) and
   the boss is `klong_toey_leviathan` ("Klong Toey Leviathan / The Scum
   Matron," 2 stages), both new ids with their own sprites - 5 new
   regular species (canal crocodiles, canal eels, drowned dockworkers,
   rusted stevedores, oil-slick wisps). Commander Lek is a revisitable
   NPC event, Stack-City Core and Drydock 4 are landmark flavor events,
   Lek's militia logs are the narrative beat (the Ratchaprasong-elites-
   trading-children reveal this bible names), and the Crane Sluice
   Alignment puzzle is a real 3-step sequential gate (bridge alpha ->
   bridge beta -> crane lock) on the same event mechanic. See
   `data/districts.json`'s `klong_toey_canals` entry.

### Prologue: The Inundation

The water didn't fall from the sky or rise from the Gulf — it pushed up
from beneath the foundations, black and viscous, vibrating at a sub-bass
hum that resonated structural steel. Bangkok didn't just flood; it sank
into an ancient sediment of human sorrow, guilt, and suppressed
mythological mass. With the surge came the Release: human neurochemistry
warped, and those who nearly drowned emerged with anomalous nervous
systems — the Hunters, indexed Rank F to S by the makeshift remnants of
the Department of Disaster Prevention. The water also carried things that
had spent millennia calcifying beneath the Chao Phraya basin: skin-
stealers, karmic parasites, conceptual abominations that feed on regret.

### Part I: The Districts (grounded descent — gritty survival, body horror)

**1. Sukhumvit Shallows** *(built, flagship depth pass)* — Waist-deep
brackish scum reflecting drowned neon signs; rooftops still have solar
power while street level is a cemetery of submerged cars. Now a real
28×20-cell map (up from an original 10×8 pilot), procedurally laid out
with guaranteed full connectivity (`tools/gen_district_layout.py`'s
carve-and-BFS-verify generator) and then hand-zoned: a canal grind zone
around the entrance, a transformer zone hosting the Breaker Pump
Protocol, Soi 11 Drowned Arcade in the north, BTS Asok Concourse Haven
sealed behind a real locked gate in the northeast, a walled-off Deep
Flood Zone in the south gated behind the Breaker Pump Protocol's payoff,
and a secret vault in the southwest gated behind a mini-boss drop — see
"Locked doors/gates" below for how the gating actually works in-engine.
NPCs: **Uncle Somchai** (Rank D veteran, legs replaced with salvaged
hydro-turbines, runs a floating noodle-barge weapons trade) and **Sister
Da** (ex-nurse performing unsedated illicit Hunter awakenings). Sub-maps,
now real rather than flavor-only: **Soi 11 Drowned Arcade** hosts a
second puzzle, *the High Score Relay* (three arcade cabinets solved in
order — Skee Ball, then Dance Revolution, then the ticket booth — the
same chained requires_flag/sets_flag pattern as the Breaker Pump
Protocol), rewarding the BTS staff keycard; **BTS Asok Concourse Haven**
is a keycard-gated safe room with loot and no monsters. Puzzle — *The
Breaker Pump Protocol*: route battery cells across floating car roofs to
drain a submerged transformer room, matching three electrical frequencies
before the rising tide electrocutes the floor — solving it now actually
opens the floodgate into the Deep Flood Zone, not just a flavor text
reward. Mini-boss — *The Neon Strangler*: a drowned tourist fused with
high-voltage neon wiring and fiber-optic cable, toughened for the bigger
map (58 HP, a new desperate third phase — *Raw Nerve* — once it drops
below 20%); plunges the room into darkness, attacks telegraphed via
buzzing cracked-tube hum; always drops the corroded vault key. Boss —
*Phra Khanong Mother (Mae Nak Reflected)*: also toughened (92 HP).
**Phase 1** a weeping silhouette atop a sunken taxi depot, hurling
shipping containers and ultrasonic wails that scramble the UI; **Phase
2** her limbs stretch through the water beneath the player — step only
on floating debris, or get dragged into a chokehold. Two new regular
species patrol the Deep Flood Zone — **Current Dragger** (a harbor tug
wreck, hits hard) and **Voltaic Current-Eel** (poisons with leaked
transformer current) — alongside the original five. Narrative beat: an
emergency broadcast recording (now found deep in the Deep Flood Zone
rather than near the entrance) proves the government knew the flood was
coming months early, and deliberately sealed canal locks to drown the
lower-income districts first. The secret vault holds the district's best
loot, the Drowned Queen's Signet.

**2. Chatuchak Ruins** *(built, depth pass)* — Mudflats and collapsed
market stalls forming a labyrinth; the weekend market is a graveyard of
exotic animals that mutated instead of dying, traded by scavengers who
worship mannequin heads. Also grown to a real 28×20 map (same
generator/zoning approach as Sukhumvit Shallows): a market-stall maze
around the entrance, Section 7 hosting the Amulet Scale puzzle, a
Mannequin Shrine zone in the north with a new second puzzle (*the Three
Offerings* — a torn dress, a porcelain face, a curio bell, solved in
order), the Vivarium Drains sealed behind a cage-key-gated lock in the
northeast, a walled-off Vault Depths in the south gated behind actually
solving the Amulet Scale (previously just a flavor reward), and a
secret alley gated behind the mini-boss's guaranteed key drop. NPC:
**The Watchmaker (Kru Viroj)**, obsessively repairing waterlogged
watches, claims he can hear the flood's pulse. Puzzle — *The Amulet
Scale*: balance genuine amulets against cursed lead weights pulled from
corpse pockets. Mini-boss — *The Scale Merchant*: four-armed, fused to
cages of mutated fighting fish spitting caustic bile; toughened to 60 HP
with a new third stage, *Every Cage at Once*, below 20%. Boss — *The
Chimera of the Drowned Aviary*: also toughened, to 96 HP. **Phase 1**
hundreds of mutated birds moving as one shifting avian titan; **Phase 2**
consolidates into an emaciated vulture-beast whose chest cavity houses
the market's blind, weeping former animal-syndicate boss. Two new
species patrol the Vault Depths — **Feral Mannequin** (an animated
display dummy) and **Vivarium Stalker** (an escaped, faster-bred exotic
predator) — alongside the original five. Narrative beat: trade
manifests show biological samples arriving from deep ocean trenches
under the river days before the first fissure broke (now found inside
the Vivarium Drains rather than near the entrance). The secret alley
holds the Mannequin Queen's Glass Eye, the district's best loot.

**3. Klong Toey Canals** *(built, depth pass)* *(the Hunter's discovery
site — Crocodile Warden)* — Oil-slicked, caustic water choked with
shipping containers; the poorest turned monstrous first. Grown to the
same 28×20 scale as the other two districts: a canal grind zone around
the entrance, the crane/sluice zone hosting Crane Sluice Alignment,
Stack-City Core in the north with a new second puzzle (*Ladder Ascent*
— three rope-ladder tiers secured in order, rewarding a tower access
card), the card-gated Drydock 4 in the northeast, a walled-off Sluice
Depths in the south gated behind actually finishing Crane Sluice
Alignment (previously just a flavor reward), and a secret hold gated
behind the mini-boss's guaranteed key drop. NPC: **Commander Lek**,
one-eyed militia leader running F-rank scavengers as expendable
mine-clearers. Puzzle — *Crane Sluice Alignment*: align container
bridges with a broken cargo crane while corrosive sludge rises.
Mini-boss — *Sluice Ripper*: a harbor worker grafted to hydraulic
forklift blades; toughened to 70 HP with a new third stage, *Redline
Failure*, below 20%. Boss — *Klong Toey Leviathan (The Scum Matron)*:
also toughened, to 110 HP. **Phase 1** an amorphous oil/hair/sewage
blob erupting through floor grates; **Phase 2** hardens into an oily
carapace and sets the water on fire — manipulate pumps to douse
platforms. Two new species patrol the Sluice Depths — **Sunken
Foreman** (a dockworker wielding a crane hook on a chain) and **Slick
Crawler** (living oil-slick filth) — alongside the original five.
Narrative beat: Lek's logs reveal Ratchaprasong elites trading food for
children, allegedly as fuel or sacrifice to keep the central grid alive.
The secret hold holds the Leviathan's Barnacle Crown, the district's
best loot.

**4. Wat Hualamphong Depths** *(the Necromancer's site — Bone Tide
Necromancer)* — Flooded temple crematoriums merged with MRT tunnels;
monks who died mid-chant are petrified statues whose voices cause
cognitive hemorrhage. NPC: **Phra Maha Prasert**, a monk who gouged out
his own eyes rather than see "the skinless things that pray beside the
novices." Sub-maps: the Hall of Unclaimed Coffins (knocking in
synchronized rhythm), MRT Platform 2 (submerged, lights still flickering
in dead train cars). Puzzle — *The Chanting Tuning-Forks*: strike three
brass bells to match the petrified monks' pitch and shatter an acoustic
seal. Mini-boss — *The Undertaker of Wat Hua*: shrouded, carries an
incense cauldron emitting blind-rage gas. Boss — *The Hungry Ghost of Hua
Lamphong (Preta Titan)*: **Phase 1** a 15m emaciated pinhole-mouthed
humanoid firing starvation sonic beams; **Phase 2** its ribs tear open
into a gravity-pulling stomach-mouth. Narrative beat: temple scripture
says the flood recurs every 500 years once collective human debt outgrows
what the soil can bear.

**5. Ratchaprasong Intersection** *(the Tank's shrine — Erawan Guardian)*
— Mirror-black water around ruined luxury malls; wealthy shelter-in-place
survivors turned cannibalistic aristocrats holding black-tie galas. NPC:
**Madame Pim**, rotting silk, information broker for depraved survivor
syndicates. Sub-maps: Central Atrium Abyss (a blown-out mall core), the
VIP Penthouse Suite (blood-spattered, classical music on loop). Puzzle —
*Mannequin Mirror Line*: rotate mirrored partitions to reflect sunlight
past a shadow curtain. Mini-boss — *The Retail Prince*: bulletproof
tuxedo, dual suppressed handguns, packs of skinned greyhounds. Boss — *The
Golden Yaksha of Siam (Desire Manifest)*: **Phase 1** a brass shrine
guardian wielding a massive cleaver at terrifying speed; **Phase 2** the
shell cracks — molten gold and burning flesh create persistent hazard
pools. Narrative beat: the Aristocrats made a pact with something inside
the Grand Palace, luring refugee caravans into kill-zones in exchange for
safety.

**6. Thonburi Drowned Temples** *(shared site for the Assassin's Yaksha
Blade and Kuman Thong Warden)* — Total submersion; bell towers and
Ayutthaya-era brick pushing through modern asphalt, silent water, lotus
flowers that rot into blood when touched. NPC: **The Boatman (Khun
Charoen)**, silent, communicates only via oar-tapping rhythm. Sub-maps:
the Inverted Stupa (sunk point-down into a sinkhole), the Hall of the
Submerged Buddha (a bronze reclining Buddha under poisonous water).
Puzzle — *The Water Bell Alignment*: dive between three bronze bell
chambers before oxygen runs out to part the water. Mini-boss — *The
Bell-Ringer Priest*: external gills, wields a temple clapper like a
warhammer. Boss — *Naga Regent (The River's Spite)*: **Phase 1** a
serpentine demigod generating whirlpool currents; **Phase 2** sprouts
seven heads, each casting a distinct elemental curse while slamming tidal
waves. Narrative beat: murals inside the inverted stupa depict modern
Bangkok burning and drowning — painted 300 years ago by a mad Ayutthayan
monk.

**7. Rama IV Fuel Depots** *(the Pyromancer's origin — Garuda Ember
Knight)* — Diesel slicks, ruptured silos, floating napalm-grade gasoline
lakes; one spark ignites entire blocks. NPC: **Chief Engineer Korn**,
coughing, obsessed with preventing a mega-silo explosion that would take
the remaining districts with it. Sub-maps: Silo 9 Interior (an insurgent
cult's torture den in a hollow fuel tank), Pipeline Catwalks (suspended
mesh bridges over burning crude). Puzzle — *Pressure Relief Valve
Routing*: adjust three valves across a burning catwalk within a 90-second
countdown. Mini-boss — *The Pyre Warden*: fire-immune, strapped into an
industrial flamethrower rig. Boss — *Combustion Entity: Phloeng (The
Fire-In-Water)*: **Phase 1** superheated blue flame inside a boiling-water
sphere, throwing steam geysers; **Phase 2** expands into a combustion
pillar — trigger halon fire-suppression stations to weaken its shield.
Narrative beat: the fuel was stockpiled by the military junta to burn the
slums if the infected broke the cordon, not for civilian survival.

**8. Skybridge Network** *(the Ranger's vertical territory —
Hanuman-Blessed Ranger)* — 30m above the water; glass/steel skywalks
between towers, toxic mist below, winged skinless carrion beasts hunting
the walkways. NPC: **Sniper Jane**, ex-Olympic marksman defending an
orphanage on the 42nd floor. Sub-maps: the Shattered Glass Bridge
(cracked floorplates give way under weight), Sky-Lobby Helipad
(windswept, rain-lashed). Puzzle — *The Counterweight Crane Elevator*:
sever specific cables to catapult a maintenance lift up. Mini-boss — *The
Wind-Cutter Drone*: an overgrown security drone with mutated human
eyeballs wired into its targeting. Boss — *Garuda Ascendant (The Apex
Scavenger)*: **Phase 1** an avian-humanoid slicing catwalk cables, dropping
arena segments into the mist; **Phase 2** summons gale winds forcing
players to anchor to pillars while dodging javelin feathers. Narrative
beat: Jane reveals the evacuation helicopters didn't reach safety — they
flew into the sky above the Grand Palace and vanished.

**9. Bang Rak Underlevels** *(the Berserker's fight pits — Rakshasa
Fury)* — Colonial brick drainage and flooded embassy vaults, smelling of
wet parchment and formaldehyde; catacombs hold preserved 19th-century
diplomats and anatomical specimens. NPC: **Father Thomas**, a mad Jesuit
baptizing survivors in caustic floodwater until they mutate or drown.
Sub-maps: the Flooded Embassy Archive (floating colonial intelligence on
Siamese occult relics), the Bone-Cistern (a century of human skulls
stacked to the ceiling). Puzzle — *The Seal of St. Jude*: align three
Latin dials to historical plague dates. Mini-boss — *The Archivist of
Flesh*: multi-limbed, binds skin into leather books with scalpels. Boss —
*The Inquisitor's Leviathan (The Penitent King)*: **Phase 1** a floating
iron cage firing barbed chains to reel players into the water; **Phase 2**
the cage shatters into a flayed giant wielding crucifixes that strike with
holy-fire. Narrative beat: 1893 colonial documents describe discovering
the first "Rupture Point" beneath the river and sealing it with
silver-lined masonry — seals that cracked open in October 2025.

**10. The Drowned University** *(the Mage's original school — Naga Mage,
the very first lore hook)* — Murky courtyards, flooded libraries with
floating textbooks, collapsed labs; faculty went insane quantifying the
floodwater's supernatural properties. NPC: **Professor Chai**, dying,
IV-strapped, dimensional equations scrawled across his lab coat. Sub-maps:
the Sunken Faculty Library (a 4-story rotunda navigated via floating
bookshelves), the Centrifuge Vault (centrifuges still spinning shimmering
dimensional blood). Puzzle — *The Spectrometer Calibration*: split violet
light across three prisms to disable a decontamination laser grid.
Mini-boss — *The Dean of Dissection*: cybernetic, bone-saws and
defibrillator paddles, ceiling-rail-mounted. Boss — *The Scholastic Hive
(The Pedant)*: **Phase 1** a floating sphere of mummified professors'
heads, firing psychokinetic barrages that reverse player controls;
**Phase 2** pulls millions of wet pages and desks into a 20-foot armored
juggernaut. Narrative beat: Professor Chai's final paper argues the flood
isn't physical liquid — it's liquid *information*, reality's unused memory
overflowing into our coordinate space.

**11. Refugee Tower Cluster** *(the Healer's territory — morally
messier: inhabited, not just infested)* — Three 50-story towers leaning
together in a swamp; tens of thousands fled here and starved, driving
ritual madness and tribal floor-territories. NPC: **Mei**, a 10-year-old
who climbs elevator cables with superhuman agility, trading medicine for
dubious dried meat. Sub-maps: the Skybridge of the Starved (a rope bridge
at the 35th floor), the Meat Locker — Floor 13 (a curing room for human
jerky). Puzzle — *The Elevator Counter-Balance*: shift rubble between two
freight elevators to balance an ascent mechanism. Mini-boss — *The
Floor-Lord Butcher*: obese, wields a dual-bladed industrial pizza cutter.
Boss — *The Swarm of the 40th Floor (The Congregate)*: **Phase 1** a wall
of reaching human arms spitting toxic bile; **Phase 2** an enormous pale
tapeworm-horror with the weeping faces of the tower's original landlords
along its spine. Narrative beat: from the roof, the sky above the Grand
Palace isn't cloudy or black — it's an impossible geometric hole where the
stars spin in reverse.

**12. The Grand Palace Shallows** *(highest-tier district; gateway to the
dungeons and dimensions)* — White marble courtyards under shallow,
mirror-flat, gold-tinged water; pristine gold-leaf roofs, deafening
silence, no scent, no ripples even when walking. NPC: **The Royal Knight
(Krit)**, the last Palace Guard, guarding a door to nowhere with an empty
rifle. Sub-maps: the Corridor of Murals (the Ramayana epic, every painted
demon face gouged out), the Emerald Sanctum (the Emerald Buddha's pedestal
empty, replaced by a swirling column of static). Puzzle — *The Nine-Fold
Chatta Alignment*: rotate nine ceremonial umbrellas so their shadows
converge on the empty throne, cracking the dimensional threshold.
Mini-boss — *The Faceless Praetorian*: a 12-foot mirror-armored guardian
whose faceplate reflects the player's own worst fears/strongest attacks.
Boss — *Guardian of the Threshold (Yaksha Overlord Tossakan Reborn)*:
**Phase 1** The Ten-Faced General — ten arms, ten weapons, destroy in a
sequence keyed to elemental vulnerability; **Phase 2** The Heartless Titan
— his heart floats in a glass vessel behind the player while he sweeps;
**Phase 3** The Shattered Icon — his body crumbles into a floating vortex
that tears reality open. Narrative beat: on Tossakan's defeat the marble
splits, water rushing into a bottomless drop — the player doesn't descend,
they fall *upward* into the first dimension.

### Part II: The Dimensions (endgame — cosmic horror, metaphysical dread)

Visual/tonal shift at the transition: the water stops having physics,
becomes mirror-flat, reflects skies that don't exist. Enemy design sheds
biological motifs (teeth, hair, rotten meat) for geometric/acoustic/
typographic forms (floating Pali script, sine waves, fragmented statues).

**13. The Static Between Seconds (Time)** — Raindrops frozen mid-air,
explosions frozen mid-burst; moving causes friction burns against
unmoving air. Puzzle — *Chronos-Stepping*: use temporal resonance needles
to momentarily unfreeze specific objects as makeshift bridges/elevators.
Mini-boss — *The Stutter-Stalker*: teleports to the player's past
positions, striking where you stood 3 seconds ago. Boss — *Chronophage:
The Stolen Moment*: **Phase 1** fights in fast-forward, react to audio
cues before animations; **Phase 2** reverses status — healing damages,
resource spending restores, buffs become lethal debuffs.

**14. The Weight of What's Owed (Gravity ↔ Guilt)** — Gravity scales with
psychological guilt; inverted floating temple ruins hang over an iron
sky. Puzzle — *Karmic Ballast*: carry lead talismans representing
betrayed earlier-district NPCs — more defense, agonizingly slower, across
gravity-inversion plates. Mini-boss — *The Bailiff of Souls*: a balance
scale that equalizes party HP to the lowest member. Boss — *The Sinking
Sinner (Phra Malai's Regret)*: **Phase 1** a dense sphere of bodies
exerting gravitational pull into crushing zones; **Phase 2** gravity
reverses unpredictably — fight while falling upward toward a ceiling of
spikes.

**15. The Unheard Frequency (Sound/Signal)** *(the Bard/Signal chain's
true test)* — A pitch-black void of oscillating radio waves visualized as
blinding ribbons; sound causes physical impact. Puzzle — *Waveform
Harmonization*: tune receivers to the resonant frequency of invisible
bridges that exist only under a specific chord. Mini-boss — *The Feedback
Siren*: deafens/blurs the UI proportional to incoming sound waves. Boss —
*The Deafening Silence (The Void Broadcast)*: **Phase 1** a CRT-static
colossus that cancels spellcasting during scream cycles; **Phase 2** total
silence — no music, no SFX, attacks telegraphed only by subtle air
ripples.

**16. The Space Between Names (Identity)** — A shifting maze of mirrors
and melting mannequins; entering a room randomizes the player's visual
model and loadout. Puzzle — *The Bureaucracy of Existence*: stamp your own
death certificate at three consular desks using clues from your
character's starting corpse. Mini-boss — *The Amnesiac Clerk*: deletes a
random skill from the quick-bar every 45 seconds until staggered. Boss —
*The Nameless Doppelgänger*: **Phase 1** copies your current class/build/
deck, playing your own strategy 20% more efficiently; **Phase 2**
transforms into the party member you relied on most, forcing you to fight
your own primary damage dealer.

**17. The Undertow of Memory (Collective Memory)** — A sepia 1970s
Bangkok; vintage trams on non-existent roads, the 1976 protests looping;
touching a memory means reliving that person's death. Puzzle — *The
Paradox Photograph*: find historical discrepancies in three looped
memories to collapse the illusion. Mini-boss — *The Sepia Executioner*:
phases through walls, vulnerable only inside a vintage camera's flash.
Boss — *The Amniotic Sea (The Mother of Days)*: **Phase 1** summons
memory-clones of the Districts 1/3/5 bosses at reduced HP simultaneously;
**Phase 2** submerges the stage in memory fluid — stand only on fading
Polaroids that dissolve after 5 seconds.

**18. The Marrow Depths (Structure)** *(Necromancer-adjacent)* — Reality's
skeletal framework: walls of cross-laminated human femur, spinal elevator
shafts, pulsing marrow rivers. Puzzle — *Osteo-Pillar Alignment*: strike
nerve bundles to grow/retract bone spurs into a 500-foot spinal
staircase. Mini-boss — *The Calcified Carpenter*: constructs bone walls to
box the player into crush zones. Boss — *The Architect of Ribs (The Great
Osteon)*: **Phase 1** traps the player in its own ribcage with rhythmic
spike waves; **Phase 2** sheds its structure — an exposed spinal cord
lashes electrical nerve impulses that stun.

**19. The Mirror Current (Alternate Choice)** — The river of unmade
choices; phantom Bangkoks that were never flooded (solar utopias, nuclear
wastelands, extinction in 1767). Puzzle — *Timeline Shifting*: step
through fractured mirror glass to toggle a room between Ruined/Utopian/
Scorched states to bypass walls. Mini-boss — *The Unborn Potential*: uses
skills from classes the player chose *not* to evolve into. Boss — *The
Parallel Sovereign (The You That Didn't Drown)*: **Phase 1** a version of
the protagonist who embraced the flood's corruption; **Phase 2** melds
with three alternate-timeline selves, rotating elemental affinity/combat
style every 30 seconds.

**20. The Yantra Lattice (Sacred Geometry)** *(the Monk chain's true
test)* — Floating golden Pali scripture and laser-precise sacred geometry
in a velvet-red cosmos. Puzzle — *Sutra Completion*: trace missing
geometric lines by stepping on glowing glyphs in correct phonetic
sequence. Mini-boss — *The Geometer Monk*: fires geometric laser grids
bisecting the room into safe/lethal zones. Boss — *The Living Yantra
(Phra Phrom Unbound)*: **Phase 1** a rotating four-faced tetrahedral
construct that rotates the whole battlefield 90° each turn; **Phase 2**
deconstructs into thousands of razor-sharp golden characters raining in
carpet-bombing runs.

**21. The Court Beyond Court (Myth-Above-Myth)** — The celestial throne
room above all pantheons; infinite cracked marble pillars leaking black
sewage, dead gods propped like discarded marionettes. Puzzle — *The
Broken Scales*: place earlier dimensional bosses' severed heads on
celestial balance scales to force the Obsidian Gate open. Mini-boss — *The
Executioner of Deities*: a guillotine blade that permanently reduces max
HP for the rest of the fight. Boss — *The Usurper of the Throne (Indra
Decayed)*: **Phase 1** a rotting king on an elephant skeleton, hurling
petrifying lightning spears; **Phase 2** fights on foot with broken
god-metal blades at near-light speed. Dying gasp: *"We did not start the
flood... we built the dams... and your world... broke them from below..."*

**22. The Source of the Release (Origin) — final area** — Not an ocean or
temple: a sterile hyper-modern hospital basement beneath a Bangkok street,
smelling of damp concrete, infant powder, and sea salt. At its center, an
ancient pulsating biological valve — the primordial drain reality's toxic
waste is purged through. No NPCs; only the player's own thoughts echoed
back along the wet walls. **Final boss — The Embryo of the Flood
(Ananta-Shesha Unborn)**: **Phase 1** The Cradle of Seepage — an immense
mass wedged into the foundation, acidic tidal surges, memory wipes,
summoned echoes; **Phase 2** The Anthropocene Worm — a multi-headed
cosmic serpent built from Bangkok's debris (cars, rail, concrete, a
million human hands); **Phase 3** The Dry Water — a pure conceptual
entity, the water becomes blinding white light, and the player's entire
card deck/skill set dissolves, fighting with only core "Drown" or
"Breathe" primordial commands.

**The Ending — three mutually exclusive options:**
- **A. Pull the Plug (The Drain)** — drain the water permanently; magic
  and classes vanish, monsters die, Bangkok becomes a desiccated
  bone-desert. Humanity survives, hollowed out.
- **B. Let It Rise (The Abyssal Cradle)** — surrender the terrestrial
  world; the earth drowns completely and humanity evolves into
  gill-bearing, psychically linked aquatic beings.
- **C. Become the Dam (The Sovereign Seal)** — fuse body and soul into the
  ruptured foundation, becoming the new seal; the flood recedes to normal
  river levels, but you remain awake for eternity beneath the Chao
  Phraya, feeling every drop of filth pass through your teeth.

### Part III: The Dungeons — updated with real class-family mappings

*Gimmick/boss concept and unlock tier are the bible's as written; the
"Unlocks" column maps each placeholder base class to the actual family
(see reconciliation note 3 above) and — where one already exists — the
already-documented evolution target from the Roster table.*

| Tier | Dungeon | Gimmick / Boss | Unlocks (real family) |
|---|---|---|---|
| D | The Flooded Subway Line | Total darkness, flashlight battery life. Boss: *The Track-Dragger* (blind mole-human) | **Ranger** branch — "Sub-Stalker" |
| D-C | The Sunken Cinema | Projector shadows become physical. Boss: *The Projectionist* (cutting film reels) | **Mage** branch — "Illusionist," alongside the existing Naga Mage path |
| C | The Vertical Vault | High water pressure; armor slows descent but resists hazards. Boss: *The Gilded Safe-Cracker* | **Tank** branch — "Juggernaut" |
| C | The Coiling Temple | Continuous whirlpool current along a spiral dragon body. Boss: *The Dragon's Heart Parasite* | **Monk** branch — "Dragon-Monk," naga-themed |
| C-B | The Rakshasa's Arena | Melee generates "Blood Heat"; low heat = hypothermia. Boss: *The Unbeaten Champion* (8-limbed ghoul) | **Berserker** — matches the already-documented Rakshasa Fury proving ground |
| B | The Garuda Spire | Wind gusts push toward the edge; lightning telegraphs landing zones. Boss: *Storm-Herald Roc* | **Ranger** — alongside the existing Hanuman-Blessed Ranger/Pyromancer site |
| B | Hanging Gardens of Kuman Thong | Toxic spores swap friend/foe labels. Boss: *The Floral Mother (Banyan Queen)* | **Necromancer** branch — closest fit to "Necro-Botanist" |
| B-A | Court of the Drowned King | Boats tip/rock based on damage and weight. Boss: *The Admiral of the Rotten Fleet* | **Summoner** branch ("Tide-Caller") **or** Necromancer (this dungeon was originally slated as the Necromancer's own endgame — genuinely ambiguous, worth the project owner's call |
| A | The Yaksha Vault | Security lasers reflect off water; gold weights disable traps. Boss: *The Automated Yaksha Colossus* | **Berserker** branch — "Titan-Breaker," a second/higher offshoot alongside Rakshasa Fury |
| A | The Erawan Bastion | Three-headed statue beams divine wrath by quadrant. Boss: *Erawan's Avatar* (33-headed) | **Tank** — matches the already-documented Erawan Guardian → Erawan Avatar S-rank chain directly |

### Gameplay flow directives (design notes — not yet built)

- **Water Level Meter** (districts 1–12): being submerged drains stamina,
  slows dodge-rolling, and raises encounter frequency.
- **Structural integrity**: certain floor tiles (cracked glass, rotten
  boards, rusted zinc) have HP that degrades under weapon use or
  prolonged standing.
- **The Abstract Transition** (district 12 → dimension 13): water stops
  having physics, becomes mirror-flat, reflects nonexistent skies; enemy
  design shifts from biological to geometric/acoustic/typographic.
- **Boss Phase Escalation Protocol** (every boss, all 22 critical-path
  maps): Phase 1 recognizable iconography (monks, statues, serpents,
  flood myths) → Phase 2 the arena itself breaks, environmental hazards
  dominate → Phase 3/desperation the boss sheds identity and attacks the
  player's interface/senses/status directly, not just their HP. This
  already has a real, working analog in the engine: `MonsterData.stages`
  (HP-threshold-triggered movelist/name swaps — see `shallow_tide_mother`
  for a working 2-stage example) is the mechanism a real Phase 2/3 would
  extend, not a new system.

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
  hinting at the mage school). Optional `requires_flag`/`sets_flag`/
  `fail_text`/`reward_item` turn a plain event into a chained puzzle step
  (Breaker Pump Protocol, Amulet Scale, Crane Sluice Alignment, and now
  Sukhumvit Shallows' second puzzle, the arcade's High Score Relay).
- **Locked doors/gates** (`DistrictData.locked_cells`): a second, distinct
  kind of impassable cell from `blocked_cells` — not a wall (it still
  renders as normal walkable terrain, just marked with a small amber
  marker), but `move_player` refuses to cross it until the player holds a
  specific item (`requires_item`, checked against `RunState.inventory`,
  a permanent unlock once found — not consumed) or a district flag is
  set (`requires_flag`, the same flags puzzle events already write via
  `sets_flag`). This is the primitive behind Sukhumvit Shallows' BTS Asok
  Haven (keycard-gated), its secret vault (vault-key-gated, dropped by
  the mini-boss), and its Deep Flood Zone gate (flag-gated by actually
  finishing the Breaker Pump Protocol, not just a flavor reward anymore).
  Distinct from an event's own `requires_flag`, which gates a one-time
  text/reward, not passage.

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
- **Three fully playable districts** (`scenes/overworld.tscn` /
  `scripts/overworld/overworld.gd`): Sukhumvit Shallows, Chatuchak
  Ruins, and Klong Toey Canals, each with grid movement, a mini-boss and
  boss (with stage transitions) that are permanently removed once
  beaten, item pickups + monster loot drops feeding a simple inventory
  with usable items, and a cluster of NPC/landmark/narrative events plus
  a sequential flag-gated puzzle (Breaker Pump Protocol / Amulet Scale /
  Crane Sluice Alignment) apiece. All three now got the same depth pass
  (see above) and are 28×20 with 14 regular spawns across 7 species, two
  puzzles, 3 locked gates, and a secret vault apiece — up from the
  original 10×8/6-spawn/one-puzzle/no-locks pilot shape every district
  shipped with initially. No travel between them yet - each is its own
  standalone run, picked by `RunState` via a
  "[DEV] <district>" main-menu button. Walking into a live monster
  transitions into...
- **A real save/load system, single slot** (`RunState.save_game`/
  `load_game`, JSON at `user://saves/slot1.json`): player class, HP,
  resource, inventory, and *every* district's exploration state
  (defeated spawns, collected items, fired events, puzzle flags) all
  round-trip. The one real correctness trap here - `defeated_spawns`'
  respawn timers are stored as *absolute* `Time.get_ticks_msec()`
  values, which reset to ~0 every process start, so saving them raw
  and reloading in a later session would make every timed-out spawn
  respawn instantly (or at some arbitrary wrong moment) - is handled by
  converting to/from *remaining* milliseconds at the save/load
  boundary, verified headlessly by checking the restored value isn't
  the stale raw number and the remaining time survives within a slack
  window. "Save Game" lives in the status menu (needs to know where
  the player currently is, which `RunState` alone can't - `overworld.gd`
  hands the status menu a reference to itself for exactly this);
  "Continue" appears on the main menu only when a save file exists and
  resumes at the exact saved district and cell via
  `RunState.pending_player_cell`, consumed once by `Overworld._ready()`
  the same way `pending_district_id` already was.
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
- **Real dark theme app-wide + enemy intent telegraph, not stock Godot
  widgets.** `scripts/util/ui_theme.gd`'s `UITheme` (a static-function
  utility, same convention as `SpriteLoader`/`TileLoader`) builds one
  shared `Theme` - dark bordered `PanelContainer`s, per-role bar colors
  (`COL_PLAYER` cyan, `COL_ENEMY` rose, `COL_RESOURCE` violet,
  `COL_WARNING` amber), a consistent button/label palette - and every
  screen adopts it with one `theme = UITheme.build()` line in its own
  `_build_ui()`/`_ready()`: `combat.gd` (which originated the look, now
  refactored to call `UITheme` instead of keeping a private copy),
  `overworld.gd` (flat-fill panel backgrounds behind the top/bottom HUD
  bands, since those position children by raw pixel coordinates rather
  than container rules, so a `PanelContainer` wrapper would fight that;
  `Minimap._draw()` also fills its own panel-colored background now),
  `status_menu.gd`, and `main_menu.gd` (boxed in a `PanelContainer`,
  which required capping its width and adding `clip_text` to the
  buttons - a `PanelContainer` sizes to its widest natural content, and
  these button labels are long enough to overflow the 480px canvas
  unconstrained; caught by an actual screenshot, not assumed). Applied
  once to a scene root, every dynamically-created node (tray buttons,
  inventory buttons) picks it up automatically rather than needing
  per-instance overrides. Cards also get a type-tinted border, reusing
  the same `TYPE_TINT` the icon tinting already used.
  **Combat's bigger addition is a real intent telegraph**: `enemy_intent`
  holds the monster's next move, pre-rolled a full player turn in
  advance (`_start_battle` seeds it; `_enemy_turn` re-rolls it right
  after resolving a move, and *also* whenever a stage transition swaps
  the active move list, so a mid-telegraph phase change can't show a
  move that phase doesn't have) and rendered near the enemy portrait as
  an icon (the same effect icons cards use) plus name and, for
  offensive moves, the exact value — matching Slay the Spire's "you can
  see the hit coming" pattern rather than a monster that just acts blind
  each turn. Damage/heal/block also spawn a floating number over the
  affected portrait (`_spawn_floating_number`, a `Tween` that rises and
  fades) and a brief positional-jitter screen-shake on hits
  (`_screen_shake`) - juice a static HP-bar tick alone didn't give.
  Headlessly verified with a real multi-turn fight against the Neon
  Strangler (`sukhumvit_stalker`) through an actual stage transition,
  confirming intent stays populated and gets re-rolled correctly across
  the phase swap. Deliberately not attempted: a real-time animated
  canvas battle scene (a different rendering architecture, not a UI
  reskin) and new action-economy mechanics such as a stagger gauge, a
  mana-generating basic attack, or a flee command, which are game-design
  decisions rather than visual polish.
- **Card art: one icon per effect, tinted per type.** `tools/gen_card_icons.py`
  generates seven small white-silhouette icons keyed to `CardData.effect`
  (damage/heal/block/empower_next/dot/aoe_damage/execute —
  `assets/icons/effect_<name>.png`), covering all 417 cards automatically
  since every card already has one of these seven effects — no per-card
  or per-class art needed. Each icon is tinted at runtime via
  `TextureRect.modulate` keyed by `CardData.type` (`combat.gd`'s
  `TYPE_TINT`: action=red-orange, spell=blue, power=gold), so 7 effects
  × 3 types reads as meaningfully different without baking 21 separate
  images. A deliberate scope call: the user asked for "action and spell"
  art, and with 417 cards, bespoke art per card wasn't tractable
  alongside the 90-class portrait pass in the same session — an
  effect-keyed icon is also more informative at a glance (shows *what a
  card does*) than a per-card illustration would be at this size.
  Wiring this in surfaced a real pre-existing layout bug: `_make_tray_button`'s
  `Button` doesn't auto-grow to fit its children (they're anchored via
  `PRESET_FULL_RECT`, so the button's own fixed size is authoritative,
  not computed from content) — the longest card description (89 chars)
  was silently overflowing past its button's bottom edge even before
  the icon narrowed the text column further, just by less. Card tray
  buttons grew (208×50 → 228×70, using width the scroll area already
  had unused) and `card_scroll` grew to match (116 → 132), both
  re-validated against that exact longest-description card as the
  worst-case test, not just typical ones.
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
- **Real pixel art for all 105 classes and all 22 monsters across
  Sukhumvit Shallows, Chatuchak Ruins, and Klong Toey Canals.** Every class in the roster — not just the 15 F-rank
  starters — now has a true 64×64 RGBA sprite in `assets/sprites/`,
  every pixel an explicit color choice (region-fill generation, not an
  AI image model), so hard edges and real alpha transparency are
  guaranteed, not hoped for. Native resolution was bumped from an
  original 32×32 (real added detail per `tools/gen_sprites.py` — eye
  highlights, fabric-fold shading, finer weapon/shield shapes — not the
  old shapes just scaled up 2x) once 32×32 started reading as too
  low-fidelity at the sizes players actually see it. Combat and the
  status menu grew their portrait boxes (56px → 80px) to show the extra
  detail off; the overworld's on-screen sprite size is native-scale
  again now that the camera/scroll system removed the old viewport
  constraint. Each has a 2-frame idle animation.
  **Rank power progression, not 90 hand-authored palettes**: each of
  the 15 families defines one base look (`FAMILY_BASE` — the F-rank
  config, every family now with its own hair color and either a weapon
  or hand-wraps — no more bald heads or empty hands), and `RANK_TIERS`
  in `tools/gen_sprites.py` derives E through S from it. The
  progression is gear, not just a recolor, because a class evolution is
  meant to be hard-won and the payoff needs to read as genuinely more
  elegant/powerful: HSV saturation/brightness boosts (`boost_colors`)
  throughout, then from C rank up shoulder pauldrons, from B rank up a
  flowing cape, and — S rank only — a circlet, fully luminous eyes, a
  halo arc hovering above the head, and two small glowing companion
  orbs at the shoulders, so the final evolution reads as a distinct
  apex tier rather than one more step of the same escalation. C rank up
  also adds a forehead mark and a glowing aura outline dilated around
  the finished silhouette (`add_aura`, thickening with rank), and the
  weapon itself picks up the same glow from C rank up
  (`_draw_weapon`'s `glow` accent). All of it — aura, pauldron trim,
  weapon glow, halo, orbs — is drawn from each family's own trim/glow
  color, so it stays family-distinct (the Necromancer's ghostly green
  glow, the Tank's blue-gray shield glint) rather than a single generic
  "power-up" effect. This is a deliberate scope trade against bespoke
  myth-specific art (naga scales for the Mage chain, wings for Garuda,
  etc.) for all 90 non-F-rank classes at once — uniform and honest
  about being a rank indicator, not a claim of unique per-evolution
  iconography. Real per-evolution art remains a future upgrade path per
  family, not blocked by anything structural.
  The generator reads `data/classes.json` directly to walk each
  family's actual F→S `evolves_to` chain rather than guessing an
  id-naming pattern — several E-rank ids don't follow `family_e` (e.g.
  the Mage family's E rank is `naga_mage_e`), so this only ever uses
  real roster data. `SpriteLoader` renders them as `AnimatedSprite2D` in
  the overworld and as animated portraits in combat, and **falls back
  to the original colored-rectangle/text-only look for any id without
  art** — now down to just monsters beyond those 22. Adding
  a class's art is one `humanoid(...)` config entry in
  `tools/gen_sprites.py` — no other code changes needed; `SpriteLoader`
  picks it up by filename
  convention alone.
- **Tile-based overworld rendering with a real camera, piloted on
  Sukhumvit Shallows.** `tools/gen_tiles.py` generates an original 64×64
  tileset (`assets/tiles/flood_tileset.png`: shallow water, deep water,
  wet pavement, rubble — same region-fill/real-alpha principle as the
  character generator, themed to *our* flooded Bangkok, not copied from
  any reference game's tile graphics; the design grid is fully
  addressable at the native tile size, not a chunky upscale, so there's
  room for fine ripple/crack/debris texture) that
  `scripts/util/tile_loader.gd` turns into a real Godot
  `TileSet`/`TileMap`. A district opts in with a `terrain` field
  (`DistrictData.terrain` — one legend string per row, purely cosmetic;
  collision always comes from `blocked_cells` regardless of the terrain
  character underneath). No `terrain` data (every one of the other 31
  districts/dungeons/dimensions right now) falls back to the original
  flat colored-rect grid — same "safe fallback for content that hasn't
  been authored yet" pattern as sprites. The overworld HUD: a district
  name/description banner and a small live minimap (dot-grid, player
  marker, red mini-boss/boss markers while they're still up) top, an
  HP/resource bar readout, deck-size counter, message log, and inventory
  row bottom.
  **Camera/scroll system**: `grid_root` (all tiles/sprites, in pure
  grid-local pixel coordinates) lives inside `map_viewport`, a Control
  with `clip_contents = true` sized to the play area between the HUD
  bands; `_update_camera` recenters on the player every move, clamped so
  it never scrolls past the map's edges, or exactly centers the map if
  it's smaller than the viewport (the small-map case — what Sukhumvit
  Shallows *was* before this — is a special case of the same clamp, not
  a separate code path). This removed the "district must fit on one
  screen" constraint, so `CELL_SIZE` went 24→40→64 to finally match the
  sprite/tile art's native resolution. Headlessly verified: the
  tile-rendering path, the flat-grid fallback path, every HUD element's
  on-screen bounds, camera clamping at all four map corners plus a
  synthetic small-map centering case, and that movement/encounters/item
  pickup are unaffected, on top of the existing overworld↔combat
  end-to-end flow.
  **Known visual issue (found during the Sukhumvit Shallows depth pass,
  not fixed):** once the camera scrolls a few rows away from wherever it
  started, the TileMap stops drawing tiles for the rest of the district
  and the dark background shows through instead — reproducible with real
  `move_player()` calls (not just a test-harness teleport), and present
  on the small pre-existing districts too once you walk far enough from
  the entrance, so it predates this depth pass rather than being caused
  by it. Collision/spawns/events/locks are entirely data-driven and keep
  working correctly underneath (headlessly verified independent of
  rendering), so this is cosmetic, not a game-logic bug. Investigated at
  length: not explained by terrain tile color, not fixed by disabling
  `map_viewport.clip_contents`, and not fixed by replacing the plain
  clipped `Control` with a real `SubViewport`/`SubViewportContainer`
  (the standard Godot scrolling-2D pattern) — both architectures show
  the identical cutoff, which points at something lower-level (possibly
  specific to `llvmpipe` software rendering in this headless sandbox,
  since it couldn't be tested against a real GPU here). Needs a fresh
  look, ideally on real hardware, before the next district depth pass.
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

- **The other 29 zones.** Three districts are real (Sukhumvit Shallows,
  Chatuchak Ruins, Klong Toey Canals), all three now at the same
  28×20 depth-pass scale; the other 9 districts, all 10 dungeons, and
  all 10 dimensions are designed (World Map above and the Story Bible
  section, with full atmosphere/NPC/puzzle/boss detail for every one of
  them) but have zero entries in `data/districts.json` /
  `data/monsters.json`. Filling in new zones is purely content
  work, following the pattern Sukhumvit Shallows proved out (content +
  `terrain` tile art, `tools/gen_district_layout.py` for a
  connectivity-guaranteed base layout at any size) — the camera system
  means a district's size no longer has to fit on one screen, so this is
  no longer blocked on anything structural, only on the known tile-
  rendering issue noted above being worth chasing down first. The full
  spawn-to-final-boss
  order is: the 12 districts in tier order, then the 10 dimensions in
  their documented order ending at *The Source of the Release* (the
  literal final boss); the 10 dungeons are optional side content, not on
  the critical path.
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
- Art for everything outside the 3 built districts: monster/item icons
  for the other 29 planned districts/dungeons/dimensions, a real tileset
  for their overworld ground (Sukhumvit Shallows, Chatuchak Ruins, and
  Klong Toey Canals all use the generated flood-city tileset already;
  everywhere else still falls back to plain `ColorRect`s), named-
  building/landmark art beyond flavor text, and general UI skinning
  (partially addressed by `UITheme` - see the dark-theme note above,
  though it's palette/panels, not bespoke per-district art).
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
