class_name Minimap
extends Control

## A small top-down dot-grid of the current district: blocked cells dark,
## open cells lighter, mini-boss/boss cells (while still present) marked
## red, and the player a bright marker. Lets the player get their bearings
## without a real camera/scroll system, which the overworld doesn't have
## yet - see overworld.gd's doc comment on why grids bigger than the
## viewport are a known follow-up, not solved here.

const CELL_PX := 4

var district: DistrictData
var player_cell: Vector2i
var marker_cells: Array[Vector2i] = []

func setup(d: DistrictData) -> void:
	district = d
	custom_minimum_size = Vector2(d.grid_width * CELL_PX, d.grid_height * CELL_PX)

func update_player(cell: Vector2i) -> void:
	player_cell = cell
	queue_redraw()

func set_markers(cells: Array[Vector2i]) -> void:
	marker_cells = cells
	queue_redraw()

func _draw() -> void:
	if district == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), UITheme.COL_PANEL_BG)
	for y in district.grid_height:
		for x in district.grid_width:
			var blocked := false
			for b in district.blocked_cells:
				if b[0] == x and b[1] == y:
					blocked = true
					break
			var color: Color = Color(0.15, 0.15, 0.18) if blocked else Color(0.35, 0.48, 0.52)
			draw_rect(Rect2(x * CELL_PX, y * CELL_PX, CELL_PX - 1, CELL_PX - 1), color)

	for m in marker_cells:
		draw_rect(Rect2(m.x * CELL_PX, m.y * CELL_PX, CELL_PX - 1, CELL_PX - 1), Color(0.9, 0.2, 0.2))

	draw_rect(Rect2(player_cell.x * CELL_PX, player_cell.y * CELL_PX, CELL_PX - 1, CELL_PX - 1), Color(1.0, 0.95, 0.3))
