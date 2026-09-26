class_name DistrictData
extends RefCounted

## A district/dungeon/dimension definition, loaded from res://data/districts.json.
## Layout is a simple fixed-size grid (no hand-authored TileMap/TileSet
## resource - see overworld.gd for why) described entirely as cell
## coordinates: which are blocked, where regular monsters/items/events
## sit, where the entrance is, and where the (single, non-respawning)
## mini-boss and boss stand. This same shape is meant to describe every
## future district/dungeon/dimension, not just the one that's built.

var id: String
var display_name: String
var description: String
var danger_tier: String # rough rank band this district/dungeon is meant for, e.g. "F-E"
var kind: String # "district" | "dungeon" | "dimension"
var grid_width: int
var grid_height: int
var blocked_cells: Array # Array[Array] of [x, y]
var entrance_cell: Array # [x, y]
var monster_spawns: Array # Array[Dictionary] {monster_id, cell:[x,y], respawn_seconds}
var miniboss_spawn: Dictionary # {monster_id, cell:[x,y]} or {} if none
var boss_spawn: Dictionary # {monster_id, cell:[x,y]} or {} if none
var item_spawns: Array # Array[Dictionary] {item_id, cell:[x,y]}
## {cell:[x,y], requires_item OR requires_flag, locked_text}. A cell that
## looks walkable (it's not in blocked_cells, so terrain/tile rendering
## treats it normally) but overworld.gd's move_player refuses to cross
## until the player holds `requires_item` (RunState.inventory count > 0)
## or the district has `requires_flag` set (same flags puzzle events set
## via sets_flag) - exactly one of the two per entry, not both. Doesn't
## consume the key item; possessing it is a permanent unlock, matching
## "you found the key" rather than "you used up the key". The generic
## navigation-gating primitive behind locked doors/gates, distinct from
## events' requires_flag (which gates a one-time text/reward, not passage).
var locked_cells: Array # Array[Dictionary]
## {cell:[x,y], text, repeatable}. Optional gating/reward fields turn a
## plain flavor event into a chained puzzle step (see overworld.gd's
## _maybe_fire_event): requires_flag (only fires once that district flag
## is set elsewhere, otherwise logs fail_text instead and never marks
## itself fired, so it can be retried), sets_flag (marks a district flag
## true when this event fires, for a later event's requires_flag to read),
## reward_item (an item id granted via RunState.add_item the first time
## this event successfully fires).
var events: Array # Array[Dictionary]

## Optional visual terrain: one string per row (top to bottom), one
## legend character per column - see overworld.gd's TERRAIN_LEGEND. Purely
## cosmetic; collision always comes from blocked_cells regardless of what
## a cell's terrain character says. Empty (the default for every district
## that hasn't been authored yet) means "no tile art yet" and overworld.gd
## falls back to its plain colored-grid rendering, the same fallback
## pattern used for character/monster sprites.
var terrain: Array # Array[String]

static func from_dict(data: Dictionary) -> DistrictData:
	var d := DistrictData.new()
	d.id = data.get("id", "")
	d.display_name = data.get("display_name", "???")
	d.description = data.get("description", "")
	d.danger_tier = data.get("danger_tier", "F")
	d.kind = data.get("kind", "district")
	d.grid_width = data.get("grid_width", 12)
	d.grid_height = data.get("grid_height", 8)

	d.blocked_cells = []
	for cell in data.get("blocked_cells", []):
		d.blocked_cells.append(cell)

	d.entrance_cell = data.get("entrance_cell", [0, 0])

	d.monster_spawns = []
	for spawn in data.get("monster_spawns", []):
		d.monster_spawns.append(spawn)

	d.miniboss_spawn = data.get("miniboss_spawn", {})
	d.boss_spawn = data.get("boss_spawn", {})

	d.item_spawns = []
	for spawn in data.get("item_spawns", []):
		d.item_spawns.append(spawn)

	d.locked_cells = []
	for lock in data.get("locked_cells", []):
		d.locked_cells.append(lock)

	d.events = []
	for event in data.get("events", []):
		d.events.append(event)

	d.terrain = []
	for row in data.get("terrain", []):
		d.terrain.append(String(row))

	return d
