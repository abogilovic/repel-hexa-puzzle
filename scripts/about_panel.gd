extends Control

onready var anim_player=get_node("animation_player")

func open_panel():
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")

func _on_byteblast_button_pressed():
	OS.shell_open("https://play.google.com/store/apps/dev?id=6586000841688917619")
