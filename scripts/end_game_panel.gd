extends Control

export(Color) var pnl_clr
export(Array, NodePath) var buttons
onready var anim_player=get_node("animation_player")
onready var end_score=get_node("core/end_score")
onready var high_score=get_node("core/high_score")
onready var new_high_score=get_node("core/new_high_score")

func _ready():
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color

func open_panel():
	ads.show_short_video()
	if save_system.show_rate:
		var rate=sng.rate_us.instance()
		rate.open_panel(); add_child(rate)
	set_scores(sng.ui_game.score, sng.ui_game.high_score)
	shared_audio.play_sound_fx("end_game")
	save_system.save_all()
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")

func set_scores(score, h_score):
	end_score.text=String(score)
	high_score.text=String(h_score)
	new_high_score.visible=score==h_score

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_home_pressed():
	get_tree().change_scene("res://scenes/main_screen.tscn")
