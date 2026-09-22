class_name SpriteLoader
extends RefCounted

## Builds a small 2-frame idle-animated sprite for a class/monster id, or a
## plain ColorRect if no generated art exists for it yet. Most ids DON'T
## have art (see GDD.md - only Sukhumvit Shallows' cast does), so the
## fallback path is the common case, not an edge case, and must never
## error or print warnings for a missing id.
##
## Art convention: res://assets/sprites/<kind>s/<id>_idle1.png and
## _idle2.png, both true 32x32 RGBA (real alpha, not a drawn checkerboard).
## `kind` is "character" or "monster".

const ROOTS := {
	"character": "res://assets/sprites/characters/",
	"monster": "res://assets/sprites/monsters/",
}

static func has_art(id: String, kind: String) -> bool:
	var root: String = ROOTS.get(kind, "")
	if root == "":
		return false
	return ResourceLoader.exists(root + id + "_idle1.png") and ResourceLoader.exists(root + id + "_idle2.png")

## Returns [frame1: Texture2D, frame2: Texture2D], or [] if no art exists.
static func load_frames(id: String, kind: String) -> Array:
	if not has_art(id, kind):
		return []
	var root: String = ROOTS[kind]
	return [load(root + id + "_idle1.png"), load(root + id + "_idle2.png")]

## For the overworld (Node2D-based free positioning): an AnimatedSprite2D
## already playing its idle loop, or a ColorRect fallback sized/colored by
## the caller. Position is left at (0,0) - callers position both node
## types uniformly via a helper like overworld.gd's _position_visual_at_cell.
static func build_sprite(id: String, kind: String, fallback_color: Color, fallback_size: Vector2, sprite_scale: float = 1.0) -> Node:
	var frames: Array = load_frames(id, kind)
	if frames.is_empty():
		var rect := ColorRect.new()
		rect.color = fallback_color
		rect.size = fallback_size
		return rect

	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 2.0)
	sprite_frames.add_frame("idle", frames[0])
	sprite_frames.add_frame("idle", frames[1])

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = sprite_frames
	sprite.animation = "idle"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.play()
	return sprite
