class_name ItemData
extends RefCounted

## An item definition, loaded from res://data/items.json. Kept deliberately
## simple for the first district: a consumable (usable from the overworld,
## effect + value reuse the heal/block vocabulary), a key/quest item, or a
## curio with no mechanical effect yet (currency/crafting hooks are a
## Phase 2 idea - see GDD.md). effect == "" means "not usable," just
## collected.

var id: String
var display_name: String
var description: String
var rarity: String # "common" | "uncommon" | "rare" | "unique"
var effect: String # "" | "heal" | "restore_resource"
var value: int

static func from_dict(data: Dictionary) -> ItemData:
	var i := ItemData.new()
	i.id = data.get("id", "")
	i.display_name = data.get("display_name", "???")
	i.description = data.get("description", "")
	i.rarity = data.get("rarity", "common")
	i.effect = data.get("effect", "")
	i.value = data.get("value", 0)
	return i
