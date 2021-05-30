extends Control

export(Color) var pnl_clr
export(Array, NodePath) var buttons
onready var anim_player=get_node("animation_player")

var can_continue=false

func _ready():
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color
		else:
			if save_system.saved_field!=null: 
				button.button_color=pnl_clr
				can_continue=true
			else: 
				button.button_color=button.unhiglighted_color
				can_continue=false

func open_panel():
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")

func _on_continue_pressed():
	if can_continue:
		save_system.n_for_show+=1
		get_tree().change_scene("res://scenes/main_node.tscn")

func _on_new_game_pressed():
	save_system.saved_field=null
	save_system.n_for_show+=1
	get_tree().change_scene("res://scenes/main_node.tscn")
