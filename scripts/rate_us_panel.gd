extends CanvasLayer

export(Color) var pnl_clr
export(Array, NodePath) var buttons

func _ready():
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color

func open_panel():
	get_node("animation_player").play("open_rate_us")
	if sng.gc and is_instance_valid(sng.gc):
		sng.gc.paused=true

func _on_yes_pressed():
	save_system.show_rate=false
	sng.ui_game.pause_panel.open_panel()
	OS.shell_open("https://play.google.com/store/apps/details?id=com.byteblaststudio.repel")
	queue_free()

func _on_no_pressed():
	if sng.gc and is_instance_valid(sng.gc):
		sng.gc.paused=false
	queue_free()