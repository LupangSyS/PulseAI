extends Control

## Main menu. Every class in data/classes.json currently has is_hidden = true
## by design (see GDD.md) - so the codex summary below never names a class,
## only counts them, until a real discovery/unlock system exists.
##
## "Start Exploring" begins a fresh run and drops into the World Map
## (scripts/world_map/world_map.gd), which lists every built district in
## tier order - only Sukhumvit Shallows starts unlocked; defeating a
## district's boss unlocks the next one (RunState.unlock_next_district).
## "Continue" only appears when RunState.has_save() is true (a single save
## slot - status_menu.gd's "Save Game" button writes it) and bypasses the
## World Map entirely, resuming at the exact saved district/cell via
## RunState.pending_player_cell, consumed once by Overworld._ready().
##
## "[DEV] Enter the Flood" / "[DEV] Chatuchak Ruins" / "[DEV] Klong Toey
## Canals" / "[DEV] Wat Hualamphong Depths" are developer shortcuts straight
## into an isolated test battle or a specific district, bypassing both the
## World Map and its unlock gating entirely - kept for quick balance
## testing, not part of the real progression loop.

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UITheme.build()

	var backdrop := ColorRect.new()
	backdrop.color = UITheme.COL_BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.panel_style(UITheme.COL_PANEL_BORDER))
	center.add_child(panel)

	# Capped to fit the 480-wide base canvas (see project.godot's
	# viewport_width) with margin either side - a PanelContainer/VBoxContainer
	# otherwise sizes to its widest natural content, and these button labels
	# are long enough to overflow the screen if left unconstrained.
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(440, 0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)

	var title := Label.new()
	title.text = "DELUGE CHRONICLES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UITheme.COL_WARNING)
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Bangkok, 2035. The water remembers what the surface forgot."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_color_override("font_color", UITheme.COL_TEXT_DIM)
	box.add_child(subtitle)

	var codex_label := Label.new()
	codex_label.text = _build_codex_text()
	codex_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	codex_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_label.add_theme_color_override("font_color", UITheme.COL_TEXT_DIM)
	box.add_child(codex_label)

	if RunState.has_save():
		var continue_button := _make_menu_button("Continue (resume your saved run)")
		continue_button.pressed.connect(_on_continue_pressed)
		box.add_child(continue_button)

	var explore_button := _make_menu_button("Start Exploring (World Map, as the Apprentice Mage)")
	explore_button.pressed.connect(_on_explore_pressed)
	box.add_child(explore_button)

	var start_button := _make_menu_button("[DEV] Enter the Flood - Test Combat (Apprentice Mage)")
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

	var chatuchak_button := _make_menu_button("[DEV] Chatuchak Ruins - Test District 2 (Apprentice Mage)")
	chatuchak_button.pressed.connect(_on_chatuchak_pressed)
	box.add_child(chatuchak_button)

	var klong_toey_button := _make_menu_button("[DEV] Klong Toey Canals - Test District 3 (Apprentice Mage)")
	klong_toey_button.pressed.connect(_on_klong_toey_pressed)
	box.add_child(klong_toey_button)

	var wat_hua_button := _make_menu_button("[DEV] Wat Hualamphong Depths - Test District 4 (Apprentice Mage)")
	wat_hua_button.pressed.connect(_on_wat_hualamphong_pressed)
	box.add_child(wat_hua_button)

## Godot's Button doesn't wrap its own text (same constraint combat.gd's
## tray buttons work around with a wrapped Label) - clip_text at least
## ellipsizes instead of silently rendering past the button's own bounds.
func _make_menu_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.clip_text = true
	btn.custom_minimum_size = Vector2(440, 0)
	return btn

func _build_codex_text() -> String:
	var total: int = GameData.classes.size()
	var hidden: int = 0
	for c in GameData.classes.values():
		if c.is_hidden:
			hidden += 1
	return "%d of %d known classes are still unresolved rumors." % [hidden, total]

func _on_explore_pressed() -> void:
	RunState.begin_run("mage_f")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_continue_pressed() -> void:
	var resume: Dictionary = RunState.load_game()
	if resume.is_empty():
		return
	RunState.pending_district_id = resume["district_id"]
	RunState.pending_player_cell = resume["player_cell"]
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat.tscn")

func _on_chatuchak_pressed() -> void:
	RunState.begin_run("mage_f")
	RunState.pending_district_id = "chatuchak_ruins"
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_klong_toey_pressed() -> void:
	RunState.begin_run("mage_f")
	RunState.pending_district_id = "klong_toey_canals"
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_wat_hualamphong_pressed() -> void:
	RunState.begin_run("mage_f")
	RunState.pending_district_id = "wat_hualamphong_depths"
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")
