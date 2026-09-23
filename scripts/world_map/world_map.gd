extends Control

## The travel hub between districts (GDD.md's "the main structural piece
## standing between one working district and an actual game you play
## through"). Lists every district in RunState.DISTRICT_ORDER, in tier
## order: unlocked ones are real buttons that drop straight into that
## district's entrance; locked ones are disabled with a short reason.
## Defeating a district's boss unlocks the next entry (see
## RunState.unlock_next_district, called from Overworld._process_battle_result).
##
## Reached from the main menu's "Start Exploring" (a fresh run) or the
## status menu's "World Map" button (leaving mid-run, same as the [DEV]
## shortcuts, just gated by progress instead of always-open). "Continue"
## on the main menu bypasses this entirely and resumes at the exact saved
## district/cell, matching its existing "pick up exactly where you left
## off" contract.

const VIEWPORT_WIDTH := 480
const VIEWPORT_HEIGHT := 460

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UITheme.build()

	var backdrop := ColorRect.new()
	backdrop.color = UITheme.COL_BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 16)
	add_child(margin)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 10)
	margin.add_child(root_box)

	var title := Label.new()
	title.text = "WORLD MAP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UITheme.COL_WARNING)
	root_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Bangkok, flooded. Clear a district's boss to open the next."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_color_override("font_color", UITheme.COL_TEXT_DIM)
	root_box.add_child(subtitle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_box.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

	for i in RunState.DISTRICT_ORDER.size():
		var district_id: String = RunState.DISTRICT_ORDER[i]
		list.add_child(_build_district_row(district_id, i))

	var back_button := Button.new()
	back_button.text = "Back to Main Menu"
	back_button.pressed.connect(_on_back_pressed)
	root_box.add_child(back_button)

func _build_district_row(district_id: String, index: int) -> Control:
	var district: DistrictData = GameData.get_district(district_id)
	var unlocked: bool = RunState.is_district_unlocked(district_id)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.panel_style(
		UITheme.COL_WARNING if unlocked else UITheme.COL_PANEL_BORDER
	))

	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	panel.add_child(row)

	var header := Label.new()
	header.text = "District %d: %s  (Danger %s)" % [index + 1, district.display_name, district.danger_tier]
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", UITheme.COL_TEXT if unlocked else UITheme.COL_TEXT_DIM)
	row.add_child(header)

	if unlocked:
		var desc := Label.new()
		desc.text = district.description
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 9)
		desc.add_theme_color_override("font_color", UITheme.COL_TEXT_DIM)
		row.add_child(desc)

		var enter_button := Button.new()
		enter_button.text = "Enter"
		enter_button.pressed.connect(_on_enter_pressed.bind(district_id))
		row.add_child(enter_button)
	else:
		var locked_label := Label.new()
		locked_label.text = "Locked - defeat District %d's boss to open this." % index
		locked_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		locked_label.add_theme_font_size_override("font_size", 9)
		locked_label.add_theme_color_override("font_color", UITheme.COL_TEXT_DIM)
		row.add_child(locked_label)

	return panel

func _on_enter_pressed(district_id: String) -> void:
	if RunState.player == null:
		RunState.begin_run("mage_f")
	RunState.pending_district_id = district_id
	RunState.pending_player_cell = Vector2i(-1, -1) # always the entrance, never a stale cell from elsewhere
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
