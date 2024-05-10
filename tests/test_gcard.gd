extends GutTest

var gcard:GCard

func before_each():
	gcard = autofree(partial_double(GCard).new())

func test_state_idle():
	gcard.state = GCard.State.IDLE
	assert_eq(gcard.scale, Vector2.ONE)

func test_state_hover():
	gcard.rotation = 5.0
	gcard.hovered_scale = Vector2(2, 2)
	gcard.state = GCard.State.HOVER
	assert_eq(gcard.scale, gcard.hovered_scale)
	assert_almost_eq(gcard.rotation, 0.0, 0.01)

func test_state_drag():
	gcard.rotation = 5.0
	gcard.hovered_scale = Vector2(2, 2)
	gcard.state = GCard.State.HOVER
	assert_eq(gcard.scale, gcard.hovered_scale)
	assert_almost_eq(gcard.rotation, 0.0, 0.01)
