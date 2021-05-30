extends Button
class_name MyButton

export(String) var button_name
export(bool) var fixed_highlight
export(bool) var highlight
export(Color) var unhiglighted_color
var button_color setget set_button_color

func _ready():
	get_node("label").text=button_name

func set_button_color(c):
	button_color=c
	get_node("texture_rect").modulate=c

func _on_button_pressed():
	shared_audio.play_sound_fx("button_click")
