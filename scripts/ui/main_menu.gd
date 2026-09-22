extends Control

## Main menu. Every class in data/classes.json currently has is_hidden = true
## by design (see GDD.md) - so the codex summary below never names a class,
## only counts them, until a real discovery/unlock system exists. Two entry
## points exist on purpose: "Start Exploring" is the real (if still rough)
## game loop - it begins a run and drops the player into the starting
## district's overworld. "[DEV] Enter the Flood" is a developer shortcut
## straight into an isolated test battle, bypassing the overworld/class
## gating entirely, kept for quick combat-balance testing.

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	add_child(box)

	var title := Label.new()
	title.text = "DELUGE CHRONICLES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Bangkok, 2035. The water remembers what the surface forgot."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	var codex_label := Label.new()
	codex_label.text = _build_codex_text()
	codex_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(codex_label)

	var explore_button := Button.new()
	explore_button.text = "Start Exploring (Sukhumvit Shallows, as the Apprentice Mage)"
	explore_button.pressed.connect(_on_explore_pressed)
	box.add_child(explore_button)

	var start_button := Button.new()
	start_button.text = "[DEV] Enter the Flood - Test Combat (Apprentice Mage)"
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

func _build_codex_text() -> String:
	var total: int = GameData.classes.size()
	var hidden: int = 0
	for c in GameData.classes.values():
		if c.is_hidden:
			hidden += 1
	return "%d of %d known classes are still unresolved rumors." % [hidden, total]

func _on_explore_pressed() -> void:
	RunState.begin_run("mage_f")
	RunState.pending_district_id = "sukhumvit_shallows"
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat.tscn")
