extends KinematicBody2D
class_name HexaFigure

enum PlaceType {NTNG, EMPTY, HEXA, BADHEXA, MAINHEXA}
export(PackedScene) var point
export(PlaceType) var type
export(int) var moving_speed
export(int) var merge_multiplier_speed

onready var anim_player=get_node("animation_player")
onready var audio_player=get_node("audio_stream_player_2d")

var brow; var bcol
var on_hexa_field;
var increasing_level=true setget set_increasing_level
var level=1 setget set_level
var color setget set_color
var places_around=[] #{"PlaceType": PlaceType.NTNG, "HexRef": null}
var placed=false

var move_stage=-1
var move_to
var move_to_cursor=false

var marked_for_merge=false

var marked_flood=false
var repel=false
var displayed_points=false

func _ready():
	define_animations_sizing()

var ds=null
func _physics_process(delta):
	if move_to_cursor and !placed:
		if position.distance_to(move_to)>0.2:
			move_and_slide((move_to-position)*delta*moving_speed)
		else: move_to_cursor=false

	if sng.gc.merging:
		if move_stage==sng.gc.current_moving_stage and marked_for_merge:
			if !displayed_points: display_points('m')
			if !ds || position.distance_to(move_to)<=ds:
				ds=position.distance_to(move_to)
				move_and_slide((move_to-position).normalized()*delta*merge_multiplier_speed*moving_speed)
			else:
				sng.gc.noh_merge_stages[move_stage]-=1
				if sng.gc.noh_merge_stages[move_stage]==0: sng.gc.current_moving_stage-=1
				if sng.gc.current_moving_stage<0:
					sng.gc.level_up_placed_hexa()
				queue_free()
	if repel:
		if !displayed_points: display_points('r')
		if position.distance_to(move_to)>0.2:
			move_and_slide((move_to-position)*delta*moving_speed/4)
		else:
			print("freed")
			queue_free()
	
func define_animations_sizing():
	var anim_lvl_up; var anim_pop; var anim_repel; var anim_place; var hx_scale=sng.gc.hexa_scale
	if type==PlaceType.MAINHEXA:
		anim_lvl_up=anim_player.get_animation("level_up_main")
		hx_scale*=1.1
	else:
		if type!=PlaceType.BADHEXA:
			anim_lvl_up=anim_player.get_animation("level_up")
			anim_repel=anim_player.get_animation("repel")
			anim_place=anim_player.get_animation("place")
			for i in range(anim_repel.track_get_key_count(0)):
				anim_repel.track_set_key_value(0,i,anim_repel.track_get_key_value(0,i)*hx_scale)
		else:
			anim_place=anim_player.get_animation("bad_place")
		#pop
		anim_pop=anim_player.get_animation("pop")
		for i in range(anim_pop.track_get_key_count(0)):
			anim_pop.track_set_key_value(0,i,anim_pop.track_get_key_value(0,i)*hx_scale)
		#place
		for i in range(anim_place.track_get_key_count(0)):
			anim_place.track_set_key_value(0,i,anim_place.track_get_key_value(0,i)*hx_scale)
	#level_up
	if type!=PlaceType.BADHEXA:
		for i in range(anim_lvl_up.track_get_key_count(0)):
			anim_lvl_up.track_set_key_value(0,i,anim_lvl_up.track_get_key_value(0,i)*hx_scale)

func set_color(c):
	color=c
	get_node("sprite").modulate=color

func set_level(l):
	level=l
	if l<=sng.gc.hexa_figure_colors.size() and (type==PlaceType.HEXA or type==PlaceType.MAINHEXA):
		get_node("label").text=String(level)

func smooth_move_to(to, k):
	if k==0 and !move_to_cursor: move_to_cursor=true
	move_to=to

func place_hexa(row, col, load_place=false):
	print("-----------")
	if sng.gc.field[row][col]["PlaceType"]!=PlaceType.EMPTY:
		failed_to_place_hexa()
		return
	var can_be_placed=false
	
	if col%2==0: places_around=[[row-1, col+1], [row-1, col], [row-1, col-1], [row, col-1], [row+1, col], [row, col+1]]
	else: places_around=[[row, col+1], [row-1, col], [row, col-1], [row+1, col-1], [row+1, col], [row+1, col+1]]
	
	if !load_place:
		for i in range(6):
			var pl=places_around[i]
			if not(pl[0]<0 || pl[0]>=sng.gc.dimensions[0] || pl[1]<0 || pl[1]>=sng.gc.dimensions[1]) and sng.gc.field[pl[0]][pl[1]]["PlaceType"]!=PlaceType.EMPTY:
				can_be_placed=true
				break
	
	if can_be_placed and type!=PlaceType.MAINHEXA and !load_place:
		match type:
			PlaceType.HEXA: 
				if anim_player.is_playing(): anim_player.queue("place")
				else: anim_player.play("place")
			PlaceType.BADHEXA: 
				if anim_player.is_playing(): anim_player.queue("bad_place")
				else: anim_player.play("bad_place")
	if can_be_placed || type==PlaceType.MAINHEXA || load_place:
		print("place new hexa")
		placed=true; set_physics_process(false)
		brow=row; bcol=col
		on_hexa_field=sng.gc.field[row][col]["HexRef"]
		position=sng.gc.field[row][col]["HexRef"].position
		highlight_fields_around(1)
		
		sng.gc.field[row][col]={"PlaceType": type, "HexRef": self}
		if type!=PlaceType.MAINHEXA:
			z_index=1
			scale=sng.gc.hexa_scale*Vector2.ONE
		
		if type==PlaceType.HEXA:
			var m=sng.gc.main_hex_ref.merge_hexas_around()
			print("Main can merge: ", m)
			if !m:
				print("Basic merge")
				merge_hexas_around()
			else: print("Main merge")
		elif type==PlaceType.MAINHEXA and level==1:
			get_node("ind_abtomrg").visible=true
			get_node("shade_transp").visible=false
		if !load_place:
			sng.gc.spawn_new_hexa()
		sng.gc.places_count-=1
	else:
		failed_to_place_hexa()

func merge_hexas_around():
	var current_stage=0
	var hexas_current=[self]
	var hexas_next=[]
	var all_for_merge=[self]
	
	marked_for_merge=true
	sng.gc.noh_merge_stages.clear()
	while true:
		for c in hexas_current:
			for p in c.places_around:
				if p[0]>=0 and p[0]<sng.gc.dimensions[0] and p[1]>=0 and p[1]<sng.gc.dimensions[1]:
					var hex=sng.gc.field[p[0]][p[1]]
					var hex_ref=hex["HexRef"]
					if hex["PlaceType"]==PlaceType.HEXA and hex_ref.level==level and !hex_ref.marked_for_merge:
						hex_ref.marked_for_merge=true
						hex_ref.move_to=c.position
						hex_ref.move_stage=current_stage
						hexas_next.append(hex_ref); all_for_merge.append(hex_ref);
		if hexas_next.size()==0: break
		else:
			sng.gc.noh_merge_stages.append(hexas_next.size())
			hexas_current=hexas_next.duplicate()
			hexas_next.clear()
			current_stage+=1
	if all_for_merge.size()>=level+1:
		if type==PlaceType.MAINHEXA:
			get_node("ind_abtomrg").visible=false
			get_node("shade_transp").visible=true
		for a in all_for_merge:
			if a!=self:
				a.highlight_fields_around(-1)
				sng.gc.field[a.brow][a.bcol]={"PlaceType": PlaceType.EMPTY, "HexRef": a.on_hexa_field}
				a.z_index=0; a.get_node("label").visible=false
				a.get_node("ind_abtomrg").visible=false; a.get_node("shade_transp").visible=true
				a.set_physics_process(true)
		marked_for_merge=false
		sng.gc.start_the_merge(self, all_for_merge.size()-1)
		sng.gc.current_moving_stage=sng.gc.noh_merge_stages.size()-1
		return true
	elif all_for_merge.size()==level:
		for a in all_for_merge:
			a.marked_for_merge=false
			if!a.get_node("ind_abtomrg").visible:
				a.get_node("ind_abtomrg").visible=true
				a.get_node("shade_transp").visible=false
				if a.type==PlaceType.HEXA:
					if a.anim_player.is_playing(): a.anim_player.queue("about_merge")
					else: a.anim_player.play("about_merge")
				elif a.type==PlaceType.MAINHEXA:
					if a.anim_player.is_playing(): a.anim_player.queue("main_about_merge")
					else: a.anim_player.play("main_about_merge")
		return false
	else:
		for a in all_for_merge: a.marked_for_merge=false
		return false

func failed_to_place_hexa():
	move_to_cursor=false
	scale=Vector2(0.45, 0.45)
	position=sng.bg_game.glow_first.rect_position

func forward_flood_signal(b):
	marked_flood=b
	for p in places_around:
		if p[0]>=0 and p[0]<sng.gc.dimensions[0] and p[1]>=0 and p[1]<sng.gc.dimensions[1]:
			var hex=sng.gc.field[p[0]][p[1]]
			var hex_ref=hex["HexRef"]
			if (hex["PlaceType"]==PlaceType.HEXA or hex["PlaceType"]==PlaceType.BADHEXA) and ((!hex_ref.marked_flood and b) or (hex_ref.marked_flood and !b)):
				hex_ref.forward_flood_signal(b)

func repel():
	repel=true
	highlight_fields_around(-1)
	z_index=4;
	
	if type==PlaceType.HEXA:
		if anim_player.is_playing(): anim_player.queue("repel")
		else: anim_player.play("repel")
	var m=sng.gc.main_hex_ref.position
	var a=position-m
	var v=Vector2(position.x-(m.x-position.x), position.y-(m.y-position.y))
	var k=800-a.length(); if k<0: k=0
	smooth_move_to(v+k*a.normalized(), 1)
	set_physics_process(true)

func turn_off_ind_abtomrg():
	get_node("ind_abtomrg").visible=false
	get_node("shade_transp").visible=true
	for p in places_around:
		if p[0]>=0 and p[0]<sng.gc.dimensions[0] and p[1]>=0 and p[1]<sng.gc.dimensions[1]:
			var hex=sng.gc.field[p[0]][p[1]]
			var hex_ref=hex["HexRef"]
			if hex["PlaceType"]==PlaceType.HEXA and hex_ref.get_node("ind_abtomrg").visible:
				hex_ref.turn_off_ind_abtomrg()

var timer=null
func pop_around():
	shared_audio.play_sound_fx("pop_around", 0.45)
	var plus_places=0
	if type!=PlaceType.MAINHEXA:
		pop(); plus_places+=1
		
	for p in places_around:
		if p[0]>=0 and p[0]<sng.gc.dimensions[0] and p[1]>=0 and p[1]<sng.gc.dimensions[1]:
			var hex=sng.gc.field[p[0]][p[1]]
			var hex_ref=hex["HexRef"]
			if hex["PlaceType"]==PlaceType.HEXA or hex["PlaceType"]==PlaceType.BADHEXA: 
				hex_ref.pop(); plus_places+=1
				if hex_ref.type==PlaceType.HEXA and hex_ref.get_node("ind_abtomrg").visible: hex_ref.turn_off_ind_abtomrg()
	
	sng.gc.places_count+=plus_places
	sng.gc.merging=true #zbog zabrane inputa dok ne zavrsi ovo
	
	if type==PlaceType.MAINHEXA and !timer or type!=PlaceType.MAINHEXA:
		timer=Timer.new()
		timer.set_wait_time(0.5); timer.one_shot=true
		timer.connect("timeout", sng.gc, "repel_unflooded")
		add_child(timer)
		timer.start()
	else: timer.start()

func pop():
	highlight_fields_around(-1)
	sng.gc.field[brow][bcol]={"PlaceType": PlaceType.EMPTY, "HexRef": on_hexa_field}
	if type!=PlaceType.MAINHEXA:
		if anim_player.is_playing(): anim_player.queue("pop")
		else: anim_player.play("pop")
	else:
		if anim_player.is_playing(): anim_player.queue("level_up_main")
		else: anim_player.play("level_up_main")

func highlight_fields_around(x):
	on_hexa_field.highlight_field(x)
	for i in range(6):
		var pl=places_around[i]
		if not(pl[0]<0 || pl[0]>=sng.gc.dimensions[0] || pl[1]<0 || pl[1]>=sng.gc.dimensions[1]):
			if sng.gc.field[pl[0]][pl[1]]["PlaceType"]==PlaceType.EMPTY:
				sng.gc.field[pl[0]][pl[1]]["HexRef"].highlight_field(x)
			else:
				sng.gc.field[pl[0]][pl[1]]["HexRef"].on_hexa_field.highlight_field(x)

func display_points(t):
	var m; var p; var clr
	if type==PlaceType.HEXA:
		if t=='m':
			p=level; m=sng.gc.main_hex_ref.level; clr=color
		elif t=='r':
			p=1; m=sng.gc.main_hex_ref.level; clr=Color(255,255,255,0)
	elif type==PlaceType.BADHEXA and t=='r':
		p=level; m=sng.gc.main_hex_ref.level; clr=Color("e83855")
	
	var pnt=point.instance()
	pnt.display(p, m, position, clr)
	sng.gc.add_child(pnt)
	displayed_points=true

func set_increasing_level(l):
	increasing_level=l
	if type==PlaceType.MAINHEXA:
		get_node("increasing_level").visible=l
		get_node("decreasing_level").visible=not l