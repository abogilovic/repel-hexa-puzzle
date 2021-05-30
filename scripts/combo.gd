extends Control

onready var anim_player=get_node("animation_player")
onready var n_combo=get_node("core/n_combo")
onready var bonus=get_node("core/bonus")

func show_combo(n):
	n_combo.text=String(n)
	var x=300*(2*n-1)
	sng.ui_game.add_to_score(x)
	bonus.text="%s pts"%String(x)
	anim_player.play("show_combo")

func hide_combo():
	anim_player.play("hide_combo")
