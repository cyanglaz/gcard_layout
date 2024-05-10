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
@export var unhover_delay := 0.1

@export_group("animation")
@export var animation_time := 0.1: set = _set_animation_time
@export var animation_ease := Tween.EASE_IN
@export var animation_trans := Tween.TRANS_QUAD

@export_group("sounds")
@export var hover_sound:AudioStreamPlayer2D

var gcard_hand_layout_service := GCardHandLayoutService.new()
var _dragging_index:int = -1

func _ready():
	_dragging_index = -1
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_existing_tree)
	child_order_changed.connect(_on_child_order_changed)
	for card in get_children():
		(card as GCard).state_updated.connect(_on_gcard_state_updated)
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
		card.animation_time = animation_time
		card.animation_ease = animation_ease
		card.animation_trans = animation_trans
		card.unhover_delay = unhover_delay
		var layout_info:GCardLayoutInfo = layout_infos[i]
		card.idle_rotation = layout_info.rotation
		if animation_time <= 0.0 || !animated:
			card.position = layout_info.position
		else:
			var tween := create_tween()
			if i != _dragging_index:
				tween.tween_property(card, "position", layout_info.position, animation_time).set_ease(animation_ease).set_trans(animation_trans)
				tween.play()
			
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
	if Engine.is_editor_hint():
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
	(child as GCard).state_updated.connect(_on_gcard_state_updated)

func _on_child_existing_tree(_child:Node):
	_reset_positions()

func _on_child_order_changed():
	_reset_positions()
	
func _on_gcard_hovered(card:GCard, enter:bool):
	#if enter:
		#for child_card in get_children():
			#child_card.enable_mouse_enter = card == child_card
	#else:
		#for child_card in get_children():
			#child_card.enable_mouse_enter = true
	if handle_mouse_hover_animaiton:
		var index := get_children().find(card)
		if enter:
			if hover_sound:
				hover_sound.play()
			card_hoverd.emit(card, index)
			hovered_index = index
		else:
			if hovered_index == index:
				hovered_index = -1
				card_unhovered.emit(card, index)
		_reset_positions()

func _on_gcard_dragging_started(card:GCard):
	for child_card in get_children():
		child_card.enable_mouse_enter = card == child_card
	var index := get_children().find(card)
	_dragging_index = index
	_reset_positions()
	
func _on_gcard_dragging_finished(card:GCard):
	for child_card in get_children():
		child_card.enable_mouse_enter = true
	_dragging_index = -1
	_reset_positions()

func _on_gcard_state_updated(card:GCard, old_state:GCard.State, new_state:GCard.State):
	if old_state == new_state:
		return
	if old_state == GCard.State.DRAGGING:
		_on_gcard_dragging_finished(card)
	elif new_state == GCard.State.DRAGGING:
		_on_gcard_dragging_started(card)
	if old_state == GCard.State.HOVER:
		_on_gcard_hovered(card, false)
	elif new_state == GCard.State.HOVER:
		_on_gcard_hovered(card, true)
		
