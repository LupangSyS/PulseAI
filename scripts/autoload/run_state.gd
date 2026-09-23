extends Node

## Autoload singleton (see project.godot [autoload]). Bridges state across
## the Overworld <-> Combat scene transitions: change_scene_to_file()
## destroys the old scene tree, so anything that needs to survive a fight
## (the player's HP, which district/spawn triggered the fight, per-district
## exploration progress) has to live here instead of as a direct reference.

var player: Combatant = null
var player_class_id: String = ""

## Set by Overworld before transitioning into combat.
var pending_district_id: String = ""
var pending_monster_id: String = ""
var pending_spawn_key: String = ""

## Set by Combat before transitioning back; read (and left for Overworld
## to clear/consume) on return.
var last_battle_outcome: String = "" # "victory" | "defeat" | ""
var last_battle_loot: Array = []

## Persistent per-district exploration state, keyed by district_id, each:
## {
##   "defeated_spawns": {spawn_key: respawn_at_msec}, # -1 = never respawns (mini-boss/boss)
##   "collected_items": {spawn_key: true},
##   "fired_events": {spawn_key: true},
##   "flags": {flag_name: true}, # set by events with sets_flag, read by events with requires_flag
## }
var district_states: Dictionary = {}

## item_id -> count. Simple by design (see ItemData's doc comment) - no
## equipment/slots system yet, just a collected-count per item.
var inventory: Dictionary = {}

func add_item(item_id: String, count: int = 1) -> void:
	inventory[item_id] = inventory.get(item_id, 0) + count

func get_district_state(district_id: String) -> Dictionary:
	if not district_states.has(district_id):
		district_states[district_id] = {
			"defeated_spawns": {},
			"collected_items": {},
			"fired_events": {},
			"flags": {},
		}
	return district_states[district_id]

## Starts a fresh run as the given class: a new player Combatant and no
## exploration progress. Call once when a save/new-game flow exists; for
## now the main menu's dev entry point calls it directly.
func begin_run(class_id: String) -> void:
	player_class_id = class_id
	var cls := GameData.get_class_by_id(class_id)
	player = Combatant.new(cls.display_name, cls.max_hp, cls.max_resource, cls.resource_name)
	district_states.clear()
	inventory.clear()

# ---------------------------------------------------------------------------
# Save / load (single slot, user://saves/slot1.json)
# ---------------------------------------------------------------------------
## Consumed once by Overworld._ready() after a load, to resume at the exact
## saved cell instead of the district's entrance_cell. (-1, -1) means "no
## override" - a fresh "Start Exploring"/"[DEV] ..." run leaves this unset.
var pending_player_cell: Vector2i = Vector2i(-1, -1)

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/slot1.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Called from the overworld (the only place a save makes sense - mid-combat
## or mid-menu isn't a resumable moment) with where the player currently is.
func save_game(district_id: String, player_cell: Vector2i) -> void:
	DirAccess.make_dir_absolute(SAVE_DIR)
	var data := {
		"player_class_id": player_class_id,
		"player_hp": player.hp,
		"player_resource": player.resource,
		"inventory": inventory,
		"district_id": district_id,
		"player_cell": [player_cell.x, player_cell.y],
		"district_states": _serialize_district_states(),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

## defeated_spawns' respawn_at is an *absolute* Time.get_ticks_msec() value,
## which resets to ~0 every process start - saving it raw and reloading in a
## later session would make every timed-out spawn respawn instantly (or at
## some arbitrary wrong time). Store the *remaining* milliseconds instead
## (converted back to an absolute value against the new process's tick
## clock in load_game), so "this spawn had 12s left on its timer" survives
## the save/load boundary regardless of real-world time elapsed. -1 (never
## respawns - a defeated mini-boss/boss) passes through unchanged.
func _serialize_district_states() -> Dictionary:
	var out := {}
	var now: int = Time.get_ticks_msec()
	for did in district_states.keys():
		var state: Dictionary = district_states[did]
		var defeated_out := {}
		for key in state["defeated_spawns"].keys():
			var respawn_at = state["defeated_spawns"][key]
			defeated_out[key] = -1 if respawn_at == -1 else max(0, respawn_at - now)
		out[did] = {
			"defeated_spawns": defeated_out,
			"collected_items": state["collected_items"],
			"fired_events": state["fired_events"],
			"flags": state["flags"],
		}
	return out

## Returns {} on any failure (no save file, corrupt JSON), else
## {"district_id": String, "player_cell": Vector2i} for the caller to act
## on - loading itself doesn't change scenes, matching begin_run's existing
## "just sets state" contract.
func load_game() -> Dictionary:
	if not has_save():
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text: String = f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if data == null or typeof(data) != TYPE_DICTIONARY:
		return {}

	begin_run(String(data.get("player_class_id", "mage_f")))
	player.hp = int(data.get("player_hp", player.hp))
	player.resource = int(data.get("player_resource", player.resource))
	inventory = data.get("inventory", {})

	var now: int = Time.get_ticks_msec()
	var loaded_states: Dictionary = data.get("district_states", {})
	district_states.clear()
	for did in loaded_states.keys():
		var s: Dictionary = loaded_states[did]
		var defeated_in: Dictionary = s.get("defeated_spawns", {})
		var defeated_out := {}
		for key in defeated_in.keys():
			var v = defeated_in[key]
			defeated_out[key] = -1 if int(v) == -1 else now + int(v)
		district_states[did] = {
			"defeated_spawns": defeated_out,
			"collected_items": s.get("collected_items", {}),
			"fired_events": s.get("fired_events", {}),
			"flags": s.get("flags", {}),
		}

	var cell_arr: Array = data.get("player_cell", [0, 0])
	return {
		"district_id": String(data.get("district_id", "sukhumvit_shallows")),
		"player_cell": Vector2i(int(cell_arr[0]), int(cell_arr[1])),
	}
