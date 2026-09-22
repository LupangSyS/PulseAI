extends Control

## Turn-based combat prototype: deck -> hand -> discard, Action/Spell/Power
## cards, and a combo system where playing cards with the same combo_tag
## back-to-back stacks a scaling bonus. Which tag a class's deck leans on
## (mostly Spell for the Mage, mostly Action for the Hunter, etc.) is what
## gives each class a distinct feel without any per-class special-case code.
##
## Card effects: damage, heal, block, empower_next (base kit, all ranks),
## plus three rank-gated mechanics introduced by content at D/B/S rank:
## dot (lingering damage that bypasses block, ticks down each enemy turn),
## aoe_damage (hits every living enemy), and execute (bonus damage against
## a target below half HP). The encounter itself still only ever spawns one
## enemy by default - enemies is an Array so aoe_damage has real multiple
## targets to hit once multi-enemy encounters exist, but that's an
## architectural readiness, not a shipped feature yet (see GDD.md roadmap).
##
## UI is built entirely in code (no hand-authored .tscn layout) so this
## scene is safe to review as plain text and swap for real pixel-art
## widgets later without touching the combat logic below.

const STARTING_HAND_SIZE := 4
const ENEMY_ATTACK_DAMAGE := 6

var player: Combatant
var enemies: Array[Combatant] = []
var player_class: CharacterClass

var draw_pile: Array[String] = []
var hand: Array[String] = []
var discard_pile: Array[String] = []

var combo_tag: String = ""
var combo_count: int = 0
var empower_bonus: int = 0

var status_label: Label
var enemy_label: Label
var log_label: RichTextLabel
var hand_container: HBoxContainer
var end_turn_button: Button

func _ready() -> void:
	_build_ui()
	_start_battle("mage_f")

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var root_box := VBoxContainer.new()
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_box.add_theme_constant_override("separation", 12)
	add_child(root_box)

	status_label = Label.new()
	enemy_label = Label.new()
	root_box.add_child(status_label)
	root_box.add_child(enemy_label)

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 140)
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(log_label)

	hand_container = HBoxContainer.new()
	hand_container.add_theme_constant_override("separation", 8)
	root_box.add_child(hand_container)

	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	root_box.add_child(end_turn_button)

func _start_battle(class_id: String) -> void:
	player_class = GameData.get_class_by_id(class_id)
	player = Combatant.new(player_class.display_name, player_class.max_hp, player_class.max_resource, player_class.resource_name)
	enemies = [Combatant.new("Flooded Ghoul", 25, 0, "")]

	draw_pile = player_class.deck.duplicate()
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	combo_tag = ""
	combo_count = 0
	empower_bonus = 0

	_log("[b]%s[/b] surfaces in the drowned ruins. Something lurches from the water." % player.display_name)
	_draw_cards(STARTING_HAND_SIZE)
	_refresh_ui()

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
	var value: int = card.base_value + empower_bonus
	empower_bonus = 0
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
			empower_bonus = value
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
		if not e.is_alive():
			continue
		if e.dot_stacks > 0:
			var dot_damage: int = e.tick_dot()
			_log("The lingering power in %s deals %d damage." % [e.display_name, dot_damage])
			if not e.is_alive():
				_log("[color=gold]%s succumbs to the lingering damage.[/color]" % e.display_name)
				continue
		var dealt: int = player.take_damage(ENEMY_ATTACK_DAMAGE)
		_log("The %s claws at %s for %d damage." % [e.display_name, player.display_name, dealt])
	if not player.is_alive():
		_log("[color=red]%s is dragged beneath the flood. Defeat.[/color]" % player.display_name)

func _start_player_turn() -> void:
	player.block = 0
	player.refill_resource()
	combo_tag = ""
	combo_count = 0
	_draw_cards(STARTING_HAND_SIZE - hand.size())

func _refresh_ui() -> void:
	status_label.text = "%s  |  HP %d/%d  |  %s %d/%d  |  Block %d" % [
		player.display_name, player.hp, player.max_hp,
		player.resource_name, player.resource, player.max_resource,
		player.block,
	]

	var enemy_text := ""
	for e in enemies:
		var status_text: String = "HP %d/%d" % [e.hp, e.max_hp] if e.is_alive() else "Defeated"
		enemy_text += "%s  |  %s\n" % [e.display_name, status_text]
	enemy_label.text = enemy_text.strip_edges()

	for child in hand_container.get_children():
		child.queue_free()

	var battle_over: bool = not player.is_alive() or _all_enemies_dead()
	for card_id in hand:
		var card := GameData.get_card(card_id)
		if card == null:
			continue
		var button := Button.new()
		button.text = "%s (%d)\n%s" % [card.display_name, card.cost, card.description]
		button.disabled = battle_over or card.cost > player.resource
		button.pressed.connect(_on_card_pressed.bind(card_id))
		hand_container.add_child(button)

	end_turn_button.disabled = battle_over

func _log(message: String) -> void:
	log_label.append_text(message + "\n")
