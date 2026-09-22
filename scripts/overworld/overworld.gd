extends Control

## A district/dungeon/dimension explored as a simple fixed-size grid.
## Movement is grid-step (one cell per key press), not free/continuous.
##
## Ground rendering has two paths: if the district defines `terrain`
## (DistrictData.terrain - a legend string per row, see TERRAIN_LEGEND
## below), it's drawn as a real TileMap using the generated flood-city
## tileset (tools/gen_tiles.py / TileLoader). If not, it falls back to the
## original plain colored-rect-per-cell rendering - the same "safe
## fallback for content that hasn't been authored yet" pattern used for
## character/monster sprites. Collision is always driven by
## blocked_cells regardless of which rendering path is active or what a
## cell's terrain character says - terrain is purely cosmetic.
##
## Known limitation: there's no camera/scroll system yet, so a district
## much bigger than the viewport (480x460 minus the HUD bands) will run
## off the edges. Sukhumvit Shallows (10x8) fits; this needs solving
## before bigger districts get tile art. Flagged in GDD.md's roadmap.
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

const CELL_SIZE := 40
const TOP_HUD_HEIGHT := 46
const BOTTOM_HUD_HEIGHT := 80
const VIEWPORT_WIDTH := 480
const VIEWPORT_HEIGHT := 460
const DEFAULT_DISTRICT_ID := "sukhumvit_shallows"
const DEFAULT_CLASS_ID := "mage_f"
const PLAYER_SPRITE_SCALE := 0.55 # native sprites are 64px; ~35px on-screen in a 40px cell
const MONSTER_SPRITE_SCALE := 0.53

## Purely cosmetic terrain legend -> TileLoader tile name. Any character
## not in this map (or a district with no `terrain` at all) falls back to
## the flat-color grid. Blocked cells always render as "rubble" regardless
## of their terrain character - see _tile_name_for_cell.
const TERRAIN_LEGEND := {
	"s": "shallow_water",
	"w": "deep_water",
	"p": "wet_pavement",
	"r": "rubble",
}

var district_id: String
var district: DistrictData
var player_cell: Vector2i
var grid_offset: Vector2

var active_monster_spawns: Dictionary = {} # spawn_key -> {monster_id, cell, respawn_seconds, is_unique}
var active_items: Dictionary = {} # spawn_key -> {item_id, cell}

var monster_visuals: Dictionary = {} # spawn_key -> Node
var item_visuals: Dictionary = {} # spawn_key -> Node
var event_visuals: Dictionary = {} # spawn_key -> Node

var grid_root: Node2D
var player_visual: Node
var minimap: Minimap

var name_label: Label
var desc_label: Label
var player_stat_label: Label
var hp_bar: ProgressBar
var resource_bar: ProgressBar
var deck_label: Label
var log_label: RichTextLabel
var inventory_container: HBoxContainer
var status_menu: StatusMenu

func _ready() -> void:
	if RunState.player == null:
		RunState.begin_run(DEFAULT_CLASS_ID)

	district_id = RunState.pending_district_id if RunState.pending_district_id != "" else DEFAULT_DISTRICT_ID
	RunState.pending_district_id = district_id
	district = GameData.get_district(district_id)
	player_cell = Vector2i(district.entrance_cell[0], district.entrance_cell[1])
	grid_offset = Vector2(
		(VIEWPORT_WIDTH - district.grid_width * CELL_SIZE) / 2.0,
		TOP_HUD_HEIGHT,
	)

	_build_ui()

	if RunState.last_battle_outcome != "":
		_process_battle_result()

	_build_grid()
	_spawn_entities()
	_update_player_visual()
	_refresh_status()
	_log_message("[Arrows] Move   [Esc] Status/Items menu")

func _process(_delta: float) -> void:
	_check_respawns()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	grid_root = Node2D.new()
	add_child(grid_root)

	# --- Top band: district name/description banner (left) + minimap (right).
	name_label = Label.new()
	name_label.position = Vector2(8, 2)
	name_label.add_theme_font_size_override("font_size", 14)
	add_child(name_label)

	desc_label = Label.new()
	desc_label.position = Vector2(8, 20)
	desc_label.size = Vector2(340, 18)
	desc_label.add_theme_font_size_override("font_size", 9)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.clip_text = true
	add_child(desc_label)

	minimap = Minimap.new()
	minimap.setup(district)
	minimap.position = Vector2(VIEWPORT_WIDTH - minimap.custom_minimum_size.x - 8, 4)
	add_child(minimap)

	# --- Bottom band: name/rank + deck count, HP/resource bars, log, items.
	var bottom := VBoxContainer.new()
	bottom.position = Vector2(8, VIEWPORT_HEIGHT - BOTTOM_HUD_HEIGHT)
	bottom.size = Vector2(VIEWPORT_WIDTH - 16, BOTTOM_HUD_HEIGHT - 4)
	bottom.add_theme_constant_override("separation", 2)
	add_child(bottom)

	var top_row := HBoxContainer.new()
	bottom.add_child(top_row)
	player_stat_label = Label.new()
	player_stat_label.add_theme_font_size_override("font_size", 10)
	player_stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(player_stat_label)
	deck_label = Label.new()
	deck_label.add_theme_font_size_override("font_size", 10)
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(deck_label)

	var bars_row := HBoxContainer.new()
	bars_row.add_theme_constant_override("separation", 6)
	bottom.add_child(bars_row)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(220, 10)
	hp_bar.show_percentage = false
	bars_row.add_child(hp_bar)
	resource_bar = ProgressBar.new()
	resource_bar.custom_minimum_size = Vector2(120, 10)
	resource_bar.show_percentage = false
	bars_row.add_child(resource_bar)

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 18)
	log_label.bbcode_enabled = true
	log_label.add_theme_font_size_override("normal_font_size", 10)
	bottom.add_child(log_label)

	inventory_container = HBoxContainer.new()
	inventory_container.add_theme_constant_override("separation", 4)
	bottom.add_child(inventory_container)

	status_menu = StatusMenu.new()
	add_child(status_menu)

func _build_grid() -> void:
	# remove_child (synchronous) before queue_free (deferred delete) so a
	# same-frame rebuild doesn't briefly see stale children alongside the
	# new ones - see combat.gd's card_grid refresh for the same fix.
	for child in grid_root.get_children():
		grid_root.remove_child(child)
		child.queue_free()

	if not district.terrain.is_empty() and TileLoader.has_tileset():
		_build_tile_grid()
	else:
		_build_flat_grid()

	player_visual = SpriteLoader.build_sprite(RunState.player_class_id, "character", Color(1, 1, 1), Vector2(CELL_SIZE - 6, CELL_SIZE - 6), PLAYER_SPRITE_SCALE)
	grid_root.add_child(player_visual)

func _tile_name_for_cell(cell: Vector2i) -> String:
	if _is_blocked(cell):
		return "rubble"
	var row: String = district.terrain[cell.y] if cell.y < district.terrain.size() else ""
	var ch: String = row[cell.x] if cell.x < row.length() else "s"
	return TERRAIN_LEGEND.get(ch, "shallow_water")

func _build_tile_grid() -> void:
	var tile_map := TileMap.new()
	tile_map.position = grid_offset
	tile_map.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tile_map.tile_set = TileLoader.build_tileset()
	for y in district.grid_height:
		for x in district.grid_width:
			var cell := Vector2i(x, y)
			var atlas: Vector2i = TileLoader.atlas_coords_for(_tile_name_for_cell(cell))
			tile_map.set_cell(0, cell, 0, atlas)
	grid_root.add_child(tile_map)

func _build_flat_grid() -> void:
	for y in district.grid_height:
		for x in district.grid_width:
			var cell := Vector2i(x, y)
			var rect := ColorRect.new()
			rect.size = Vector2(CELL_SIZE - 1, CELL_SIZE - 1)
			rect.position = grid_offset + Vector2(x * CELL_SIZE, y * CELL_SIZE)
			rect.color = Color(0.15, 0.2, 0.3) if _is_blocked(cell) else Color(0.2, 0.35, 0.45)
			grid_root.add_child(rect)

func _cell_key(cell) -> String:
	if cell is Vector2i:
		return "%d_%d" % [cell.x, cell.y]
	return "%d_%d" % [cell[0], cell[1]]

func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return grid_offset + Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

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

	_refresh_minimap_markers()

func _refresh_minimap_markers() -> void:
	var markers: Array[Vector2i] = []
	for key in [_cell_key(district.miniboss_spawn.get("cell", [-1, -1])), _cell_key(district.boss_spawn.get("cell", [-1, -1]))]:
		if active_monster_spawns.has(key):
			var cell: Array = active_monster_spawns[key]["cell"]
			markers.append(Vector2i(cell[0], cell[1]))
	minimap.set_markers(markers)

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
	var visual := SpriteLoader.build_sprite(entry["monster_id"], "monster", fallback_color, Vector2(CELL_SIZE - 10, CELL_SIZE - 10), MONSTER_SPRITE_SCALE)
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
	rect.size = Vector2(CELL_SIZE - 20, CELL_SIZE - 20)
	rect.color = Color(0.9, 0.85, 0.2)
	rect.position = _cell_to_pixel(Vector2i(spawn["cell"][0], spawn["cell"][1])) + Vector2(10, 10)
	grid_root.add_child(rect)
	item_visuals[key] = rect

func _create_event_visual(key: String, event: Dictionary) -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(8, 8)
	rect.color = Color(0.7, 0.3, 0.9)
	rect.position = _cell_to_pixel(Vector2i(event["cell"][0], event["cell"][1])) + Vector2(4, 4)
	grid_root.add_child(rect)
	event_visuals[key] = rect

func _update_player_visual() -> void:
	if player_visual != null:
		_position_visual_at_cell(player_visual, player_cell)
	if minimap != null:
		minimap.update_player(player_cell)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if status_menu.visible:
			status_menu.close()
		else:
			status_menu.open()
		return
	if status_menu.visible:
		return
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
	if not newly_alive.is_empty():
		_refresh_minimap_markers()

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
	var cls := GameData.get_class_by_id(RunState.player_class_id)

	name_label.text = district.display_name
	desc_label.text = district.description

	player_stat_label.text = "%s (%s)  |  HP %d/%d  |  %s %d/%d" % [
		p.display_name, cls.rank if cls != null else "?",
		p.hp, p.max_hp, p.resource_name, p.resource, p.max_resource,
	]
	deck_label.text = "Deck: %d cards" % (cls.deck.size() if cls != null else 0)

	hp_bar.max_value = p.max_hp
	hp_bar.value = p.hp
	resource_bar.max_value = max(p.max_resource, 1)
	resource_bar.value = p.resource

	for child in inventory_container.get_children():
		inventory_container.remove_child(child)
		child.queue_free()
	for item_id in RunState.inventory.keys():
		var count: int = RunState.inventory[item_id]
		if count <= 0:
			continue
		var item := GameData.get_item(item_id)
		if item == null:
			continue
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 9)
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
