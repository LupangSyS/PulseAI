class_name MonsterData
extends RefCounted

## A monster/enemy definition, loaded from res://data/monsters.json.
## Regular mobs use a flat, weighted move list the AI picks from each
## turn (see combat.gd's monster-turn resolution). Mini-bosses/bosses
## additionally define `stages`: entries are checked in order, and the
## first one whose trigger_hp_pct is still >= the monster's current HP
## fraction that hasn't already fired swaps the active move list (and
## optionally a display-name suffix, e.g. "(Enraged)") and logs
## transition_text. This is how a single monster definition becomes a
## multi-phase mini-boss/boss fight without any new data format.
##
## Moves and stage move-lists are plain Dictionaries (not their own
## Resource/RefCounted class) since they're small and only ever read,
## never round-tripped: {name, description, effect, value, weight}.
## effect reuses the exact same vocabulary combat.gd already resolves
## for player cards (damage/heal/block/dot/execute) - "aoe_damage" is
## deliberately not offered to monsters since there is only one player
## target right now, so it would be identical to "damage".
##
## `stages` entries are {trigger_hp_pct, display_name, transition_text,
## moves} and MUST be ordered descending by trigger_hp_pct - combat.gd's
## _check_stage_transitions only ever looks at stages[0] and pops it once
## crossed, so an out-of-order list will trigger stages in the wrong order.

var id: String
var display_name: String
var description: String
var rank: String
var max_hp: int
var is_miniboss: bool
var is_boss: bool
var moves: Array # Array[Dictionary]
var stages: Array # Array[Dictionary]
var drop_table: Array # Array[Dictionary] {item_id, chance}

static func from_dict(data: Dictionary) -> MonsterData:
	var m := MonsterData.new()
	m.id = data.get("id", "")
	m.display_name = data.get("display_name", "???")
	m.description = data.get("description", "")
	m.rank = data.get("rank", "F")
	m.max_hp = data.get("max_hp", 20)
	m.is_miniboss = data.get("is_miniboss", false)
	m.is_boss = data.get("is_boss", false)

	m.moves = []
	for move in data.get("moves", []):
		m.moves.append(move)

	m.stages = []
	for stage in data.get("stages", []):
		m.stages.append(stage)

	m.drop_table = []
	for drop in data.get("drop_table", []):
		m.drop_table.append(drop)

	return m
