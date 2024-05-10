@tool
class_name GCardHandLayoutService
extends RefCounted

var number_of_cards:int: set = _set_number_of_cards
var dynamic_radius := true: set = _set_dynamic_radius
var dynamic_radius_factor:float = 100.0: set = _set_dynamic_radius_factor
var radius := 1000: set = _set_radius
var circle_percentage:float = 0.05: set = _set_circle_percentage
var card_size:Vector2
var hovered_index := -1
var hover_padding := 15.0

var _need_recalculate_curve:bool = true
var _base_layout_infos:Array[GCardLayoutInfo] = []

func get_card_layouts() -> Array[GCardLayoutInfo]:
	if _need_recalculate_curve:
		recalculate_layouts()
	return sample_curve()

func recalculate_layouts():
	_base_layout_infos.clear()
	if dynamic_radius:
		radius = number_of_cards*dynamic_radius_factor
	var total_degree := TAU * circle_percentage
	var initial_angle := - PI/2
	var step := 0.0
	if number_of_cards > 1:
		initial_angle -= total_degree/2.0
		step = total_degree/float(number_of_cards-1)
	var origin := Vector2.DOWN*radius #Add Vector2.DOWN * radius to set the curve to center around (0,0)
	for i in number_of_cards:
		# Calculate the angle for this point on the circle
		var angle := initial_angle
		if number_of_cards > 1:
			angle += step * i
		# Calculate the x and y coordinates of the point on the circle
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		# Add the point to the curve
		var layout_info := GCardLayoutInfo.new()
		layout_info.position = Vector2(x, y) + origin
		layout_info.rotation = angle + PI/2
		_base_layout_infos.append(layout_info)
	_need_recalculate_curve = false

func sample_curve() -> Array[GCardLayoutInfo]:
	var result:Array[GCardLayoutInfo] = []
	var number_of_intervals := max(number_of_cards-1, 1)
	for i in number_of_cards:
		var layout_info := GCardLayoutInfo.new()
		layout_info.copy(_base_layout_infos[i])
		layout_info.position.x -= card_size.x/2
		if i == hovered_index:
			# TODO: make hover position customized
			layout_info.position.y -= card_size.y * 0.2 
			layout_info.rotation = 0
		elif hovered_index != -1:
			var i_diff := i - hovered_index
			if i_diff < 0:
				# Cards left to the hovered card.
				layout_info.position.x -= hover_padding
			else:
				layout_info.position.x += hover_padding
				# Cards right to the hovered card.
		result.append(layout_info)
	return result

func _set_dynamic_radius(val:bool):
	dynamic_radius = val
	_need_recalculate_curve = true

func _set_dynamic_radius_factor(val:float):
	dynamic_radius_factor = val
	_need_recalculate_curve = true
	
func _set_radius(val:float):
	radius = val
	_need_recalculate_curve = true

func _set_number_of_cards(val:int):
	number_of_cards = val
	_need_recalculate_curve = true

func _set_circle_percentage(val:float):
	circle_percentage = val
	_need_recalculate_curve = true
