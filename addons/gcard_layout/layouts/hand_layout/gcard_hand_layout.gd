@tool
@icon("res://addons/gcard_layout/resources/icons/card_hand_layout.svg")
class_name GCardHandLayout
extends Control

signal card_hoverd(card:Control, index:int)
signal card_unhovered(card:Control, index:int)

@export_group("idle layout")
@export var dynamic_radius := true: set = _set_dynamic_radius
@export var dynamic_radius_factor:float = 100.0: set = _set_dynamic_radius_factor
@export var radius := 1000: set = _set_radius
@export var circle_percentage:float = 0.05: set = _set_circle_percentage
@export var card_size:Vector2: set = _set_card_size

@export_group("hover layout")
@export var handle_mouse_hover_animaiton := true
@export var hovered_index := -1: set = _set_hovered_index
@export var hover_padding := 40.0: set = _set_hover_padding
@export var hovered_scale := Vector2(1.1, 1.1)
@export var unhover_delay := 0.1

@export_group("animation")
@export var animation_time := 0.1: set = _set_animation_time
@export var animation_ease := Tween.EASE_IN
@export var animation_trans := Tween.TRANS_QUAD

@export_group("sounds")
@export var hover_sound:AudioStreamPlayer2D

var gcard_hand_layout_service := GCardHandLayoutService.new()

func _ready():
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_existing_tree)
	child_order_changed.connect(_on_child_order_changed)
	for card in get_children():
		card.gcard_hovered.connect(_on_gcard_hovered)
	_reset_positions(false, false)
	
func _enter_tree():
	if is_node_ready():
		_reset_positions(false, false)
	
func _validate_property(property):
	if property.name in ["radius"] && dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["dynamic_radius_factor"] && !dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["animation_ease", "animation_trans"] && animation_time <= 0.0:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _reset_positions(reculculate_curve:bool = false, animated:bool = true):
	var number_of_cards := get_child_count()
	gcard_hand_layout_service.number_of_cards = number_of_cards
	gcard_hand_layout_service.dynamic_radius = dynamic_radius
	gcard_hand_layout_service.dynamic_radius_factor = dynamic_radius_factor
	gcard_hand_layout_service.radius = radius
	gcard_hand_layout_service.circle_percentage = circle_percentage
	gcard_hand_layout_service.card_size = card_size
	gcard_hand_layout_service.hover_padding = hover_padding
	gcard_hand_layout_service.hovered_index = hovered_index
	var layout_infos := gcard_hand_layout_service.get_card_layouts()
	for i in number_of_cards:
		var card:Control = get_children()[i]
		var layout_info:GCardLayoutInfo = layout_infos[i]
		if animation_time <= 0.0 || !animated:
			card.position = layout_info.position
			card.rotation = layout_info.rotation
			if i == hovered_index:
				card.scale = hovered_scale
			else:
				card.scale = Vector2.ONE
		else:
			var tween := create_tween()
			tween.tween_property(card, "position", layout_info.position, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			tween.parallel().tween_property(card, "rotation", layout_info.rotation, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			if i == hovered_index:
				tween.parallel().tween_property(card, "scale", hovered_scale, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			else:
				tween.parallel().tween_property(card, "scale", Vector2.ONE, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			
func _set_dynamic_radius(val:bool):
	dynamic_radius = val
	notify_property_list_changed()
	_reset_positions()

func _set_dynamic_radius_factor(val:float):
	dynamic_radius_factor = val
	_reset_positions()

func _set_radius(val:float):
	radius = val
	_reset_positions()
	
func _set_circle_percentage(val:float):
	circle_percentage = val
	_reset_positions()
	
func _set_card_size(val:Vector2):
	card_size = val
	_reset_positions()

func _set_hovered_index(val:int):
	hovered_index = val
	if hovered_index == -1:
		await get_tree().create_timer(unhover_delay).timeout
		if hovered_index == -1:
			_reset_positions()
	else:
		_reset_positions()

func _set_hover_padding(val:float):
	hover_padding = val
	_reset_positions()

func _set_animation_time(val:float):
	animation_time = val
	notify_property_list_changed()
			
func _on_child_entered_tree(child:Node):
	_reset_positions()
	(child as GCard).gcard_hovered.connect(_on_gcard_hovered)

func _on_child_existing_tree(_child:Node):
	_reset_positions()

func _on_child_order_changed():
	_reset_positions()
	
func _on_gcard_hovered(card:GCard, on:bool):
	if handle_mouse_hover_animaiton:
		var index := get_children().find(card)
		if !on:
			card.z_index = 0
			card_unhovered.emit(card, index)
			hovered_index = -1
		else:
			if hover_sound:
				hover_sound.play()
			card_hoverd.emit(card, index)
			hovered_index = index
			card.z_index = 1
