extends Node2D
class_name HexaField

var row; var col;

export(Color) var highlighted_color
export(Color) var pointer_on_color
onready var normal_color=get_node("sprite").modulate
onready var sprite=get_node("sprite")
onready var highlight_dot=get_node("sprite2")
var n_hexas_around=0
var highlighted=false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and !sng.gc.merging:
		if !event.is_pressed():
			sng.gc.new_hexa.place_hexa(row, col)

func _on_area_2d_mouse_entered():
	sprite.modulate=pointer_on_color

func _on_area_2d_mouse_exited():
	if highlighted:
		sprite.modulate=highlighted_color
	else:
		sprite.modulate=normal_color

func highlight_field(x):
	n_hexas_around+=x
	if n_hexas_around<=0 and highlighted:
		sprite.modulate=normal_color; highlighted=false
		highlight_dot.visible=false
	elif n_hexas_around>0 and !highlighted:
		sprite.modulate=highlighted_color; highlighted=true
		highlight_dot.visible=true
