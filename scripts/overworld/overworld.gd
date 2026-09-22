extends Control

## A district/dungeon/dimension explored as a simple fixed-size grid (no
## hand-authored TileMap/TileSet resource - Godot's tile resource format is
## intricate enough that hand-writing it correctly without the editor's
## visual tool would be a real risk; a grid of plain ColorRects is far
## safer to get right blind and is exactly as functionally testable).
## Movement is grid-step (one cell per key press), not free/continuous.
##
## All state that needs to survive the Overworld <-> Combat scene
## transition (change_scene_to_file destroys this scene entirely) lives on
## the RunState autoload: RunState.get_district_state(district_id) holds
## which monster spawns are dead-and-respawning vs permanently gone
## (mini-bosses/bosses), which items are already collected, and which
## events have already fired.
##
## Movement/collision/encounter/pickup logic is exposed as public methods
## (move_player, _collect_item, etc. - "private" only by convention) so it
## can be driven directly from a test script exactly like combat.gd's
## _on_card_pressed, without needing to simulate real input events.

const CELL_SIZE := 24
const GRID_OFFSET := Vector2(8, 8)
const DEFAULT_DISTRICT_ID := "sukhumvit_shallows"
const DEFAULT_CLASS_ID := "mage_f"
const PLAYER_SPRITE_SCALE := 0.875 # native sprites are 32px; displays ~28px
const MONSTER_SPRITE_SCALE := 0.75 # ~24px, matches CELL_SIZE

var district_id: String
var district: DistrictData
var player_cell: Vector2i

var active_monster_spawns: Dictionary = {} # spawn_key -> {monster_id, cell, respawn_seconds, is_unique}
var active_items: Dictionary = {} # spawn_key -> {item_id, cell}

var monster_visuals: Dictionary = {} # spawn_key -> Node
var item_visuals: Dictionary = {} # spawn_key -> Node
var event_visuals: Dictionary = {} # spawn_key -> Node

var grid_root: Node2D
var player_visual: Node
var status_label: Label
var log_label: RichTextLabel
var inventory_container: HBoxContainer

func _ready() -> void:
	if RunState.player == null:
		RunState.begin_run(DEFAULT_CLASS_ID)

	district_id = RunState.pending_district_id if RunState.pending_district_id != "" else DEFAULT_DISTRICT_ID
	RunState.pending_district_id = district_id
	district = GameData.get_district(district_id)
	player_cell = Vector2i(district.entrance_cell[0], district.entrance_cell[1])

	_build_ui()

	if RunState.last_battle_outcome != "":
		_process_battle_result()

	_build_grid()
	_spawn_entities()
	_update_player_visual()
	_refresh_status()

func _process(_delta: float) -> void:
	_check_respawns()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	grid_root = Node2D.new()
	add_child(grid_root)

	var side_panel := VBoxContainer.new()
	side_panel.position = Vector2(GRID_OFFSET.x, 210)
	side_panel.size = Vector2(464, 60)
	side_panel.add_theme_constant_override("separation", 4)
	add_child(side_panel)

	status_label = Label.new()
	side_panel.add_child(status_label)

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 24)
	log_label.bbcode_enabled = true
	side_panel.add_child(log_label)

	inventory_container = HBoxContainer.new()
	inventory_container.add_theme_constant_override("separation", 6)
	side_panel.add_child(inventory_container)

func _build_grid() -> void:
	for child in grid_root.get_children():
		child.queue_free()

	for y in district.grid_height:
		for x in district.grid_width:
			var cell := Vector2i(x, y)
			var rect := ColorRect.new()
			rect.size = Vector2(CELL_SIZE - 1, CELL_SIZE - 1)
			rect.position = GRID_OFFSET + Vector2(x * CELL_SIZE, y * CELL_SIZE)
			rect.color = Color(0.15, 0.2, 0.3) if _is_blocked(cell) else Color(0.2, 0.35, 0.45)
			grid_root.add_child(rect)

	player_visual = SpriteLoader.build_sprite(RunState.player_class_id, "character", Color(1, 1, 1), Vector2(CELL_SIZE - 6, CELL_SIZE - 6), PLAYER_SPRITE_SCALE)
	grid_root.add_child(player_visual)

func _cell_key(cell) -> String:
	if cell is Vector2i:
		return "%d_%d" % [cell.x, cell.y]
	return "%d_%d" % [cell[0], cell[1]]

func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return GRID_OFFSET + Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func _is_blocked(cell: Vector2i) -> bool:
	for b in district.blocked_cells:
		if b[0] == cell.x and b[1] == cell.y:
			return true
	return false

func _all_monster_entries() -> Array:
	var entries: Array = []
	for spawn in district.monster_spawns:
		entries.append({"monster_id": spawn["monster_id"], "cell": spawn["cell"], "respawn_seconds": spawn.get("respawn_seconds", 30), "is_unique": false})
	if not district.miniboss_spawn.is_empty():
		entries.append({"monster_id": district.miniboss_spawn["monster_id"], "cell": district.miniboss_spawn["cell"], "respawn_seconds": 0, "is_unique": true})
	if not district.boss_spawn.is_empty():
		entries.append({"monster_id": district.boss_spawn["monster_id"], "cell": district.boss_spawn["cell"], "respawn_seconds": 0, "is_unique": true})
	return entries

func _spawn_entities() -> void:
	var state: Dictionary = RunState.get_district_state(district_id)

	for v in monster_visuals.values():
		v.queue_free()
	monster_visuals.clear()
	active_monster_spawns.clear()

	for entry in _all_monster_entries():
		var key: String = _cell_key(entry["cell"])
		if _spawn_is_dead(state, key):
			continue
		active_monster_spawns[key] = entry
		_create_monster_visual(key, entry)

	for v in item_visuals.values():
		v.queue_free()
	item_visuals.clear()
	active_items.clear()

	for spawn in district.item_spawns:
		var key: String = _cell_key(spawn["cell"])
		if state["collected_items"].has(key):
			continue
		active_items[key] = spawn
		_create_item_visual(key, spawn)

	for v in event_visuals.values():
		v.queue_free()
	event_visuals.clear()
	for event in district.events:
		var key: String = _cell_key(event["cell"])
		if state["fired_events"].has(key) and not event.get("repeatable", false):
			continue
		_create_event_visual(key, event)

func _spawn_is_dead(state: Dictionary, key: String) -> bool:
	if not state["defeated_spawns"].has(key):
		return false
	var respawn_at = state["defeated_spawns"][key]
	if respawn_at == -1:
		return true
	return Time.get_ticks_msec() < respawn_at

func _create_monster_visual(key: String, entry: Dictionary) -> void:
	var monster := GameData.get_monster(entry["monster_id"])
	var fallback_color := Color(0.8, 0.2, 0.2)
	if monster != null and monster.is_boss:
		fallback_color = Color(0.6, 0.1, 0.5)
	elif monster != null and monster.is_miniboss:
		fallback_color = Color(0.9, 0.5, 0.1)
	var visual := SpriteLoader.build_sprite(entry["monster_id"], "monster", fallback_color, Vector2(CELL_SIZE - 8, CELL_SIZE - 8), MONSTER_SPRITE_SCALE)
	grid_root.add_child(visual)
	_position_visual_at_cell(visual, Vector2i(entry["cell"][0], entry["cell"][1]))
	monster_visuals[key] = visual

## Positions either node type this scene ever creates at the given cell:
## AnimatedSprite2D draws centered on its position, ColorRect draws from
## its position as a top-left corner - this normalizes both to "centered
## in the cell" so callers don't need to care which one a spawn resolved to.
func _position_visual_at_cell(visual: Node, cell: Vector2i) -> void:
	var cell_center: Vector2 = _cell_to_pixel(cell) + Vector2(CELL_SIZE, CELL_SIZE) / 2.0
	if visual is Node2D:
		visual.position = cell_center
	else:
		visual.position = cell_center - visual.size / 2.0

func _create_item_visual(key: String, spawn: Dictionary) -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(CELL_SIZE - 12, CELL_SIZE - 12)
	rect.color = Color(0.9, 0.85, 0.2)
	rect.position = _cell_to_pixel(Vector2i(spawn["cell"][0], spawn["cell"][1])) + Vector2(6, 6)
	grid_root.add_child(rect)
	item_visuals[key] = rect

func _create_event_visual(key: String, event: Dictionary) -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(6, 6)
	rect.color = Color(0.7, 0.3, 0.9)
	rect.position = _cell_to_pixel(Vector2i(event["cell"][0], event["cell"][1])) + Vector2(2, 2)
	grid_root.add_child(rect)
	event_visuals[key] = rect

func _update_player_visual() -> void:
	if player_visual != null:
		_position_visual_at_cell(player_visual, player_cell)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		move_player(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"):
		move_player(Vector2i(0, 1))
	elif event.is_action_pressed("ui_left"):
		move_player(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		move_player(Vector2i(1, 0))

## Attempts to move the player one cell in `direction`. Returns a string
## describing what happened ("moved" | "blocked_bounds" | "blocked_wall" |
## "encounter") so both the caller and tests can react to it.
func move_player(direction: Vector2i) -> String:
	var new_cell: Vector2i = player_cell + direction
	if new_cell.x < 0 or new_cell.x >= district.grid_width or new_cell.y < 0 or new_cell.y >= district.grid_height:
		return "blocked_bounds"
	if _is_blocked(new_cell):
		return "blocked_wall"

	var key: String = _cell_key(new_cell)
	if active_monster_spawns.has(key):
		_start_encounter(key)
		return "encounter"

	player_cell = new_cell
	_update_player_visual()

	if active_items.has(key):
		_collect_item(key)

	_maybe_fire_event(key)
	_refresh_status()
	return "moved"

func _start_encounter(spawn_key: String) -> void:
	var entry: Dictionary = active_monster_spawns[spawn_key]
	RunState.pending_district_id = district_id
	RunState.pending_monster_id = entry["monster_id"]
	RunState.pending_spawn_key = spawn_key
	get_tree().change_scene_to_file("res://scenes/combat.tscn")

func _process_battle_result() -> void:
	var spawn_key: String = RunState.pending_spawn_key
	var state: Dictionary = RunState.get_district_state(district_id)

	if RunState.last_battle_outcome == "victory" and spawn_key != "":
		var entry: Dictionary = {}
		for e in _all_monster_entries():
			if _cell_key(e["cell"]) == spawn_key:
				entry = e
				break
		if entry.get("is_unique", false):
			state["defeated_spawns"][spawn_key] = -1
			_log_message("The threat is gone for good.")
		else:
			var respawn_seconds: float = entry.get("respawn_seconds", 30)
			state["defeated_spawns"][spawn_key] = Time.get_ticks_msec() + int(respawn_seconds * 1000)
			_log_message("Defeated. Something else will eventually take its place.")
		for item_id in RunState.last_battle_loot:
			RunState.add_item(item_id)
			var item := GameData.get_item(item_id)
			if item != null:
				_log_message("Picked up %s." % item.display_name)

	RunState.last_battle_outcome = ""
	RunState.last_battle_loot = []
	RunState.pending_monster_id = ""
	RunState.pending_spawn_key = ""

func _collect_item(spawn_key: String) -> void:
	var state: Dictionary = RunState.get_district_state(district_id)
	if state["collected_items"].has(spawn_key):
		return
	state["collected_items"][spawn_key] = true
	var spawn: Dictionary = active_items[spawn_key]
	var item_id: String = spawn["item_id"]
	RunState.add_item(item_id)
	active_items.erase(spawn_key)
	if item_visuals.has(spawn_key):
		item_visuals[spawn_key].queue_free()
		item_visuals.erase(spawn_key)
	var item := GameData.get_item(item_id)
	_log_message("Picked up %s." % (item.display_name if item != null else item_id))
	_refresh_status()

func _maybe_fire_event(cell_key: String) -> void:
	var event: Dictionary = {}
	for e in district.events:
		if _cell_key(e["cell"]) == cell_key:
			event = e
			break
	if event.is_empty():
		return
	var state: Dictionary = RunState.get_district_state(district_id)
	var already_fired: bool = state["fired_events"].has(cell_key)
	if already_fired and not event.get("repeatable", false):
		return
	state["fired_events"][cell_key] = true
	_log_message(event.get("text", ""))

func _check_respawns() -> void:
	var state: Dictionary = RunState.get_district_state(district_id)
	var now: int = Time.get_ticks_msec()
	var newly_alive: Array = []
	for key in state["defeated_spawns"].keys():
		var respawn_at = state["defeated_spawns"][key]
		if respawn_at == -1:
			continue
		if now >= respawn_at and not active_monster_spawns.has(key):
			newly_alive.append(key)
	for key in newly_alive:
		state["defeated_spawns"].erase(key)
		for entry in _all_monster_entries():
			if _cell_key(entry["cell"]) == key:
				active_monster_spawns[key] = entry
				_create_monster_visual(key, entry)
				break

func _use_item(item_id: String) -> void:
	if not RunState.inventory.has(item_id) or RunState.inventory[item_id] <= 0:
		return
	var item := GameData.get_item(item_id)
	if item == null or item.effect == "":
		return
	match item.effect:
		"heal":
			RunState.player.heal(item.value)
		"restore_resource":
			RunState.player.resource = min(RunState.player.resource + item.value, RunState.player.max_resource)
	RunState.inventory[item_id] -= 1
	if RunState.inventory[item_id] <= 0:
		RunState.inventory.erase(item_id)
	_refresh_status()

func _refresh_status() -> void:
	var p: Combatant = RunState.player
	status_label.text = "%s  |  %s  |  HP %d/%d  |  %s %d/%d" % [
		district.display_name, p.display_name, p.hp, p.max_hp, p.resource_name, p.resource, p.max_resource,
	]

	for child in inventory_container.get_children():
		child.queue_free()
	for item_id in RunState.inventory.keys():
		var count: int = RunState.inventory[item_id]
		if count <= 0:
			continue
		var item := GameData.get_item(item_id)
		if item == null:
			continue
		var button := Button.new()
		button.text = "%s x%d" % [item.display_name, count]
		if item.effect != "":
			button.pressed.connect(_use_item.bind(item_id))
		else:
			button.disabled = true
		inventory_container.add_child(button)

func _log_message(message: String) -> void:
	if message == "":
		return
	log_label.append_text(message + "\n")
