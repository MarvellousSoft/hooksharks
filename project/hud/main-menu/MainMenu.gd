extends Control

onready var camera = $Camera2D
onready var title = $Title
onready var subtitle = $Subtitle
onready var tween = $Tween
onready var title_pos = title.rect_position
onready var subtitle_pos = subtitle.rect_position

const TITLE_OFFSET = Vector2(5000, 0)
const TITLE_DELAY = .5
const GLOW_DURATION = 1
const PRESS_START_DELAY = 3

export (PackedScene)var ModeSelect

var title_shown = false


func _ready():
	title.rect_position = title.rect_position -\
			TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))
	subtitle.rect_position = subtitle.rect_position +\
			TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))
	
	tween.interpolate_property(title, "rect_position", null, title_pos, 1.5,
			Tween.TRANS_LINEAR, Tween.EASE_OUT, TITLE_DELAY)
	tween.interpolate_property(subtitle, "rect_position", null, subtitle_pos,
			1.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, TITLE_DELAY)
	tween.start()
	
	yield(tween, "tween_completed")
	show_title()


func _input(event):
	if event.is_action_pressed("ui_start"):
		if not title_shown:
			show_title()
		else:
			change_screen()


func show_title():
	if title_shown:
		return
	
	title_shown = true
	
	tween.stop_all()
	title.rect_position = title_pos
	subtitle.rect_position = subtitle_pos
	
	tween.interpolate_property($CanvasLayer/ScreenGlow, "modulate:a", 1, 0,
			GLOW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	camera.add_shake(1)
	
	yield(get_tree().create_timer(PRESS_START_DELAY), "timeout")
	$PressStart/AnimationPlayer.play("show")


func change_screen():
	get_tree().change_scene_to(ModeSelect)