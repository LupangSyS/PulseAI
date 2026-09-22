class_name CharacterClass
extends RefCounted

## A playable class definition, loaded from res://data/classes.json.
## Ranks run F -> E -> D -> C -> B -> A -> S. Every class starts is_hidden = true;
## nothing about it (name, art, existence) should be shown to the player until
## it has been discovered in-world (quest, accident, environmental trigger).

var id: String
var display_name: String
var rank: String
var is_hidden: bool
var locked_description: String
var unlocked_description: String
var playstyle: String
var max_hp: int
var max_resource: int
var resource_name: String
var deck: Array[String]
var evolves_from: String
var evolves_to: Array[String]
var evolution_hint: String
var unlock_type: String

static func from_dict(data: Dictionary) -> CharacterClass:
	var c := CharacterClass.new()
	c.id = data.get("id", "")
	c.display_name = data.get("display_name", "???")
	c.rank = data.get("rank", "F")
	c.is_hidden = data.get("is_hidden", true)
	c.locked_description = data.get("locked_description", "A path yet undiscovered.")
	c.unlocked_description = data.get("unlocked_description", "")
	c.playstyle = data.get("playstyle", "")
	c.max_hp = data.get("max_hp", 20)
	c.max_resource = data.get("max_resource", 3)
	c.resource_name = data.get("resource_name", "Mana")

	c.deck = []
	for card_id in data.get("deck", []):
		c.deck.append(String(card_id))

	c.evolves_from = data.get("evolves_from", "")

	c.evolves_to = []
	for evo_id in data.get("evolves_to", []):
		c.evolves_to.append(String(evo_id))

	c.evolution_hint = data.get("evolution_hint", "")
	c.unlock_type = data.get("unlock_type", "hidden_event")
	return c
