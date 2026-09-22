extends Node

## Autoload singleton (see project.godot [autoload]).
## Loads every class, card, monster, item, and district definition from
## res://data/*.json at startup so new content can be added by editing
## JSON, no code changes needed.

var classes: Dictionary = {} # id (String) -> CharacterClass
var cards: Dictionary = {} # id (String) -> CardData
var monsters: Dictionary = {} # id (String) -> MonsterData
var items: Dictionary = {} # id (String) -> ItemData
var districts: Dictionary = {} # id (String) -> DistrictData

func _ready() -> void:
	_load_cards()
	_load_classes()
	_load_monsters()
	_load_items()
	_load_districts()

func get_class_by_id(id: String) -> CharacterClass:
	return classes.get(id)

func get_card(id: String) -> CardData:
	return cards.get(id)

func get_monster(id: String) -> MonsterData:
	return monsters.get(id)

func get_item(id: String) -> ItemData:
	return items.get(id)

func get_district(id: String) -> DistrictData:
	return districts.get(id)

func _load_classes() -> void:
	var data = _load_json("res://data/classes.json")
	if data == null:
		return
	for entry in data:
		var c := CharacterClass.from_dict(entry)
		classes[c.id] = c

func _load_cards() -> void:
	var data = _load_json("res://data/cards.json")
	if data == null:
		return
	for entry in data:
		var c := CardData.from_dict(entry)
		cards[c.id] = c

func _load_monsters() -> void:
	var data = _load_json("res://data/monsters.json")
	if data == null:
		return
	for entry in data:
		var m := MonsterData.from_dict(entry)
		monsters[m.id] = m

func _load_items() -> void:
	var data = _load_json("res://data/items.json")
	if data == null:
		return
	for entry in data:
		var i := ItemData.from_dict(entry)
		items[i.id] = i

func _load_districts() -> void:
	var data = _load_json("res://data/districts.json")
	if data == null:
		return
	for entry in data:
		var d := DistrictData.from_dict(entry)
		districts[d.id] = d

func _load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var result: Variant = JSON.parse_string(text)
	if result == null:
		push_error("Failed to parse JSON: %s" % path)
	return result
