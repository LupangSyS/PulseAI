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
