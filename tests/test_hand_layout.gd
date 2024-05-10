extends GutTest

var hand_layout:GCardHandLayout
var _sender = InputSender.new(Input)

func before_each():
	hand_layout = autofree(partial_double(GCardHandLayout).new())

func after_each():
	_sender.release_all()
	_sender.clear()

func test_reset_positions_on_child_order_change():
	add_child(hand_layout)
	for i in 5:
		var card:GCard = autofree(GCard.new())
		hand_layout.add_child(card)
	assert_call_count(hand_layout, "_reset_positions", 5)
	
	hand_layout.remove_child(hand_layout.get_children().front())
	assert_call_count(hand_layout, "_reset_positions", 6)

func test_reset_position_on_ready():
	for i in 5:
		var card:GCard = autofree(GCard.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_reset_position_on_card_hover():
	for i in 5:
		var card:GCard = autofree(partial_double(GCard).new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:GCard = hand_layout.get_children().front()
	gcard.mouse_entered.emit()
	assert_eq(gcard.state, GCard.State.HOVER)
	assert_call_count(gcard, "_on_mouse_entered", 1)
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_reset_position_on_card_unhover():
	for i in 5:
		var card:GCard = autofree(partial_double(GCard).new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:GCard = hand_layout.get_children().front()
	gcard.mouse_entered.emit()
	assert_eq(gcard.state, GCard.State.HOVER)
	gcard.mouse_exited.emit()
	assert_eq(gcard.state, GCard.State.IDLE)
	assert_call_count(gcard, "_on_mouse_entered", 1)
	assert_call_count(hand_layout, "_reset_positions", 3)

func test_reset_position_on_card_drag():
	for i in 5:
		var card:GCard = autofree(partial_double(GCard).new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:GCard = hand_layout.get_children().front()
	gcard.state = GCard.State.DRAGGING
	assert_eq(gcard.state, GCard.State.DRAGGING)
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_reset_position_on_card_release_drag():
	for i in 5:
		var card:GCard = autofree(partial_double(GCard).new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:GCard = hand_layout.get_children().front()
	gcard.state = GCard.State.DRAGGING
	assert_eq(gcard.state, GCard.State.DRAGGING)
	assert_call_count(hand_layout, "_reset_positions", 2)
	gcard.state = GCard.State.IDLE
	assert_eq(gcard.state, GCard.State.IDLE)
	assert_call_count(hand_layout, "_reset_positions", 3)

func test_change_parameters_reset_position():
	for i in 5:
		var card:GCard = autofree(partial_double(GCard).new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	
	hand_layout.dynamic_radius = hand_layout.dynamic_radius
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.dynamic_radius = !hand_layout.dynamic_radius
	assert_call_count(hand_layout, "_reset_positions", 2)
	
	hand_layout.dynamic_radius_factor = 10000
	assert_call_count(hand_layout, "_reset_positions", 3)
	
	hand_layout.radius = 100000
	assert_call_count(hand_layout, "_reset_positions", 4)
	
	hand_layout.circle_percentage = 1.0
	assert_call_count(hand_layout, "_reset_positions", 5)
	
	hand_layout.card_size = Vector2(100, 100)
	assert_call_count(hand_layout, "_reset_positions", 6)

	hand_layout.handle_mouse_hover_animaiton = false # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 6)
	
	hand_layout.hovered_index = 4
	assert_call_count(hand_layout, "_reset_positions", 6)
	
	hand_layout.hover_padding = 60
	assert_call_count(hand_layout, "_reset_positions", 7)
	
	hand_layout.animation_time = 0.2  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 7)
	
	hand_layout.animation_ease = Tween.EASE_OUT  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 7)
	
	hand_layout.animation_trans = Tween.TRANS_SINE  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 7)
	
	hand_layout.hover_sound = autofree(AudioStreamPlayer2D.new()) # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 7)
