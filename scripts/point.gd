extends Node2D

func display(points, multiplier, pos, clr):
	position=pos
	var pnt_label=get_node("point_struct/point")
	var color_rect=get_node("point_struct/color_rect")
	if points<10: pnt_label.text=String(points)
	else: pnt_label.text="T"
	if multiplier<10: get_node("point_struct/multiplier").text=String(multiplier)
	else: get_node("point_struct/multiplier").text="T"
	pnt_label.modulate=pnt_label.modulate.linear_interpolate(clr, 0.5)
	color_rect.color=get_node("point_struct/color_rect").color.linear_interpolate(clr, 0.5)
	
	var anims=["point1", "point2"]
	get_node("animation_player").play(anims[randi()%anims.size()])
