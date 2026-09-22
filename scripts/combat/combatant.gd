class_name Combatant
extends RefCounted

var display_name: String
var max_hp: int
var hp: int
var max_resource: int
var resource: int
var resource_name: String
var block: int = 0
var dot_stacks: int = 0

func _init(p_name: String, p_hp: int, p_resource: int, p_resource_name: String = "Mana") -> void:
	display_name = p_name
	max_hp = p_hp
	hp = p_hp
	max_resource = p_resource
	resource = p_resource
	resource_name = p_resource_name

func is_alive() -> bool:
	return hp > 0

## Returns the amount of damage that actually got through block.
func take_damage(amount: int) -> int:
	var absorbed: int = min(block, amount)
	block -= absorbed
	var remaining: int = amount - absorbed
	hp = max(hp - remaining, 0)
	return remaining

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)

func add_block(amount: int) -> void:
	block += amount

func refill_resource() -> void:
	resource = max_resource

func apply_dot(amount: int) -> void:
	dot_stacks += amount

## Deals dot_stacks damage (bypassing block, unlike take_damage), then lets
## the lingering effect fade by half. Returns the damage dealt.
func tick_dot() -> int:
	if dot_stacks <= 0:
		return 0
	var damage: int = dot_stacks
	hp = max(hp - damage, 0)
	dot_stacks = int(dot_stacks / 2.0)
	return damage
