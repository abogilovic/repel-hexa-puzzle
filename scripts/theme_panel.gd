extends Control

export(Color) var pnl_clr
export(Array, NodePath) var buttons
export(Array) var color_paletts

onready var anim_player=get_node("animation_player")

func _ready():
	var c = 0
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color
		#Postaviti boje za indikator
		var colors = button.get_node("colors").get_children()
		for i in len(colors):
			colors[i].color=color_paletts[c][i]
		c+=1

func open_panel():
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")

func _on_color_palette_pressed(palette_index):
	shared_audio.play_sound_fx("button_click")
	sng.main_screen.get_node("play_panel").open_panel()
	sng.color_palette_in_use=color_paletts[palette_index]