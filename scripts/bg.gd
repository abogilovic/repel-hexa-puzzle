extends CanvasLayer
class_name BG

onready var bgc=get_node("bg_color")
var glow_first setget ,get_glow_first; var glow_second setget ,get_glow_second;

func set_hexarepel_y(y_pos):
	var hexa_repel=get_node("bg_hexarepel")
	hexa_repel.rect_position=Vector2(hexa_repel.rect_position.x, y_pos-hexa_repel.rect_size.y/2.0)
	
func get_glow_first():
	if glow_first==null: glow_first=get_node("glow_first")
	return glow_first

func get_glow_second():
	if glow_second==null: glow_second=get_node("glow_second")
	return glow_second
