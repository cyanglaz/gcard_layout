@tool
@icon("res://addons/gcard_layout/resources/icons/card_base.svg")
class_name GCard
extends Control

signal gcard_hovered(card:GCard, on:bool)

var _hovered := false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if !_hovered:
		_hovered = true
		gcard_hovered.emit(self, true)
	
func _on_mouse_exited():
	if _hovered:
		_hovered = false
		gcard_hovered.emit(self, false)
