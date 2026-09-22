extends Control

## Turn-based combat prototype: deck -> hand -> discard, Action/Spell/Power
## cards, and a combo system where playing cards with the same combo_tag
## back-to-back stacks a scaling bonus. Which tag a class's deck leans on
## (mostly Spell for the Mage, mostly Action for the Hunter, etc.) is what
## gives each class a distinct feel without any per-class special-case code.
##
## UI is built entirely in code (no hand-authored .tscn layout) so this
## scene is safe to review as plain text and swap for real pixel-art
## widgets later without touching the combat logic below.

const STARTING_HAND_SIZE := 4
const ENEMY_ATTACK_DAMAGE := 6

var player: Combatant
var enemy: Combatant
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
	enemy = Combatant.new("Flooded Ghoul", 25, 0, "")

	draw_pile = player_class.deck.duplicate()
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	combo_tag = ""
	combo_count = 0
	empower_bonus = 0

	_log("[b]%s[/b] surfaces in the drowned ruins. A [b]%s[/b] lurches from the water." % [player.display_name, enemy.display_name])
	_draw_cards(STARTING_HAND_SIZE)
	_refresh_ui()

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
	if not player.is_alive() or not enemy.is_alive():
		return
	var card := GameData.get_card(card_id)
	if card == null or player.resource < card.cost:
		return

	player.resource -= card.cost
	hand.erase(card_id)
	discard_pile.append(card_id)

	_update_combo(card)
	_apply_card_effect(card)

	if not enemy.is_alive():
		_log("[color=gold]The %s dissolves back into the floodwater. Victory.[/color]" % enemy.display_name)

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

	match card.effect:
		"damage":
			var total: int = int(round(value * _combo_multiplier()))
			enemy.take_damage(total)
			_log("%s uses [i]%s[/i] for %d damage. (combo x%d)" % [player.display_name, card.display_name, total, combo_count])
		"heal":
			var total: int = int(round(value * _combo_multiplier()))
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
	if not player.is_alive() or not enemy.is_alive():
		return
	discard_pile.append_array(hand)
	hand.clear()

	_enemy_turn()
	if player.is_alive():
		_start_player_turn()

	_refresh_ui()

func _enemy_turn() -> void:
	if not enemy.is_alive():
		return
	var dealt: int = player.take_damage(ENEMY_ATTACK_DAMAGE)
	_log("The %s claws at %s for %d damage." % [enemy.display_name, player.display_name, dealt])
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
	enemy_label.text = "%s  |  HP %d/%d" % [enemy.display_name, enemy.hp, enemy.max_hp]

	for child in hand_container.get_children():
		child.queue_free()

	var battle_over: bool = not player.is_alive() or not enemy.is_alive()
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
