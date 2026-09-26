class_name UITheme
extends RefCounted

## The dark "combat terminal" look introduced in combat.gd, extracted so
## every screen (overworld, main menu, status menu, combat) shares one
## palette and one Theme resource instead of each scene re-deriving its
## own StyleBoxFlats. A screen adopts it with `theme = UITheme.build()` in
## its own _build_ui(); every Button/Label/PanelContainer under that root
## picks the shared styling up automatically, including nodes created
## later at runtime (card buttons, tray buttons, HUD rows, etc).
##
## "player=cyan, enemy/danger=rose, warning=amber" is the color language
## established in combat.gd and kept consistent everywhere this is used.

const COL_BG := Color("#05070c")
const COL_PANEL_BG := Color("#0d121c")
const COL_PANEL_BORDER := Color("#1e293b")
const COL_HAZARD_BORDER := Color("#7f1d1d")
const COL_PLAYER := Color("#38bdf8")
const COL_ENEMY := Color("#f43f5e")
const COL_WARNING := Color("#f59e0b")
const COL_GOOD := Color("#4ade80")
const COL_RESOURCE := Color("#a78bfa")
const COL_TEXT := Color("#dbe4f0")
const COL_TEXT_DIM := Color("#8b96ab")

static func panel_style(border: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COL_PANEL_BG
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	return style

## Applies matching background/fill StyleBoxFlats directly to a ProgressBar
## (HP/resource bars aren't picked up by the shared Theme's PanelContainer/
## Button styles, so each bar needs this called once after creation).
static func style_bar(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("#0a0d14")
	bg.border_color = COL_PANEL_BORDER
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)

static func build() -> Theme:
	var t := Theme.new()

	t.set_stylebox("panel", "PanelContainer", panel_style(COL_PANEL_BORDER))

	var btn_normal := panel_style(COL_PANEL_BORDER, 2)
	var btn_hover := panel_style(COL_PLAYER, 2)
	var btn_pressed := panel_style(COL_PLAYER, 2)
	btn_pressed.bg_color = Color("#182335")
	var btn_disabled := panel_style(Color("#232b3d"), 2)
	btn_disabled.bg_color = Color("#0a0d14")

	t.set_stylebox("normal", "Button", btn_normal)
	t.set_stylebox("hover", "Button", btn_hover)
	t.set_stylebox("pressed", "Button", btn_pressed)
	t.set_stylebox("focus", "Button", btn_hover)
	t.set_stylebox("disabled", "Button", btn_disabled)
	t.set_color("font_color", "Button", COL_TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", COL_TEXT_DIM)

	t.set_color("font_color", "Label", COL_TEXT)
	t.set_color("font_color", "RichTextLabel", COL_TEXT)
	t.set_color("default_color", "RichTextLabel", COL_TEXT)

	return t
