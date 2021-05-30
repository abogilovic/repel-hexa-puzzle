extends CanvasLayer
class_name UI

var score=0
var high_score=0
onready var score_label=get_node("score_label")
onready var high_score_label=get_node("high_score_label")
onready var time_label=get_node("time_label")

onready var pause_panel=get_node("pause_panel")
onready var settings_panel=get_node("settings_panel")
onready var end_game_panel=get_node("end_game_panel")
onready var leave_panel=get_node("leave_panel")
onready var combo=get_node("combo")

var t_start = 0
var t_now = 0
var timer

var in_pause_panel=false

func _ready():
	time_ready()
	high_score_ready()

func game_over():
	sng.gc.paused=true
	save_system.classic_hscore=high_score
	save_system.saved_field=null
	end_game_panel.open_panel()

func high_score_ready():
	high_score=save_system.classic_hscore
	high_score_label.text=String(high_score)

func time_ready():
	t_start = OS.get_unix_time()
	timer=Timer.new()
	timer.set_wait_time(1)
	timer.connect("timeout", self, "time_update")
	add_child(timer)
	timer.start()

func time_update():
	t_now = OS.get_unix_time()
	var elapsed=t_now-t_start
	var minutes=elapsed/60
	var seconds=elapsed%60
	if minutes>0: time_label.text="%d:%d"%[minutes, seconds]
	else: time_label.text="%d"%seconds

func add_to_score(s):
	score+=s;
	score_label.text=String(score)
	if score>high_score: 
		high_score=score
		high_score_label.text=String(high_score)

func _on_pause_button_pressed():
	shared_audio.play_sound_fx("button_click")
	pause_panel.open_panel()

func _on_pause_button_button_up(): #tiny bug solve
	sng.gc.new_hexa.failed_to_place_hexa()
