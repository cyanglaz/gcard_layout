@tool
@icon("res://addons/gcard_layout/resources/icons/card_base.svg")
class_name GCard
extends Control

@export_group("appearance")
@export var hovered_scale := Vector2(1.1, 1.1)
@export var dragging_scale := Vector2(1.1, 1.1)

@export_group("animation")
@export var animation_time := 0.1: set = _set_animation_time
@export var animation_ease := Tween.EASE_IN
@export var animation_trans := Tween.TRANS_QUAD

enum State {
	IDLE,
	DRAGGING,
	HOVER
}

signal gcard_hovered(card:GCard, on:bool)
signal gcard_dragging_started(card:GCard)
signal gcard_dragging_finished(card:GCard)

var state:State: set = _set_state
var idle_rotation:float

var _dragging_mouse_position:Vector2

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _process(_delta: float) -> void:
	if state == State.DRAGGING:
		global_position = get_global_mouse_position() - _dragging_mouse_position

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		var mouse_button_event = event as InputEventMouseButton
		if mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			state = State.DRAGGING
			_hovered = false
			_dragging_mouse_position = get_local_mouse_position()
			z_index = 1
			gcard_dragging_started.emit(self)
		elif !mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			state = State.IDLE
			z_index = 0
			gcard_dragging_finished.emit(self)

func _on_mouse_entered():
	if state != State.DRAGGING:
		state = State.HOVER
	
func _on_mouse_exited():
	if state != State.DRAGGING:
		state = State.IDLE

func _set_state(val:State):
	state = val
	var final_rotation := 0.0
	var final_scale := Vector2.ONE
	match state:
		State.IDLE:
			scale = Vector2.ONE
			final_rotation = idle_rotation
		State.HOVER:
			scale = hovered_scale
			final_rotation = 0.0
		State.DRAGGING:
			scale = dragging_scale
			final_rotation = 0.0
	if is_inside_tree() && animation_time > 0.0:
		var tween := create_tween()
		tween.parallel().tween_property(self, "scale", final_scale, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		if state != State.IDLE:
			tween.parallel().tween_property(self, "rotaion", final_rotation, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		tween.play()
	else:
		scale = final_scale
		if state != State.IDLE:
			rotation = final_rotation
