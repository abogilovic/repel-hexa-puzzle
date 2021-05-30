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
	sng.gc.paused=true
	sng.ui_game.in_pause_panel=true
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")
	sng.gc.paused=false
	sng.ui_game.in_pause_panel=false

func _on_resume_pressed():
	close_panel()

func _on_home_pressed():
	sng.gc.save_progress()
	get_tree().change_scene("res://scenes/main_screen.tscn")

func _on_settings_pressed():
	sng.ui_game.settings_panel.open_panel()

func _on_leave_pressed():
	sng.gc.save_progress()
	sng.ui_game.leave_panel.open_panel()
