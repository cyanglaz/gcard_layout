@tool
@icon("res://addons/gcard_layout/resources/icons/hand_layout_icon.svg")
## A node to help layout [GCard] in a hand layout.[br][br]
## Simply add [GCard]s as children to form the layout. Adding other nodes as children cause undefined behavior.
## To make the layout more customized, create a custom control scene and use [GCardHandLayoutService] as a helper.
class_name GCardHandLayout
extends Control

## Emits when a card is hovered.
signal card_hoverd(card:GCard, index:int)
## Emits when a card is unhovered.
signal card_unhovered(card:GCard, index:int)
## Emits when a card starts being dragged.
signal card_dragging_started(card:GCard, index:int)
## Emits when a dragged card is released.
signal card_dragging_finished(card:GCard, index:int)

@export_group("idle layout")
## Set radius dynamically based on the number of cards. ([member radius] = [member dynamic_radius_factor] * number_of_cards).[br][br]
## If [b]true[/b], [member radius] is ignored.
@export var dynamic_radius := true: set = _set_dynamic_radius
## If [member dynamic_radius] is [br]true[/br], this value is used to compute the radius to create the curve based on the number of cards.[br]
## A bigger value creates a flatter curve and more seperation between the cards.[br][br]
## If [member dynamic_radius] is [br]false[/br], this is ignored.
@export var dynamic_radius_factor:float = 100.0: set = _set_dynamic_radius_factor
## A fixed radius used to create the curve.[br][br]
## If [member dynamic_radius] is [b]true[/b], this is ignored.
@export var radius := 1000.0: set = _set_radius
## Determines how much of a circle to use for the curve.[br][br]
## A value of [b]0.0[/b] creates a point, and a value of [b]1.0[/b] creates a full circle.
## Usually a value between [b]0.1[/b] and [b]0.03[/b] is suitable for a card hand layout.
@export var circle_percentage:float = 0.05: set = _set_circle_percentage
## The size of the card.[br][br]
## This has to match the size of the child.
@export var card_size:Vector2: set = _set_card_size

@export_group("hover")
## Whether this layout node should handle hover animation.[br][br]
@export var handle_mouse_hover_animaiton := true
## The card index that is currently being hovered.[br][br]
## This is useful when testing layout in the inspector.[br][br]
@export var hovered_index := -1: set = _set_hovered_index
## How much pixels do un-hovered card move away from the hovered card.[br][br]
## The cards to the left of the hovered card move to the left, the cards to the right move to the right.[br][br]
@export var hover_padding := 40.0: set = _set_hover_padding

@export_group("animation") 
## The duration of all the animation related to layout, e.g. hover, reset position. [br][br]
## When value is set to [br]0.0[/br], animations are disabled.
@export var animation_time := 0.1: set = _set_animation_time
## The ease used for the animations.
@export var animation_ease := Tween.EASE_IN
## The trans used for the animations.
@export var animation_trans := Tween.TRANS_QUAD

@export_group("sounds")
## Plays when a card is hovered.
@export var hover_sound:AudioStreamPlayer2D

var gcard_hand_layout_service := GCardHandLayoutService.new()
var _dragging_index:int = -1
var _reset_position_tween:Tween

func _ready():
	_dragging_index = -1
	child_order_changed.connect(_on_child_order_changed)
	for card in get_children():
		(card as GCard).state_updated.connect(_on_gcard_state_updated)
	if get_child_count() > 0:
		_reset_positions_if_in_tree(false, false)
	
func _enter_tree():
	if is_node_ready() && get_child_count() > 0:
		_reset_positions_if_in_tree(false, false)
	
func _validate_property(property):
	if property.name in ["radius"] && dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["dynamic_radius_factor"] && !dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["animation_ease", "animation_trans"] && animation_time <= 0.0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
func _reset_positions_if_in_tree(reculculate_curve:bool = false, animated:bool = true):
	if is_inside_tree():
		_reset_positions(reculculate_curve, animated)

func _reset_positions(reculculate_curve:bool = false, animated:bool = true):
	var number_of_cards := get_child_count()
	if _dragging_index >= 0:
		number_of_cards -= 1
	gcard_hand_layout_service.number_of_cards = number_of_cards
	gcard_hand_layout_service.dynamic_radius = dynamic_radius
	gcard_hand_layout_service.dynamic_radius_factor = dynamic_radius_factor
	gcard_hand_layout_service.radius = radius
	gcard_hand_layout_service.circle_percentage = circle_percentage
	gcard_hand_layout_service.card_size = card_size
	gcard_hand_layout_service.hover_padding = hover_padding
	gcard_hand_layout_service.hovered_index = hovered_index
	var should_animate := animation_time > 0.0 && animated && number_of_cards > 0 && is_inside_tree()
	var layout_infos := gcard_hand_layout_service.get_card_layouts()
	var position_index := 0
	if _reset_position_tween && _reset_position_tween.is_running():
		_reset_position_tween.stop()
	if should_animate:
		_reset_position_tween = create_tween()
	for i in get_child_count():
		if i == _dragging_index:
			continue
		var card:Control = get_children()[i]
		card.animation_time = animation_time
		card.animation_ease = animation_ease
		card.animation_trans = animation_trans
		var layout_info:GCardLayoutInfo = layout_infos[position_index]
		card.idle_rotation = layout_info.rotation
		if !should_animate:
			card.position = layout_info.position
		else:
			_reset_position_tween.parallel().tween_property(card, "position", layout_info.position, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		position_index += 1
	if should_animate:
		_reset_position_tween.play()
			
func _set_dynamic_radius(val:bool):
	if dynamic_radius == val:
		return
	dynamic_radius = val
	notify_property_list_changed()
	_reset_positions_if_in_tree()

func _set_dynamic_radius_factor(val:float):
	dynamic_radius_factor = val
	_reset_positions_if_in_tree()

func _set_radius(val:float):
	radius = val
	_reset_positions_if_in_tree()
	
func _set_circle_percentage(val:float):
	circle_percentage = val
	_reset_positions_if_in_tree()
	
func _set_card_size(val:Vector2):
	card_size = val
	_reset_positions_if_in_tree()

func _set_hovered_index(val:int):
	hovered_index = val
	if Engine.is_editor_hint():
		if hovered_index == -1:
			_reset_positions_if_in_tree()
		else:
			_reset_positions_if_in_tree()

func _set_hover_padding(val:float):
	hover_padding = val
	_reset_positions_if_in_tree()

func _set_animation_time(val:float):
	animation_time = val
	notify_property_list_changed()

func _on_child_order_changed():
	for child in get_children():
		var gcard := (child as GCard)
		if !gcard.state_updated.is_connected(_on_gcard_state_updated):
			gcard.state_updated.connect(_on_gcard_state_updated)
	_reset_positions_if_in_tree()
	
func _on_hover_started(card:GCard):
	if hover_sound:
		hover_sound.play()
	var index := get_children().find(card)
	hovered_index = index
	_reset_positions_if_in_tree()
	card_hoverd.emit(card, index)

func _on_hover_ended(card:GCard):
	var index := get_children().find(card)
	if hovered_index == index:
		hovered_index = -1
		_reset_positions_if_in_tree()
		card_unhovered.emit(card, index)

func _on_gcard_dragging_started(card:GCard):
	for child_card in get_children():
		child_card.enable_mouse_enter = card == child_card
	var index := get_children().find(card)
	hovered_index = -1
	_dragging_index = index
	_reset_positions_if_in_tree()
	card_dragging_started.emit(card, _dragging_index)
	
func _on_gcard_dragging_finished(card:GCard):
	for child_card in get_children():
		child_card.enable_mouse_enter = true
	var dragging_index = _dragging_index
	_dragging_index = -1
	_reset_positions_if_in_tree()
	card_dragging_started.emit(card, dragging_index)

func _on_gcard_state_updated(card:GCard, old_state:GCard.State, new_state:GCard.State):
	if old_state == new_state:
		return
	if old_state == GCard.State.DRAGGING:
		_on_gcard_dragging_finished(card)
	elif new_state == GCard.State.DRAGGING:
		_on_gcard_dragging_started(card)
	if old_state == GCard.State.HOVER && new_state == GCard.State.IDLE:
		_on_hover_ended(card)
	elif new_state == GCard.State.HOVER && old_state == GCard.State.IDLE:
		_on_hover_started(card)
