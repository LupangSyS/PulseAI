extends Control

## Turn-based combat: an FF/Pokemon-style action menu (Cards / Item / Guard)
## fronting a deck-driven card system underneath. "Cards" opens your hand
## (Action/Spell/Power cards - the actual attack/cast-spell repertoire);
## "Item" opens usable consumables from RunState.inventory; "Guard" is a
## free, always-available defensive action. Multiple actions are allowed
## per turn (resource-gated for cards, free for Guard/Item) - click
## "End Turn" when done, matching the resource-pool design rather than a
## strict one-action-per-turn classic JRPG turn.
##
## Card/item/monster-move effects: damage, heal, block, empower_next (base
## kit), dot (lingering damage that bypasses block, ticks each turn),
## aoe_damage (hits every living enemy), execute (bonus damage below 50%
## HP). The same six effects resolve for BOTH the player's cards
## (_apply_card_effect) and monster moves (_apply_monster_move) - monsters
## pick from a weighted move list (MonsterData.moves) each turn instead of
## clicking a card, and mini-bosses/bosses can carry `stages` that swap
## their active move list (and optionally display_name) once their HP
## crosses a threshold - see _check_stage_transitions.
##
## Player state (HP, resource, etc) persists across encounters via the
## RunState autoload: when entered from the Overworld, RunState.player and
## RunState.pending_monster_id drive the fight, and results are written
## back to RunState before returning. With no pending state (the
## "[DEV] Enter the Flood" menu shortcut), it falls back to a fresh
## Apprentice Mage vs. the placeholder Flooded Ghoul for standalone testing.
##
## UI is built entirely in code (no hand-authored .tscn layout). Player and
## enemy portraits (SpriteLoader.load_frames, a simple 2-frame idle flip
## driven by _process) render when generated art exists for that class/
## monster id; otherwise the TextureRect just stays hidden - most ids don't
## have art yet (see GDD.md), so that fallback is the common case.
##
## Layout is a fixed-height arena (portrait + name/HP + an HP bar per side)
## over a fixed-height log over a fixed-height scrolling card/item tray -
## every panel's height is a constant, nothing relies on SIZE_EXPAND_FILL
## to soak up leftover space, and the tray wraps into a 2-column grid
## instead of a single row that can run off the right edge. See
## _build_ui's doc comment and GDD.md for why.

const STARTING_HAND_SIZE := 4
const DEFAULT_CLASS_ID := "mage_f"
const DEFAULT_MONSTER_ID := "flooded_ghoul"
const GUARD_BLOCK := 3

var player: Combatant
var enemies: Array[Combatant] = []
var player_class: CharacterClass
var from_overworld: bool = false

var draw_pile: Array[String] = []
var hand: Array[String] = []
var discard_pile: Array[String] = []

var combo_tag: String = ""
var combo_count: int = 0

## "main" | "cards" | "items" - which sub-panel the action menu is showing.
var menu_state: String = "main"

var player_name_label: Label
var enemy_name_label: Label
var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_stat_label: Label
var mana_pip_row: HBoxContainer
var log_label: RichTextLabel
var menu_row: HBoxContainer
var menu_cards_button: Button
var menu_item_button: Button
var menu_guard_button: Button
var card_scroll: ScrollContainer
var card_grid: GridContainer
var end_turn_button: Button
var continue_button: Button
var arena_row: HBoxContainer
var enemy_intent_icon: TextureRect
var enemy_intent_label: Label

## The monster's next move, pre-rolled and displayed a full player turn in
## advance (Slay the Spire-style intent telegraph) rather than picked blind
## when their turn arrives - see _enemy_turn. {} means "no intent yet"
## (battle just started) or "enemy is dead", both of which hide the display.
var enemy_intent: Dictionary = {}

## Palette for the combat scene's theme/panels/accents, aliased from the
## shared UITheme utility (scripts/util/ui_theme.gd) so every other screen
## (overworld, main menu, status menu) uses the exact same "player=cyan,
## enemy=rose, warning=amber" color language instead of each scene
## re-deriving its own.
const COL_BG := UITheme.COL_BG
const COL_PANEL_BG := UITheme.COL_PANEL_BG
const COL_PANEL_BORDER := UITheme.COL_PANEL_BORDER
const COL_HAZARD_BORDER := UITheme.COL_HAZARD_BORDER
const COL_PLAYER := UITheme.COL_PLAYER
const COL_ENEMY := UITheme.COL_ENEMY
const COL_WARNING := UITheme.COL_WARNING
const COL_TEXT := UITheme.COL_TEXT
const COL_TEXT_DIM := UITheme.COL_TEXT_DIM

var player_portrait: TextureRect
var enemy_portrait: TextureRect
var player_portrait_frames: Array = []
var enemy_portrait_frames: Array = []
var portrait_anim_timer: float = 0.0
var portrait_anim_frame: int = 0

func _ready() -> void:
	_build_ui()
	if RunState.pending_monster_id != "":
		from_overworld = true
		_start_battle(RunState.player_class_id, RunState.pending_monster_id, RunState.player)
	else:
		from_overworld = false
		_start_battle(DEFAULT_CLASS_ID, DEFAULT_MONSTER_ID, null)

func _process(delta: float) -> void:
	portrait_anim_timer += delta
	if portrait_anim_timer < 0.5:
		return
	portrait_anim_timer = 0.0
	portrait_anim_frame = 1 - portrait_anim_frame
	if player_portrait_frames.size() == 2:
		player_portrait.texture = player_portrait_frames[portrait_anim_frame]
	if enemy_portrait_frames.size() == 2:
		enemy_portrait.texture = enemy_portrait_frames[portrait_anim_frame]

## Layout budget (fits the 480x460 viewport with slack to spare, verified
## headlessly - see GDD.md's combat UI note): a fixed-height arena row, a
## fixed-height log, and a fixed-height scrolling card tray. Nothing here
## uses SIZE_EXPAND_FILL to soak up leftover space, on purpose - every
## panel's height is a known constant, so total content height is
## predictable instead of depending on how much text happens to be in the
## log or how many cards are in hand (the cause of the original overflow
## bug, where an expand-fill log always grew to fill whatever space was
## left, and an unbounded hand row could run past the right edge).
func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = _build_theme()

	var backdrop := ColorRect.new()
	backdrop.color = COL_BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 8)
	add_child(margin)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 6)
	margin.add_child(root_box)

	# --- Arena: player (left) vs. enemy (right), each with a portrait,
	# name + HP readout, and a visual HP bar. Wrapped in a dark bordered
	# panel (the "stage") instead of sitting bare on the background.
	var arena_panel := PanelContainer.new()
	arena_panel.add_theme_stylebox_override("panel", UITheme.panel_style(COL_PANEL_BORDER))
	root_box.add_child(arena_panel)

	arena_row = HBoxContainer.new()
	arena_row.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_theme_constant_override("separation", 28)
	arena_row.custom_minimum_size = Vector2(0, 150)
	arena_panel.add_child(arena_row)

	var player_panel := VBoxContainer.new()
	player_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_child(player_panel)
	player_portrait = _make_portrait()
	player_panel.add_child(player_portrait)
	player_name_label = _make_centered_label(11)
	player_name_label.add_theme_color_override("font_color", COL_PLAYER)
	player_panel.add_child(player_name_label)
	player_hp_bar = _make_hp_bar(COL_PLAYER)
	player_panel.add_child(player_hp_bar)

	var enemy_panel := VBoxContainer.new()
	enemy_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_child(enemy_panel)
	enemy_portrait = _make_portrait()
	enemy_panel.add_child(enemy_portrait)
	enemy_name_label = _make_centered_label(11)
	enemy_name_label.add_theme_color_override("font_color", COL_ENEMY)
	enemy_panel.add_child(enemy_name_label)
	enemy_hp_bar = _make_hp_bar(COL_ENEMY)
	enemy_panel.add_child(enemy_hp_bar)

	# --- Intent telegraph: what the enemy is about to do, visible for the
	# whole player turn so a hit can actually be planned around instead of
	# just reacted to after the fact - see enemy_intent's doc comment.
	var intent_row := HBoxContainer.new()
	intent_row.alignment = BoxContainer.ALIGNMENT_CENTER
	intent_row.add_theme_constant_override("separation", 4)
	enemy_panel.add_child(intent_row)

	enemy_intent_icon = TextureRect.new()
	enemy_intent_icon.custom_minimum_size = Vector2(14, 14)
	enemy_intent_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	enemy_intent_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_intent_icon.modulate = COL_WARNING
	intent_row.add_child(enemy_intent_icon)

	enemy_intent_label = Label.new()
	enemy_intent_label.add_theme_font_size_override("font_size", 9)
	enemy_intent_label.add_theme_color_override("font_color", COL_WARNING)
	intent_row.add_child(enemy_intent_label)

	# --- Compact resource/block readout beneath the arena, plus mana shown
	# as pips (filled = available) for an at-a-glance read alongside the
	# exact numbers in the text.
	player_stat_label = _make_centered_label()
	root_box.add_child(player_stat_label)

	mana_pip_row = HBoxContainer.new()
	mana_pip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mana_pip_row.add_theme_constant_override("separation", 3)
	root_box.add_child(mana_pip_row)

	# --- Battle log: fixed height, does not expand.
	var log_panel := PanelContainer.new()
	log_panel.add_theme_stylebox_override("panel", UITheme.panel_style(COL_PANEL_BORDER))
	root_box.add_child(log_panel)

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 42)
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	log_label.add_theme_color_override("default_color", COL_TEXT)
	log_panel.add_child(log_label)

	# --- Action menu: Cards / Item / Guard (FF/Pokemon-style turn input).
	menu_row = HBoxContainer.new()
	menu_row.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_row.add_theme_constant_override("separation", 8)
	root_box.add_child(menu_row)

	menu_cards_button = Button.new()
	menu_cards_button.text = "Cards"
	menu_cards_button.custom_minimum_size = Vector2(72, 0)
	menu_cards_button.pressed.connect(_on_menu_cards_pressed)
	menu_row.add_child(menu_cards_button)

	menu_item_button = Button.new()
	menu_item_button.text = "Item"
	menu_item_button.custom_minimum_size = Vector2(72, 0)
	menu_item_button.pressed.connect(_on_menu_item_pressed)
	menu_row.add_child(menu_item_button)

	menu_guard_button = Button.new()
	menu_guard_button.text = "Guard"
	menu_guard_button.custom_minimum_size = Vector2(72, 0)
	menu_guard_button.pressed.connect(_on_guard_pressed)
	menu_row.add_child(menu_guard_button)

	# --- Card/item tray: a fixed-size scroll area holding a 2-column grid,
	# so entries wrap to a new row instead of running off the right edge,
	# and any overflow (more rows than fit) scrolls instead of pushing
	# End Turn off-screen. Wrapped in a hazard-bordered panel (the action
	# zone) to distinguish it from the arena/log's neutral panels.
	var tray_panel := PanelContainer.new()
	tray_panel.add_theme_stylebox_override("panel", UITheme.panel_style(COL_HAZARD_BORDER))
	root_box.add_child(tray_panel)

	card_scroll = ScrollContainer.new()
	card_scroll.custom_minimum_size = Vector2(0, 132)
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tray_panel.add_child(card_scroll)

	card_grid = GridContainer.new()
	card_grid.columns = 2
	card_grid.add_theme_constant_override("h_separation", 8)
	card_grid.add_theme_constant_override("v_separation", 8)
	card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_scroll.add_child(card_grid)

	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	root_box.add_child(end_turn_button)

	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	root_box.add_child(continue_button)

## Builds the dark, bordered "combat terminal" look shared by every panel
## and button in this scene from one place, so a future palette tweak is a
## one-function edit instead of hunting down N inline StyleBoxFlats. Applied
## as this Control's own `theme` (see _build_ui), so every child Button/
## Label/PanelContainer picks it up automatically, including ones created
## later by _make_tray_button for cards/items.
## Combat's own buttons (menu Cards/Item/Guard, End Turn, tray entries) use
## a thicker border than UITheme.build()'s default - they're chunkier
## tap/click targets than a HUD label row - so this stays a thin local
## wrapper around UITheme.panel_style rather than calling UITheme.build()
## directly.
func _build_theme() -> Theme:
	var t := Theme.new()

	t.set_stylebox("panel", "PanelContainer", UITheme.panel_style(COL_PANEL_BORDER))

	var btn_normal := UITheme.panel_style(COL_PANEL_BORDER, 4)
	var btn_hover := UITheme.panel_style(COL_PLAYER, 4)
	var btn_pressed := UITheme.panel_style(COL_PLAYER, 4)
	btn_pressed.bg_color = Color("#182335")
	var btn_disabled := UITheme.panel_style(Color("#232b3d"), 4)
	btn_disabled.bg_color = Color("#0a0d14")

	t.set_stylebox("normal", "Button", btn_normal)
	t.set_stylebox("hover", "Button", btn_hover)
	t.set_stylebox("pressed", "Button", btn_pressed)
	t.set_stylebox("focus", "Button", btn_hover)
	t.set_stylebox("disabled", "Button", btn_disabled)
	t.set_color("font_color", "Button", COL_TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", COL_TEXT_DIM)

	t.set_color("font_color", "Label", COL_TEXT)
	t.set_color("font_color", "RichTextLabel", COL_TEXT)

	return t

func _make_portrait() -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(80, 80)
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return rect

func _make_centered_label(font_size: int = 0) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	return label

func _make_hp_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(110, 12)
	bar.min_value = 0
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UITheme.style_bar(bar, fill_color)
	return bar

## A tray entry (hand card or item): a Button used purely as the click
## target (text left empty) wrapping a VBoxContainer of real Labels, so
## the description can word-wrap instead of overflowing the button's
## fixed width. Every descendant is set to MOUSE_FILTER_IGNORE so clicks
## pass through to the Button itself rather than being eaten by a child.
## Per-effect icon (assets/icons/effect_<effect>.png - see
## tools/gen_card_icons.py) tinted per card type at runtime via
## TextureRect.modulate, rather than baking 7 effects x 3 types = 21
## separate images. Covers all cards automatically since every card
## already has one of these seven effects (card_data.gd).
const TYPE_TINT := {
	"action": Color(0.91, 0.4, 0.27),
	"spell": Color(0.4, 0.58, 0.91),
	"power": Color(0.89, 0.74, 0.3),
}

func _make_tray_button(title: String, description: String, is_disabled: bool, icon_effect: String = "", icon_tint: Color = Color.WHITE) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(228, 70)
	btn.disabled = is_disabled

	# Border tinted per card type (icon_tint is already TYPE_TINT-derived -
	# see the icon block below) so a card's type reads at a glance, the
	# same idea as the icon tinting, applied to the frame around it too.
	if icon_tint != Color.WHITE:
		var border := UITheme.panel_style(icon_tint, 2)
		border.bg_color = COL_PANEL_BG
		btn.add_theme_stylebox_override("normal", border)
		var border_disabled := border.duplicate()
		border_disabled.bg_color = Color("#0a0d14")
		border_disabled.border_color = icon_tint.darkened(0.5)
		btn.add_theme_stylebox_override("disabled", border_disabled)
		var border_hover := border.duplicate()
		border_hover.bg_color = Color("#182335")
		btn.add_theme_stylebox_override("hover", border_hover)

	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hb.add_theme_constant_override("separation", 6)
	btn.add_child(hb)

	if icon_effect != "":
		var icon_path := "res://assets/icons/effect_%s.png" % icon_effect
		if ResourceLoader.exists(icon_path):
			var icon := TextureRect.new()
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.custom_minimum_size = Vector2(22, 22)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.modulate = icon_tint
			icon.texture = load(icon_path)
			hb.add_child(icon)

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hb.add_child(vb)

	var title_label := Label.new()
	title_label.text = title
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(title_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 9)
	vb.add_child(desc_label)

	return btn

func _load_portraits(class_id: String, monster_id: String) -> void:
	player_portrait_frames = SpriteLoader.load_frames(class_id, "character")
	enemy_portrait_frames = SpriteLoader.load_frames(monster_id, "monster")
	portrait_anim_frame = 0
	portrait_anim_timer = 0.0

	player_portrait.visible = not player_portrait_frames.is_empty()
	if not player_portrait_frames.is_empty():
		player_portrait.texture = player_portrait_frames[0]

	enemy_portrait.visible = not enemy_portrait_frames.is_empty()
	if not enemy_portrait_frames.is_empty():
		enemy_portrait.texture = enemy_portrait_frames[0]

func _start_battle(class_id: String, monster_id: String, existing_player: Combatant) -> void:
	player_class = GameData.get_class_by_id(class_id)
	if existing_player != null:
		player = existing_player
	else:
		player = Combatant.new(player_class.display_name, player_class.max_hp, player_class.max_resource, player_class.resource_name)
	player.block = 0
	player.dot_stacks = 0
	player.pending_empower = 0
	player.refill_resource()

	enemies = [_make_monster_combatant(monster_id)]
	_load_portraits(class_id, monster_id)

	draw_pile = player_class.deck.duplicate()
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	combo_tag = ""
	combo_count = 0
	menu_state = "main"
	continue_button.visible = false
	enemy_intent = _pick_weighted_move(enemies[0].moves) if not enemies[0].moves.is_empty() else {}

	_log("[b]%s[/b] squares off against [b]%s[/b]." % [player.display_name, enemies[0].display_name])
	_draw_cards(STARTING_HAND_SIZE)
	_refresh_ui()

func _make_monster_combatant(monster_id: String) -> Combatant:
	var data := GameData.get_monster(monster_id)
	if data == null:
		return Combatant.new("Unknown Threat", 20, 0, "")
	var c := Combatant.new(data.display_name, data.max_hp, 0, "")
	c.moves = data.moves.duplicate(true)
	c.stages = data.stages.duplicate(true)
	c.drop_table = data.drop_table.duplicate(true)
	c.is_boss = data.is_boss
	c.is_miniboss = data.is_miniboss
	return c

func _first_alive_enemy() -> Combatant:
	for e in enemies:
		if e.is_alive():
			return e
	return null

func _all_enemies_dead() -> bool:
	for e in enemies:
		if e.is_alive():
			return false
	return true

func _draw_cards(amount: int) -> void:
	for i in amount:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
		hand.append(draw_pile.pop_back())

func _on_menu_cards_pressed() -> void:
	menu_state = "main" if menu_state == "cards" else "cards"
	_refresh_ui()

func _on_menu_item_pressed() -> void:
	menu_state = "main" if menu_state == "items" else "items"
	_refresh_ui()

func _on_guard_pressed() -> void:
	if not player.is_alive() or _all_enemies_dead():
		return
	player.add_block(GUARD_BLOCK)
	combo_tag = ""
	combo_count = 0
	_log("%s braces defensively, gaining %d block." % [player.display_name, GUARD_BLOCK])
	_refresh_ui()

func _has_usable_items() -> bool:
	for item_id in RunState.inventory.keys():
		if RunState.inventory[item_id] <= 0:
			continue
		var item := GameData.get_item(item_id)
		if item != null and item.effect != "":
			return true
	return false

func _on_item_button_pressed(item_id: String) -> void:
	if not player.is_alive() or _all_enemies_dead():
		return
	if not RunState.inventory.has(item_id) or RunState.inventory[item_id] <= 0:
		return
	var item := GameData.get_item(item_id)
	if item == null or item.effect == "":
		return

	match item.effect:
		"heal":
			player.heal(item.value)
			_log("%s uses [i]%s[/i], recovering %d HP." % [player.display_name, item.display_name, item.value])
		"restore_resource":
			player.resource = min(player.resource + item.value, player.max_resource)
			_log("%s uses [i]%s[/i], recovering %d %s." % [player.display_name, item.display_name, item.value, player.resource_name])

	RunState.inventory[item_id] -= 1
	if RunState.inventory[item_id] <= 0:
		RunState.inventory.erase(item_id)
	combo_tag = ""
	combo_count = 0
	if not _has_usable_items():
		menu_state = "main"
	_refresh_ui()

func _on_card_pressed(card_id: String) -> void:
	if not player.is_alive() or _all_enemies_dead():
		return
	var card := GameData.get_card(card_id)
	if card == null or player.resource < card.cost:
		return

	player.resource -= card.cost
	hand.erase(card_id)
	discard_pile.append(card_id)

	_update_combo(card)
	_apply_card_effect(card)

	if _all_enemies_dead():
		_log("[color=gold]Every threat here has been put down. Victory.[/color]")

	_refresh_ui()

func _update_combo(card: CardData) -> void:
	if combo_tag != "" and card.combo_tag == combo_tag:
		combo_count += 1
	else:
		combo_tag = card.combo_tag
		combo_count = 1

func _combo_multiplier() -> float:
	return 1.0 + 0.2 * float(combo_count - 1)

func _apply_card_effect(card: CardData) -> void:
	var value: int = card.base_value + player.pending_empower
	player.pending_empower = 0
	var multiplier: float = _combo_multiplier()

	match card.effect:
		"damage":
			var target := _first_alive_enemy()
			if target == null:
				return
			var total: int = int(round(value * multiplier))
			target.take_damage(total)
			_log("%s uses [i]%s[/i] for %d damage. (combo x%d)" % [player.display_name, card.display_name, total, combo_count])
			_spawn_floating_number(enemy_portrait, "-%d" % total, COL_ENEMY)
			_screen_shake()
		"aoe_damage":
			var total: int = int(round(value * multiplier))
			var hit_count := 0
			for e in enemies:
				if e.is_alive():
					e.take_damage(total)
					hit_count += 1
			_log("%s unleashes [i]%s[/i] for %d damage to %d foe(s). (combo x%d)" % [player.display_name, card.display_name, total, hit_count, combo_count])
			_spawn_floating_number(enemy_portrait, "-%d" % total, COL_ENEMY)
			_screen_shake()
		"dot":
			var target := _first_alive_enemy()
			if target == null:
				return
			var stacks: int = int(round(value * multiplier))
			target.apply_dot(stacks)
			_log("%s brands the enemy with [i]%s[/i], a lingering power now dealing %d damage a turn. (combo x%d)" % [player.display_name, card.display_name, target.dot_stacks, combo_count])
			_spawn_floating_number(enemy_portrait, "+%d dot" % stacks, COL_WARNING)
		"execute":
			var target := _first_alive_enemy()
			if target == null:
				return
			var total: int = int(round(value * multiplier))
			var executed := false
			if target.hp <= int(target.max_hp / 2.0):
				total *= 2
				executed = true
			target.take_damage(total)
			if executed:
				_log("%s unleashes [i]%s[/i] on the weakened foe for %d devastating damage! (combo x%d)" % [player.display_name, card.display_name, total, combo_count])
			else:
				_log("%s unleashes [i]%s[/i] for %d damage. (combo x%d)" % [player.display_name, card.display_name, total, combo_count])
			_spawn_floating_number(enemy_portrait, "-%d" % total, Color("#facc15") if executed else COL_ENEMY)
			_screen_shake()
		"heal":
			var total: int = int(round(value * multiplier))
			player.heal(total)
			_log("%s channels [i]%s[/i], healing %d." % [player.display_name, card.display_name, total])
			_spawn_floating_number(player_portrait, "+%d" % total, Color("#4ade80"))
		"block":
			player.add_block(value)
			_log("%s raises [i]%s[/i], gaining %d block." % [player.display_name, card.display_name, value])
			_spawn_floating_number(player_portrait, "+%d block" % value, COL_PLAYER)
		"empower_next":
			player.pending_empower = value
			_log("%s focuses with [i]%s[/i], empowering the next card by %d." % [player.display_name, card.display_name, value])
		_:
			_log("%s plays [i]%s[/i]." % [player.display_name, card.display_name])

func _on_end_turn_pressed() -> void:
	if not player.is_alive() or _all_enemies_dead():
		return
	discard_pile.append_array(hand)
	hand.clear()

	_enemy_turn()
	if player.is_alive():
		_start_player_turn()

	_refresh_ui()

func _enemy_turn() -> void:
	for e in enemies:
		if not player.is_alive():
			break
		if not e.is_alive():
			continue
		if e.dot_stacks > 0:
			var dot_damage: int = e.tick_dot()
			_log("The lingering power in %s deals %d damage." % [e.display_name, dot_damage])
			if not e.is_alive():
				_log("[color=gold]%s succumbs to the lingering damage.[/color]" % e.display_name)
				continue
		var stages_before: int = e.stages.size()
		_check_stage_transitions(e)
		if not e.is_alive():
			continue
		# A stage transition swaps the active move list (see
		# _check_stage_transitions), which can make the already-telegraphed
		# intent stale - re-roll from the new list rather than resolve a
		# move that phase may not even have. Also covers turn 1, where
		# enemy_intent was pre-rolled in _start_battle from a possibly-
		# different (base) move list if a stage already triggered above.
		if enemy_intent.is_empty() or e.stages.size() != stages_before:
			enemy_intent = _pick_weighted_move(e.moves)
		_apply_monster_move(e, enemy_intent)
		# Telegraph what's coming next turn immediately, so it's visible
		# for the player's entire upcoming turn rather than appearing only
		# once their turn starts.
		enemy_intent = _pick_weighted_move(e.moves) if not e.moves.is_empty() else {}
	if not player.is_alive():
		_log("[color=red]%s is dragged beneath the flood. Defeat.[/color]" % player.display_name)

## Pops and applies every stage whose trigger_hp_pct the monster's current
## HP fraction has crossed (a loop, not a single check, so a monster can't
## skip a phase by taking a huge hit in one turn). Requires e.stages to be
## sorted descending by trigger_hp_pct - see MonsterData's doc comment.
func _check_stage_transitions(e: Combatant) -> void:
	while not e.stages.is_empty():
		var hp_pct: float = float(e.hp) / float(e.max_hp)
		var stage: Dictionary = e.stages[0]
		var threshold: float = stage.get("trigger_hp_pct", 0.5)
		if hp_pct > threshold:
			break
		e.stages.pop_front()
		if stage.has("moves"):
			e.moves = stage["moves"]
		var new_name: String = stage.get("display_name", "")
		if new_name != "":
			e.display_name = new_name
		var transition_text: String = stage.get("transition_text", "")
		if transition_text == "":
			transition_text = "%s enters a new phase!" % e.display_name
		_log("[color=orange]%s[/color]" % transition_text)


func _pick_weighted_move(moves: Array) -> Dictionary:
	var total_weight: float = 0.0
	for m in moves:
		total_weight += float(m.get("weight", 1))
	if total_weight <= 0.0:
		return moves[0]
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for m in moves:
		cumulative += float(m.get("weight", 1))
		if roll <= cumulative:
			return m
	return moves[-1]

func _apply_monster_move(e: Combatant, move: Dictionary) -> void:
	var value: int = int(move.get("value", 0)) + e.pending_empower
	e.pending_empower = 0
	var effect: String = move.get("effect", "damage")
	var move_name: String = move.get("name", "Attack")

	match effect:
		"damage":
			var dealt: int = player.take_damage(value)
			_log("%s uses [i]%s[/i] for %d damage." % [e.display_name, move_name, dealt])
			_spawn_floating_number(player_portrait, "-%d" % dealt, COL_ENEMY)
			_screen_shake()
		"dot":
			player.apply_dot(value)
			_log("%s uses [i]%s[/i], a lingering harm now dealing %d damage a turn." % [e.display_name, move_name, player.dot_stacks])
			_spawn_floating_number(player_portrait, "+%d dot" % value, COL_WARNING)
		"execute":
			var total: int = value
			var executed := false
			if player.hp <= int(player.max_hp / 2.0):
				total *= 2
				executed = true
			var dealt: int = player.take_damage(total)
			if executed:
				_log("[color=red]%s uses [i]%s[/i] on you, weakened, for %d devastating damage![/color]" % [e.display_name, move_name, dealt])
			else:
				_log("%s uses [i]%s[/i] for %d damage." % [e.display_name, move_name, dealt])
			_spawn_floating_number(player_portrait, "-%d" % dealt, Color("#facc15") if executed else COL_ENEMY)
			_screen_shake()
		"heal":
			e.heal(value)
			_log("%s uses [i]%s[/i], recovering %d HP." % [e.display_name, move_name, value])
			_spawn_floating_number(enemy_portrait, "+%d" % value, Color("#4ade80"))
		"block":
			e.add_block(value)
			_log("%s uses [i]%s[/i], gaining %d block." % [e.display_name, move_name, value])
			_spawn_floating_number(enemy_portrait, "+%d block" % value, COL_ENEMY)
		"empower_next":
			e.pending_empower = value
			_log("%s uses [i]%s[/i], readying a stronger blow." % [e.display_name, move_name])
		_:
			_log("%s uses [i]%s[/i]." % [e.display_name, move_name])

func _start_player_turn() -> void:
	if player.dot_stacks > 0:
		var dot_damage: int = player.tick_dot()
		_log("The lingering harm on %s deals %d damage." % [player.display_name, dot_damage])
		if not player.is_alive():
			_log("[color=red]%s succumbs to the lingering harm. Defeat.[/color]" % player.display_name)
			return
	player.block = 0
	player.refill_resource()
	combo_tag = ""
	combo_count = 0
	menu_state = "main"
	_draw_cards(STARTING_HAND_SIZE - hand.size())

## Resource shown as filled/empty pips alongside the exact text in
## player_stat_label, an at-a-glance read the same way the mockup's mana
## crystals work. Capped so a high-max_resource class late-game doesn't
## turn this into a wall of dots - the text above always has the real
## number regardless.
const MAX_DISPLAYED_PIPS := 12

func _refresh_mana_pips() -> void:
	for child in mana_pip_row.get_children():
		mana_pip_row.remove_child(child)
		child.queue_free()
	if player.max_resource <= 0 or player.max_resource > MAX_DISPLAYED_PIPS:
		return
	for i in player.max_resource:
		var pip := PanelContainer.new()
		pip.custom_minimum_size = Vector2(10, 10)
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(5)
		if i < player.resource:
			style.bg_color = COL_PLAYER
			style.border_color = Color.WHITE
		else:
			style.bg_color = Color("#0a0d14")
			style.border_color = COL_PANEL_BORDER
		style.set_border_width_all(1)
		pip.add_theme_stylebox_override("panel", style)
		mana_pip_row.add_child(pip)

## Icon reused from the same effect-icon set cards use (tools/gen_card_icons.py)
## so "what kind of threat is this" reads the same visual language as "what
## kind of card is this" - no separate icon set to maintain.
const INTENT_ICON_EFFECTS := ["damage", "heal", "block", "empower_next", "dot", "aoe_damage", "execute"]

func _refresh_intent_display(enemy: Combatant) -> void:
	if enemy == null or not enemy.is_alive() or enemy_intent.is_empty():
		enemy_intent_icon.visible = false
		enemy_intent_label.visible = false
		return

	var effect: String = enemy_intent.get("effect", "damage")
	var move_name: String = enemy_intent.get("name", "???")
	var value: int = int(enemy_intent.get("value", 0))

	enemy_intent_label.visible = true
	if effect in ["damage", "dot", "execute"]:
		enemy_intent_label.text = "Next: %s (%d)" % [move_name, value]
	else:
		enemy_intent_label.text = "Next: %s" % move_name

	enemy_intent_icon.visible = effect in INTENT_ICON_EFFECTS
	if enemy_intent_icon.visible:
		var icon_path := "res://assets/icons/effect_%s.png" % effect
		if ResourceLoader.exists(icon_path):
			enemy_intent_icon.texture = load(icon_path)
		else:
			enemy_intent_icon.visible = false

func _refresh_ui() -> void:
	player_name_label.text = "%s\nHP %d/%d" % [player.display_name, player.hp, player.max_hp]
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.hp
	player_stat_label.text = "%s %d/%d  |  Block %d" % [
		player.resource_name, player.resource, player.max_resource, player.block,
	]
	_refresh_mana_pips()

	var enemy: Combatant = enemies[0] if enemies.size() > 0 else null
	if enemy != null:
		var status_text: String = "HP %d/%d" % [enemy.hp, enemy.max_hp] if enemy.is_alive() else "Defeated"
		enemy_name_label.text = "%s\n%s" % [enemy.display_name, status_text]
		enemy_hp_bar.max_value = enemy.max_hp
		enemy_hp_bar.value = enemy.hp
	_refresh_intent_display(enemy)

	var battle_over: bool = not player.is_alive() or _all_enemies_dead()

	# remove_child (synchronous) before queue_free (deferred delete) so a
	# menu switch within the same frame doesn't briefly count/see the old
	# children alongside the new ones - queue_free alone only marks them
	# for deletion at end-of-frame, leaving them in the tree until then.
	for child in card_grid.get_children():
		card_grid.remove_child(child)
		child.queue_free()

	if not battle_over and menu_state == "cards":
		for card_id in hand:
			var card := GameData.get_card(card_id)
			if card == null:
				continue
			var btn := _make_tray_button(
				"%s (%d)" % [card.display_name, card.cost],
				card.description,
				card.cost > player.resource,
				card.effect,
				TYPE_TINT.get(card.type, Color.WHITE),
			)
			btn.pressed.connect(_on_card_pressed.bind(card_id))
			card_grid.add_child(btn)
	elif not battle_over and menu_state == "items":
		for item_id in RunState.inventory.keys():
			var count: int = RunState.inventory[item_id]
			if count <= 0:
				continue
			var item := GameData.get_item(item_id)
			if item == null or item.effect == "":
				continue
			var btn := _make_tray_button("%s x%d" % [item.display_name, count], item.description, false)
			btn.pressed.connect(_on_item_button_pressed.bind(item_id))
			card_grid.add_child(btn)
	elif not battle_over:
		var hint := _make_centered_label()
		hint.text = "Choose Cards, Item, or Guard."
		hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_grid.add_child(hint)

	menu_row.visible = not battle_over
	menu_cards_button.disabled = battle_over
	menu_item_button.disabled = battle_over or not _has_usable_items()
	menu_guard_button.disabled = battle_over

	end_turn_button.disabled = battle_over
	end_turn_button.visible = not battle_over
	continue_button.visible = battle_over

func _on_continue_pressed() -> void:
	RunState.player = player
	if _all_enemies_dead():
		RunState.last_battle_outcome = "victory"
		RunState.last_battle_loot = _roll_loot(enemies[0])
	else:
		RunState.last_battle_outcome = "defeat"
		RunState.last_battle_loot = []
		player.hp = max(int(player.max_hp * 0.5), 1)

	if from_overworld:
		get_tree().change_scene_to_file("res://scenes/overworld.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _roll_loot(monster: Combatant) -> Array:
	var loot: Array = []
	for drop in monster.drop_table:
		var chance: float = float(drop.get("chance", 0))
		if randf() <= chance:
			loot.append(String(drop.get("item_id", "")))
	return loot

func _log(message: String) -> void:
	log_label.append_text(message + "\n")

## Rises and fades over `anchor` (a portrait) for ~0.8s, then frees itself -
## the per-hit "juice" a plain HP-bar-tick alone doesn't give. Uses
## global_position rather than the local `position` math the anchor's own
## parent chain would require, since the label is added as this Control's
## own direct child (arena_row nests portraits several levels deep, and
## global_position sidesteps having to account for that depth by hand).
func _spawn_floating_number(anchor: Control, text: String, color: Color) -> void:
	if anchor == null:
		return
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 100
	add_child(label)
	label.global_position = anchor.get_global_rect().get_center() + Vector2(-18, -50)

	var tween := create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 34, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.25)
	tween.tween_callback(label.queue_free)

## A brief jitter on the arena panel (the "stage") when a hit lands, same
## idea as the mockup's screen-shake - cheap, and it's the single biggest
## "does this attack actually feel like it landed" cue a static HP bar tick
## can't give on its own.
func _screen_shake() -> void:
	if arena_row == null:
		return
	var original_pos: Vector2 = arena_row.position
	var tween := create_tween()
	for i in 4:
		var offset := Vector2(randf_range(-4.0, 4.0), randf_range(-3.0, 3.0))
		tween.tween_property(arena_row, "position", original_pos + offset, 0.035)
	tween.tween_property(arena_row, "position", original_pos, 0.035)
