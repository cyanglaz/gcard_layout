@tool
@icon("res://addons/gcard_layout/resources/icons/card_base.svg")
class_name GCard
extends Control

enum State {
	IDLE,
	DRAGGING,
	HOVER
}

signal state_updated(card:GCard, old_state:State, new_state:State)

@export_group("appearance")
@export var hovered_scale := Vector2(1.1, 1.1)
@export var dragging_scale := Vector2(1.1, 1.1)

var animation_time := 0.1
var animation_ease := Tween.EASE_IN
var animation_trans := Tween.TRANS_QUAD
var unhover_delay := 0.1

var state:State: set = _set_state
var idle_rotation:float : set = _set_idle_rotation

var _dragging_mouse_position:Vector2

func _validate_property(property):
	if property.name in ["animation_ease", "animation_trans"] && animation_time <= 0.0:
		property.usage = PROPERTY_USAGE_NO_EDITOR

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
			_dragging_mouse_position = get_local_mouse_position()
			z_index = 1
		elif !mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			state = State.IDLE
			z_index = 0

func _on_mouse_entered():
	if state != State.DRAGGING:
		state = State.HOVER
		z_index = 1
	
func _on_mouse_exited():
	if state != State.DRAGGING:
		await get_tree().create_timer(unhover_delay).timeout
		state = State.IDLE
		z_index = 0

func _set_state(val:State):
	if state == val:
		return
	var old_state = state
	state = val
	_reset_scale()
	_reset_rotation()
	state_updated.emit(self, old_state, state)

func _set_idle_rotation(val:float):
	if idle_rotation == val:
		return
	idle_rotation = val
	_reset_rotation()

func _reset_rotation():
	var final_rotation := 0.0
	match state:
		State.IDLE:
			final_rotation = idle_rotation
		State.HOVER:
			final_rotation = 0.0
		State.DRAGGING:
			final_rotation = 0.0
	if is_inside_tree() && animation_time > 0.0:
		var tween := create_tween()
		tween.tween_property(self, "rotation", final_rotation, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		tween.play()
	else:
		rotation = final_rotation

func _reset_scale():
	var final_scale := Vector2.ONE
	match state:
		State.IDLE:
			scale = Vector2.ONE
		State.HOVER:
			final_scale = hovered_scale
		State.DRAGGING:
			final_scale = dragging_scale
	if is_inside_tree() && animation_time > 0.0:
		var tween := create_tween()
		tween.tween_property(self, "scale", final_scale, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		tween.play()
	else:
		scale = final_scale
