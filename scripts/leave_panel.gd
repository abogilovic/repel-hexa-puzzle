extends Control

export(Color) var pnl_clr
export(Array, NodePath) var buttons
onready var anim_player=get_node("animation_player")

func _ready():
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color

func open_panel():
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")
	if sng.gc and is_instance_valid(sng.gc) and !sng.ui_game.in_pause_panel:
		sng.gc.paused=false

func _on_yes_pressed():
	save_system.save_all()
	get_tree().quit()

func _on_no_pressed():
	close_panel()
