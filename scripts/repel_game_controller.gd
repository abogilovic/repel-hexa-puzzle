extends Node
class_name RepelGameController

var paused=false setget set_paused

export(Array, int) var dimensions #row,col
export(Array, float) var row_play_space
export(Array, float) var col_play_space
export(int) var hexa_original_width
export(PackedScene) var hexa_field
export(PackedScene) var hexa_figure
export(PackedScene) var hexa_figure_main
export(PackedScene) var hexa_figure_bad
var hexa_figure_colors
onready var mouse_pointer=get_node("mouse_pointer")

var places_count setget set_places_count
var repel_ad_trigger;
var field=[] #{"PlaceType": PlaceType.NTNG, "HexRef": null}
var hexa_width; var hexa_scale; var start_pos

var pressed_screen=false
var new_hexa; var next_hexa

var placed_hex_ref; var main_hex_ref

var noh_merge_stages=[] #number of hexas merge stages
var current_moving_stage setget set_current_moving_stage
var merging=false

func _ready():
	hexa_figure_colors=sng.color_palette_in_use
	places_count=dimensions[0]*dimensions[1]
	repel_ad_trigger = places_count/63.0*13 #15 ih treba repelat ako je 9*7 dimenzija
	_prepare_sizings()
	_make_hexa_field()
	if save_system.saved_field: load_progress()

var lvl_hexas_alive=[0,0,0,0,0,0,0,0,0,0]
var tezista=[1.0,0.96,0.92,0.88,0.84,0.8,0.76,0.72,0.68,0.64]
func get_next_corresponding_hexa():
	var raspodjela=[]
	for i in range(tezista.size()):
		if i>0: raspodjela.append(raspodjela[i-1]+tezista[i]*(1+lvl_hexas_alive[i]))
		else: raspodjela.append(tezista[i]*(1+lvl_hexas_alive[i]))
	randomize(); var t=rand_range(0.0,raspodjela.back())
	
	var prob=[]
	for i in range(raspodjela.size()):
		if i>0: prob.append(100.0*(raspodjela[i]-raspodjela[i-1])/raspodjela.back())
		else: prob.append(100.0*raspodjela[i]/raspodjela.back())
	print("PROBABILITY")
	print(prob)
	var lg=0; for i in range(prob.size()): lg+=prob[i]; print(lg)
	print(lvl_hexas_alive)
	print(t)
	print(raspodjela)
	
	for i in range(raspodjela.size()):
		if t<=raspodjela[i]: return i
	return 0 #IF BUG HAPPENS

var k_hex=0
func spawn_new_hexa():
	var x; var bad
	#koef [0,1]
	var koef=(k_hex/(1.85*places_count))*main_hex_ref.level/10.0
	print(koef)
	if koef>1: koef=1
	randomize(); bad=randf()>1-0.41*koef
	
	if new_hexa==null:
		if !bad:
			new_hexa=hexa_figure.instance()
			k_hex+=1
			x=get_next_corresponding_hexa()
			lvl_hexas_alive[x]+=1
			new_hexa.color=hexa_figure_colors[x]; new_hexa.level=x+1
		else:
			new_hexa=hexa_figure_bad.instance()
			new_hexa.level=10
		new_hexa.position=sng.bg_game.glow_first.rect_position
		new_hexa.scale=Vector2(0.45, 0.45)
		new_hexa.z_index=4
		add_child(new_hexa)
	
		if !bad:
			next_hexa=hexa_figure.instance()
			k_hex+=1
			x=get_next_corresponding_hexa()
			lvl_hexas_alive[x]+=1
			next_hexa.color=hexa_figure_colors[x]; next_hexa.level=x+1
		else: 
			next_hexa=hexa_figure_bad.instance()
			next_hexa.level=10
		next_hexa.position=sng.bg_game.glow_second.rect_position
		next_hexa.scale=Vector2(0.35, 0.35)
		add_child(next_hexa)
	else:
		new_hexa=next_hexa
		new_hexa.position=sng.bg_game.glow_first.rect_position
		new_hexa.scale=Vector2(0.45, 0.45)
		new_hexa.z_index=4
		
		if !bad:
			next_hexa=hexa_figure.instance()
			k_hex+=1
			x=get_next_corresponding_hexa()
			lvl_hexas_alive[x]+=1
			next_hexa.color=hexa_figure_colors[x]; next_hexa.level=x+1
		else: 
			next_hexa=hexa_figure_bad.instance()
			next_hexa.level=10
		next_hexa.position=sng.bg_game.glow_second.rect_position
		next_hexa.scale=Vector2(0.35, 0.35)
		add_child(next_hexa)

func _input(event):
	if !paused:
		if event is InputEventMouseButton and !merging:
			if event.is_pressed():
				if not pressed_screen:
					new_hexa.scale=hexa_scale*Vector2.ONE
				pressed_screen=true
				new_hexa.smooth_move_to(event.position+Vector2(0,-hexa_width/1.25), 0)
				mouse_pointer.position=event.position
			else:
				pressed_screen=false
				if mouse_pointer.get_overlapping_areas().size()==0:
					new_hexa.failed_to_place_hexa()
				else:
					sng.gc.save_progress()
					save_system.save_all()
		if event is InputEventMouseMotion and pressed_screen and !merging:
			new_hexa.smooth_move_to(event.position+Vector2(0,-hexa_width/1.25), 0)
			mouse_pointer.position=event.position

func _prepare_sizings():
	var w_display=ProjectSettings.get_setting("display/window/size/width")
	var h_display=ProjectSettings.get_setting("display/window/size/height")
	var vw_size=get_viewport().size #var vw_size=OS.get_window_size()
	if vw_size.y/vw_size.x>float(h_display)/w_display: h_display=(vw_size.y/vw_size.x)*w_display
	else: w_display=h_display/(vw_size.y/vw_size.x)
	
	var play_width=w_display*(col_play_space[1]-col_play_space[0])
	var play_height=h_display*(row_play_space[1]-row_play_space[0])
	
	var w_hexa_field=dimensions[1]*hexa_original_width*3/4+hexa_original_width*1/4
	var h_hexa_field=dimensions[0]*hexa_original_width*sqrt(3)/2+hexa_original_width*+sqrt(3)/4
	var row_scale=play_height/(h_hexa_field)
	var col_scale=play_width/(w_hexa_field)
	
	if(row_scale<col_scale): hexa_scale=row_scale; else: hexa_scale=col_scale
	hexa_width=hexa_original_width*hexa_scale
	start_pos=Vector2(w_display*col_play_space[0]+hexa_width/2+(play_width-w_hexa_field*hexa_scale)/2, h_display*row_play_space[0]+hexa_width*sqrt(3)/4+(play_height-h_hexa_field*hexa_scale)/2)

func _make_hexa_field():
	for i in range(dimensions[0]):
		field.append([])
		for j in range(dimensions[1]):
			var h=hexa_field.instance()
			h.scale*=hexa_scale; h.row=i; h.col=j;
			if j%2==0:
				h.position=Vector2(start_pos.x+hexa_width*3/4*j, start_pos.y+(hexa_width*sqrt(3)/2)*i)
			else:
				h.position=Vector2(start_pos.x+hexa_width*3/4*j, start_pos.y+(hexa_width*sqrt(3)/2)*i+(hexa_width*sqrt(3)/4))
			field[i].append({"PlaceType": HexaFigure.PlaceType.EMPTY, "HexRef": h})
			add_child(h)
	#main_hexa_figure
	var main_level=1; var fld=save_system.saved_field; var brk=false
	if fld:
		for i in range(fld.size()):
			if brk: break;
			for j in range(len(fld[i])):
				if fld[i][j]=='M':
					if fld[i][j+1] in ['1','2','3','4','5','6','7','8','9']: main_level=int(fld[i][j+1])
					else: main_level=10
					brk=true
	main_hex_ref=hexa_figure_main.instance()
	main_hex_ref.scale*=hexa_scale*1.1; main_hex_ref.color=hexa_figure_colors[main_level-1]; main_hex_ref.level=main_level;
	lvl_hexas_alive[main_level-1]+=1
	main_hex_ref.increasing_level=save_system.main_increasing_level
	sng.bg_game.bgc.color=main_hex_ref.color.darkened(0.25)
	main_hex_ref.place_hexa((dimensions[0]-1)/2, (dimensions[1]-1)/2, fld)
	main_hex_ref.marked_for_merge=true
	add_child(main_hex_ref)
	sng.bg_game.set_hexarepel_y(main_hex_ref.position.y)

var number_of_hexas_merge=0
func start_the_merge(placed_hexref, nohm):
	print("Start merge around main hexa? ", placed_hexref.type==HexaFigure.PlaceType.MAINHEXA)
	merging=true
	placed_hex_ref=placed_hexref
	number_of_hexas_merge=nohm
	self.places_count+=nohm
	print("Number of hexas ",nohm)
	lvl_hexas_alive[placed_hex_ref.level-1]-=nohm

var placed_hex_flooded
var n_combo=0
func level_up_placed_hexa():
	n_combo+=1
	if placed_hex_ref.type==HexaFigure.PlaceType.MAINHEXA:
		var ap=placed_hex_ref.anim_player
		if ap.is_playing():
			ap.clear_queue(); ap.stop(); ap.play("level_up_main")
		else: placed_hex_ref.anim_player.play("level_up_main")
	else: 
		if placed_hex_ref.anim_player.is_playing(): placed_hex_ref.anim_player.queue("level_up")
		else: placed_hex_ref.anim_player.play("level_up")
	repel_unflooded()
	sng.ui_game.add_to_score(main_hex_ref.level*number_of_hexas_merge*placed_hex_ref.level)
	
	if placed_hex_ref.level==hexa_figure_colors.size(): #10
		if placed_hex_flooded:
			placed_hex_ref.pop_around()
	
	if placed_hex_ref==main_hex_ref:
		match main_hex_ref.level:
			1: main_hex_ref.increasing_level=true
			10: main_hex_ref.increasing_level=false
	
	if placed_hex_flooded: lvl_hexas_alive[placed_hex_ref.level-1]-=1
	placed_hex_ref.level+=(1 if placed_hex_ref.increasing_level else -1)
	if placed_hex_ref.level<=hexa_figure_colors.size():
		placed_hex_ref.color=hexa_figure_colors[placed_hex_ref.level-1]
		if placed_hex_flooded: lvl_hexas_alive[placed_hex_ref.level-1]+=1
	
	var m
	if placed_hex_ref.type==HexaFigure.PlaceType.MAINHEXA:
		print("main level up")
		sng.bg_game.bgc.color=placed_hex_ref.color.darkened(0.25)
		m=main_hex_ref.merge_hexas_around()
	else:
		print("basic level up")
		m=main_hex_ref.merge_hexas_around()
		print("1Main can merge: ", m)
		if !m:
			print("1Basic merge")
			m=placed_hex_ref.merge_hexas_around()
		else: print("1Main merge")
	if !m:
		if n_combo>1:
			sng.ui_game.combo.show_combo(n_combo-1)
			n_combo=0
		else: n_combo=0

onready var _merge_sound=load("res://audio/sound_fx/bad_hexa.wav")
var _merge_ass;
func set_current_moving_stage(s):
	current_moving_stage=s
	if s>=0:
		if s<=sng.gc.noh_merge_stages.size()-1:
			_merge_ass=placed_hex_ref.audio_player
			_merge_ass.stream=_merge_sound
			_merge_ass.pitch_scale=0.5+s/10.0
			if _merge_ass.playing: _merge_ass.stop();
			_merge_ass.play()
			print(_merge_ass.stream.get_length())
	else: _merge_ass.pitch_scale=1

func repel_unflooded():
	merging=false
	main_hex_ref.forward_flood_signal(true)
	placed_hex_flooded=placed_hex_ref.marked_flood
	var r=0
	var bad_r=0
	for i in range(dimensions[0]):
		for j in range(dimensions[1]):
			var ftype=field[i][j]["PlaceType"]
			var fhex=field[i][j]["HexRef"]
			if ftype!=HexaFigure.PlaceType.EMPTY and !fhex.marked_flood:
				sng.gc.field[i][j]={"PlaceType": HexaFigure.PlaceType.EMPTY, "HexRef": fhex.on_hexa_field}
				if ftype==HexaFigure.PlaceType.HEXA:
					r+=1; lvl_hexas_alive[fhex.level-1]-=1
				elif ftype==HexaFigure.PlaceType.BADHEXA: bad_r+=1
				fhex.repel();
	self.places_count+=(r+bad_r)
	print("---------------------------")
	print(OS.get_unix_time()-ads.last_interstitial_time)
	print(ads.wait_for_seconds)
	print("---------------------------")
	if r+bad_r>repel_ad_trigger and OS.get_unix_time()-ads.last_interstitial_time>ads.wait_for_seconds:
		print("SHOW AD !!!!!!!!!!!!!!!")
		ads.last_interstitial_time=OS.get_unix_time()
		ads.show_ad_in_seconds(1.5)
	var score_to_add=main_hex_ref.level*(r+bad_r*10)
	if score_to_add>0: sng.ui_game.add_to_score(score_to_add)
	main_hex_ref.forward_flood_signal(false)

func save_progress():
	save_system.saved_field=save_type_field()
	save_system.live_score=sng.ui_game.score
	save_system.main_increasing_level=main_hex_ref.increasing_level
	save_system.nhexa_placed=k_hex
	
	if new_hexa.type==HexaFigure.PlaceType.HEXA:
		match new_hexa.level:
			10: save_system.current_hexa='T'
			_: save_system.current_hexa=String(new_hexa.level)
	else: save_system.current_hexa='B'
	
	if next_hexa.type==HexaFigure.PlaceType.HEXA:
		match next_hexa.level:
			10: save_system.next_hexa='T'
			_: save_system.next_hexa=String(next_hexa.level)
	else: save_system.next_hexa='B'

func save_type_field():
	var r=[]
	for i in range(dimensions[0]):
		var x=''
		for j in range(dimensions[1]):
			var ftype=field[i][j]["PlaceType"]
			match ftype:
				HexaFigure.PlaceType.EMPTY: x+='0'
				HexaFigure.PlaceType.HEXA:
					var fhex=field[i][j]["HexRef"]; x+=('T' if fhex.level==10 else String(fhex.level))
				HexaFigure.PlaceType.BADHEXA: x+='B'
				_:
					var fhex=field[i][j]["HexRef"]; x+='M'+('T' if fhex.level==10 else String(fhex.level))
		r.append(x)
	return r

func load_spawn_new_hexa(type, level, pos):
	var put_here=sng.bg_game.glow_first.rect_position if pos==1 else sng.bg_game.glow_second.rect_position
	var hexa
	match type:
		HexaFigure.PlaceType.HEXA:
			hexa=hexa_figure.instance()
			hexa.color=hexa_figure_colors[level-1]
			lvl_hexas_alive[level-1]+=1
		HexaFigure.PlaceType.BADHEXA:
			hexa=hexa_figure_bad.instance()
	hexa.level=level
	hexa.position=put_here
	hexa.z_index=4
	hexa.scale=Vector2(0.45, 0.45) if pos==1 else Vector2(0.35, 0.35)
	if pos==1: new_hexa=hexa
	elif pos==2: next_hexa=hexa
	add_child(hexa)

func load_progress():
	var rs=save_system.saved_field
	var live_score=save_system.live_score
	var current_hexa=save_system.current_hexa
	#var current_hexa='B'
	var nxt_hexa=save_system.next_hexa
	#var nxt_hexa='6'
	k_hex=save_system.nhexa_placed
	
	if live_score!=null and current_hexa!=null and nxt_hexa!=null:
		sng.ui_game.add_to_score(live_score)
		if current_hexa!='B':
			load_spawn_new_hexa(HexaFigure.PlaceType.HEXA, 10 if current_hexa=='T' else int(current_hexa), 1)
		else:
			load_spawn_new_hexa(HexaFigure.PlaceType.BADHEXA, 10, 1)
		if nxt_hexa!='B':
			load_spawn_new_hexa(HexaFigure.PlaceType.HEXA, 10 if nxt_hexa=='T' else int(nxt_hexa), 2)
		else:
			load_spawn_new_hexa(HexaFigure.PlaceType.BADHEXA, 10, 2)
		
		for i in range(rs.size()):
			var f=0; var continue_next=false
			for j in range(len(rs[i])):
				if continue_next:
					continue_next=false; continue;
				if rs[i][j] in ['1','2','3','4','5','6','7','8','9','T']:
					load_set_figure(HexaFigure.PlaceType.HEXA, 10 if rs[i][j]=='T' else int(rs[i][j]), i, j-f)
				elif rs[i][j]=='B': 
					load_set_figure(HexaFigure.PlaceType.BADHEXA, 10, i, j-f)
				elif rs[i][j]=='M': 
					f=1; continue_next=true

func load_set_figure(type, level, row, col):
	var hexa
	match type:
		HexaFigure.PlaceType.HEXA:
			hexa=hexa_figure.instance()
			hexa.scale=hexa_scale*Vector2.ONE
			hexa.color=hexa_figure_colors[level-1]; hexa.level=level
			lvl_hexas_alive[level-1]+=1
		HexaFigure.PlaceType.BADHEXA:
			hexa=hexa_figure_bad.instance()
			hexa.scale=hexa_scale*Vector2.ONE
			hexa.level=level
	
	add_child(hexa)
	hexa.place_hexa(row, col, true)

func set_places_count(c):
	places_count=c
	if places_count==0:
		sng.ui_game.game_over()

func set_paused(p):
	paused=p
