@tool
@icon("res://addons/gcard_layout/resources/icons/card_base.svg")
class_name GCard
extends Control

signal gcard_hovered(card:GCard, on:bool)
signal gcard_dragging_started(card:GCard)
signal gcard_dragging_finished(card:GCard)


var _hovered := false : set = _set_hovered
var _dragging := false

var _dragging_mouse_position:Vector2

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position() - _dragging_mouse_position

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		var mouse_button_event = event as InputEventMouseButton
		if mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = true
			_hovered = false
			_dragging_mouse_position = get_local_mouse_position()
			z_index = 1
			gcard_dragging_started.emit(self)
		elif !mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = false
			z_index = 0
			gcard_dragging_finished.emit(self)

func _on_mouse_entered():
	if !_dragging:
		_hovered = true
	
func _on_mouse_exited():
	if !_dragging:
		_hovered = false

func _set_hovered(val:bool):
	if _hovered == val:
		return
	_hovered = val
	if _dragging:
		return
	gcard_hovered.emit(self, _hovered)
