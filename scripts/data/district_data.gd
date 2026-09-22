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
var events: Array # Array[Dictionary] {cell:[x,y], text, repeatable}

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

	d.events = []
	for event in data.get("events", []):
		d.events.append(event)

	return d
