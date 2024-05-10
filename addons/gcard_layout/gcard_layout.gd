@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _add_layout_nodes():
	add_custom_type("GCardHandLayout", "Control", preload("res://addons/gcard_layout/layouts/hand_layout/gcard_hand_layout.gd"), preload("res://addons/gcard_layout/resources/icons/hand_layout_icon.svg"))
	add_custom_type("GCard", "Control", preload("res://addons/gcard_layout/card/gcard.gd"), preload("res://addons/gcard_layout/resources/icons/card_icon.svg"))
