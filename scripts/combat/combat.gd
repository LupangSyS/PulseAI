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
var log_label: RichTextLabel
var menu_row: HBoxContainer
var menu_cards_button: Button
var menu_item_button: Button
var menu_guard_button: Button
var card_scroll: ScrollContainer
var card_grid: GridContainer
var end_turn_button: Button
var continue_button: Button

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

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 8)
	add_child(margin)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 6)
	margin.add_child(root_box)

	# --- Arena: player (left) vs. enemy (right), each with a portrait,
	# name + HP readout, and a visual HP bar.
	var arena_row := HBoxContainer.new()
	arena_row.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_theme_constant_override("separation", 28)
	arena_row.custom_minimum_size = Vector2(0, 150)
	root_box.add_child(arena_row)

	var player_panel := VBoxContainer.new()
	player_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_child(player_panel)
	player_portrait = _make_portrait()
	player_panel.add_child(player_portrait)
	player_name_label = _make_centered_label(11)
	player_panel.add_child(player_name_label)
	player_hp_bar = _make_hp_bar()
	player_panel.add_child(player_hp_bar)

	var enemy_panel := VBoxContainer.new()
	enemy_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	arena_row.add_child(enemy_panel)
	enemy_portrait = _make_portrait()
	enemy_panel.add_child(enemy_portrait)
	enemy_name_label = _make_centered_label(11)
	enemy_panel.add_child(enemy_name_label)
	enemy_hp_bar = _make_hp_bar()
	enemy_panel.add_child(enemy_hp_bar)

	# --- Compact resource/block readout beneath the arena.
	player_stat_label = _make_centered_label()
	root_box.add_child(player_stat_label)

	# --- Battle log: fixed height, does not expand.
	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 42)
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	root_box.add_child(log_label)

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
	# End Turn off-screen.
	card_scroll = ScrollContainer.new()
	card_scroll.custom_minimum_size = Vector2(0, 116)
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_box.add_child(card_scroll)

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

func _make_hp_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(110, 12)
	bar.min_value = 0
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return bar

## A tray entry (hand card or item): a Button used purely as the click
## target (text left empty) wrapping a VBoxContainer of real Labels, so
## the description can word-wrap instead of overflowing the button's
## fixed width. Every descendant is set to MOUSE_FILTER_IGNORE so clicks
## pass through to the Button itself rather than being eaten by a child.
func _make_tray_button(title: String, description: String, is_disabled: bool) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(208, 50)
	btn.disabled = is_disabled

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.add_theme_constant_override("separation", 2)
	btn.add_child(vb)

	var title_label := Label.new()
	title_label.text = title
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(title_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 10)
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
		"aoe_damage":
			var total: int = int(round(value * multiplier))
			var hit_count := 0
			for e in enemies:
				if e.is_alive():
					e.take_damage(total)
					hit_count += 1
			_log("%s unleashes [i]%s[/i] for %d damage to %d foe(s). (combo x%d)" % [player.display_name, card.display_name, total, hit_count, combo_count])
		"dot":
			var target := _first_alive_enemy()
			if target == null:
				return
			var stacks: int = int(round(value * multiplier))
			target.apply_dot(stacks)
			_log("%s brands the enemy with [i]%s[/i], a lingering power now dealing %d damage a turn. (combo x%d)" % [player.display_name, card.display_name, target.dot_stacks, combo_count])
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
		"heal":
			var total: int = int(round(value * multiplier))
			player.heal(total)
			_log("%s channels [i]%s[/i], healing %d." % [player.display_name, card.display_name, total])
		"block":
			player.add_block(value)
			_log("%s raises [i]%s[/i], gaining %d block." % [player.display_name, card.display_name, value])
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
		_check_stage_transitions(e)
		if not e.is_alive():
			continue
		_resolve_monster_turn(e)
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

func _resolve_monster_turn(e: Combatant) -> void:
	if e.moves.is_empty():
		return
	var move: Dictionary = _pick_weighted_move(e.moves)
	_apply_monster_move(e, move)

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
		"dot":
			player.apply_dot(value)
			_log("%s uses [i]%s[/i], a lingering harm now dealing %d damage a turn." % [e.display_name, move_name, player.dot_stacks])
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
		"heal":
			e.heal(value)
			_log("%s uses [i]%s[/i], recovering %d HP." % [e.display_name, move_name, value])
		"block":
			e.add_block(value)
			_log("%s uses [i]%s[/i], gaining %d block." % [e.display_name, move_name, value])
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

func _refresh_ui() -> void:
	player_name_label.text = "%s\nHP %d/%d" % [player.display_name, player.hp, player.max_hp]
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.hp
	player_stat_label.text = "%s %d/%d  |  Block %d" % [
		player.resource_name, player.resource, player.max_resource, player.block,
	]

	var enemy: Combatant = enemies[0] if enemies.size() > 0 else null
	if enemy != null:
		var status_text: String = "HP %d/%d" % [enemy.hp, enemy.max_hp] if enemy.is_alive() else "Defeated"
		enemy_name_label.text = "%s\n%s" % [enemy.display_name, status_text]
		enemy_hp_bar.max_value = enemy.max_hp
		enemy_hp_bar.value = enemy.hp

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
