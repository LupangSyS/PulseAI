class_name StatusMenu
extends Control

## An overworld overlay (opened with Escape, not a scene change - so it
## can't disturb the overworld's spawn/respawn state) showing the two
## things the solo evolving-class design actually has: your held items
## (Items tab, reusing combat.gd's tray-button pattern for consistency)
## and your class/deck (Status tab - portrait, name, rank, HP/resource,
## and the full card list, which isn't shown anywhere else in the game).
##
## Deliberately does NOT have Equipment/Formation/Config/Save commands
## like the FF-style reference menu - none of those systems exist yet
## (no equipment slots, no party, no settings, no save/load), and a menu
## button that does nothing is worse than no button.

const VIEWPORT_WIDTH := 480
const VIEWPORT_HEIGHT := 460

## "status" | "items" - which tab is showing.
var tab_state: String = "status"

var panel_bg: ColorRect
var portrait: TextureRect
var portrait_frames: Array = []
var portrait_anim_timer: float = 0.0
var portrait_anim_frame: int = 0
var title_label: Label
var hp_bar: ProgressBar
var resource_bar: ProgressBar
var tab_status_button: Button
var tab_items_button: Button
var content_scroll: ScrollContainer
var content_list: VBoxContainer
var close_button: Button
var save_button: Button

## Set by Overworld right after instantiating this menu - lets the Save
## button capture exactly where the player currently is (district_id +
## player_cell), which RunState.save_game needs but has no way to know on
## its own since it doesn't track overworld position.
var overworld_ref: Control = null

func _ready() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _process(delta: float) -> void:
	if not visible:
		return
	portrait_anim_timer += delta
	if portrait_anim_timer < 0.5:
		return
	portrait_anim_timer = 0.0
	portrait_anim_frame = 1 - portrait_anim_frame
	if portrait_frames.size() == 2:
		portrait.texture = portrait_frames[portrait_anim_frame]

func open() -> void:
	visible = true
	tab_state = "status"
	save_button.text = "Save Game"
	_load_portrait()
	refresh()

func close() -> void:
	visible = false

func _on_save_pressed() -> void:
	if overworld_ref == null:
		return
	RunState.save_game(overworld_ref.district_id, overworld_ref.player_cell)
	save_button.text = "Saved!"

func _build_ui() -> void:
	theme = UITheme.build()

	panel_bg = ColorRect.new()
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_bg.color = Color(UITheme.COL_BG.r, UITheme.COL_BG.g, UITheme.COL_BG.b, 0.94)
	add_child(panel_bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 10)
	add_child(margin)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 6)
	margin.add_child(root_box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.custom_minimum_size = Vector2(0, 88)
	root_box.add_child(header)

	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(80, 80)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	header.add_child(portrait)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_text)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.add_theme_color_override("font_color", UITheme.COL_WARNING)
	header_text.add_child(title_label)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(0, 12)
	hp_bar.show_percentage = false
	UITheme.style_bar(hp_bar, UITheme.COL_PLAYER)
	header_text.add_child(hp_bar)

	resource_bar = ProgressBar.new()
	resource_bar.custom_minimum_size = Vector2(0, 12)
	resource_bar.show_percentage = false
	UITheme.style_bar(resource_bar, UITheme.COL_RESOURCE)
	header_text.add_child(resource_bar)

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	root_box.add_child(tab_row)

	tab_status_button = Button.new()
	tab_status_button.text = "Status"
	tab_status_button.pressed.connect(_on_tab_status_pressed)
	tab_row.add_child(tab_status_button)

	tab_items_button = Button.new()
	tab_items_button.text = "Items"
	tab_items_button.pressed.connect(_on_tab_items_pressed)
	tab_row.add_child(tab_items_button)

	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_box.add_child(content_scroll)

	content_list = VBoxContainer.new()
	content_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_list.add_theme_constant_override("separation", 4)
	content_scroll.add_child(content_list)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	root_box.add_child(bottom_row)

	save_button = Button.new()
	save_button.text = "Save Game"
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_on_save_pressed)
	bottom_row.add_child(save_button)

	close_button = Button.new()
	close_button.text = "Close (Esc)"
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.pressed.connect(close)
	bottom_row.add_child(close_button)

func _load_portrait() -> void:
	portrait_frames = SpriteLoader.load_frames(RunState.player_class_id, "character")
	portrait_anim_frame = 0
	portrait_anim_timer = 0.0
	portrait.visible = not portrait_frames.is_empty()
	if not portrait_frames.is_empty():
		portrait.texture = portrait_frames[0]

func _on_tab_status_pressed() -> void:
	tab_state = "status"
	refresh()

func _on_tab_items_pressed() -> void:
	tab_state = "items"
	refresh()

func refresh() -> void:
	var p: Combatant = RunState.player
	var cls := GameData.get_class_by_id(RunState.player_class_id)
	if p == null or cls == null:
		return

	title_label.text = "%s  (Rank %s)" % [p.display_name, cls.rank]
	hp_bar.max_value = p.max_hp
	hp_bar.value = p.hp
	resource_bar.max_value = max(p.max_resource, 1)
	resource_bar.value = p.resource

	for child in content_list.get_children():
		content_list.remove_child(child)
		child.queue_free()

	match tab_state:
		"status":
			_populate_status(cls)
		"items":
			_populate_items()

func _populate_status(cls: CharacterClass) -> void:
	var playstyle_label := Label.new()
	playstyle_label.text = cls.playstyle if cls.playstyle != "" else "A survivor who learned to wield what came out."
	playstyle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	playstyle_label.add_theme_font_size_override("font_size", 10)
	content_list.add_child(playstyle_label)

	var deck_header := Label.new()
	deck_header.text = "Deck (%d cards):" % cls.deck.size()
	deck_header.add_theme_font_size_override("font_size", 11)
	content_list.add_child(deck_header)

	var counted: Dictionary = {}
	for card_id in cls.deck:
		counted[card_id] = counted.get(card_id, 0) + 1

	for card_id in counted.keys():
		var card := GameData.get_card(card_id)
		if card == null:
			continue
		var row := _make_list_row(
			"%s x%d  (cost %d)" % [card.display_name, counted[card_id], card.cost],
			card.description,
		)
		content_list.add_child(row)

func _populate_items() -> void:
	if RunState.inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No items held."
		empty_label.add_theme_font_size_override("font_size", 10)
		content_list.add_child(empty_label)
		return
	for item_id in RunState.inventory.keys():
		var count: int = RunState.inventory[item_id]
		if count <= 0:
			continue
		var item := GameData.get_item(item_id)
		if item == null:
			continue
		var row := _make_list_row("%s x%d" % [item.display_name, count], item.description)
		content_list.add_child(row)

func _make_list_row(title: String, description: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)

	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 11)
	box.add_child(title_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 9)
	box.add_child(desc_label)

	return box
