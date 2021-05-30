extends Control

var value=false setget set_value #BOOL

export(Color) var on_color
export(Color) var off_colors

onready var bg=get_node("bg")
onready var anim_player=get_node("animation_player")
var feedback_obj; var feedback_fun

func set_slider(on_clr, obj, fun_str):
	on_color=on_clr;  feedback_obj=obj; feedback_fun=fun_str

func switch_value():
	self.value=!value

func set_value(v):
	value=v
	if v: 
		anim_player.play("on_slider")
		bg.modulate=on_color
	else:
		anim_player.play_backwards("on_slider")
		bg.modulate=off_colors
	print(feedback_fun)
	feedback_obj.call(feedback_fun, value)
