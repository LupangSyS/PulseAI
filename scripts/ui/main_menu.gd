extends Control

## Main menu. Every class in data/classes.json currently has is_hidden = true
## by design (see GDD.md) - so the codex list below shows every class as an
## unresolved "???" entry until a real discovery/unlock system exists. The
## "Enter the Flood" button is a developer shortcut straight into the combat
## prototype and bypasses that gating on purpose; it is not the real
## class-selection flow.

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

	var start_button := Button.new()
	start_button.text = "[DEV] Enter the Flood - Test Combat (Apprentice Mage)"
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

func _build_codex_text() -> String:
	var text := ""
	for c in GameData.classes.values():
		if c.is_hidden:
			text += "F-??? ... %s\n" % c.locked_description
		else:
			text += "%s-Rank %s\n" % [c.rank, c.display_name]
	return text

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat.tscn")
