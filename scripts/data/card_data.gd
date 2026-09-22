class_name CardData
extends RefCounted

## A single card definition, loaded from res://data/cards.json.
## type is the player-facing category (action / spell / power); effect is
## what actually resolves when the card is played. combo_tag drives the
## combo system in combat.gd: playing cards with matching combo_tag back
## to back stacks a scaling bonus, which is how each class's deck (skewed
## toward one card type) ends up with a distinct playstyle.
##
## effect is one of the base kit (damage / heal / block / empower_next,
## available at every rank) or one of three mechanics content only starts
## using at specific ranks (see GDD.md's Combat System section): dot
## (D-rank+, lingering damage that bypasses block), aoe_damage (B-rank+,
## hits every living enemy), execute (S-rank+, bonus damage below 50% HP).

var id: String
var display_name: String
var type: String # "action" | "spell" | "power"
var class_id: String
var cost: int
var description: String
var effect: String # "damage" | "heal" | "block" | "empower_next" | "dot" | "aoe_damage" | "execute"
var base_value: int
var combo_tag: String

static func from_dict(data: Dictionary) -> CardData:
	var c := CardData.new()
	c.id = data.get("id", "")
	c.display_name = data.get("display_name", "Unknown Card")
	c.type = data.get("type", "action")
	c.class_id = data.get("class_id", "")
	c.cost = data.get("cost", 1)
	c.description = data.get("description", "")
	c.effect = data.get("effect", "damage")
	c.base_value = data.get("base_value", 0)
	c.combo_tag = data.get("combo_tag", c.type)
	return c
