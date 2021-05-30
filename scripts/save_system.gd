extends Node

var save_path="user://save_file.cfg"
var config=ConfigFile.new()
var respond_on_load=config.load(save_path)

#scores
var classic_hscore setget set_classic_high_score, get_classic_high_score
#settings
var sound setget set_sound, get_sound
var music setget set_music, get_music
#continue
var saved_field setget set_saved_field, get_saved_field
var live_score setget set_live_score, get_live_score
var current_hexa setget set_current_hexa, get_current_hexa
var next_hexa setget set_next_hexa, get_next_hexa
var nhexa_placed setget set_nhexa_placed, get_nhexa_placed
var main_increasing_level setget set_main_increasing_level, get_main_increasing_level
var guide_on_startup setget set_guide_on_startup, get_guide_on_startup
var n_for_show setget set_n_for_show, get_n_for_show
var show_rate setget set_show_rate, get_show_rate

func _ready():
	if respond_on_load!=OK:
		var file=File.new()
		file.open(save_path, File.WRITE)
		file.close()
		config.load(save_path)

func _notification(what):
	if what==MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		save_system.save_all()
		if sng.ui_game and is_instance_valid(sng.ui_game):
			sng.gc.paused=true
			sng.gc.save_progress()
			sng.ui_game.leave_panel.open_panel()
		else: sng.main_screen.get_node("leave_panel").open_panel()

#x
func save_value(section, key, value): config.set_value(section, key, value)
func load_value(section, key): return config.get_value(section, key)
func save_all(): config.save(save_path)
#x

#GETSETS

#CONTINUE
func set_saved_field(field):
	saved_field=field
	save_value("continue", "classic_saved_field", field)

func get_saved_field():
	if !saved_field:
		if config.has_section_key("continue", "classic_saved_field"): 
			saved_field=load_value("continue", "classic_saved_field")
	return saved_field

func set_live_score(s):
	live_score=s
	save_value("continue", "live_score", s)

func get_live_score():
	if !live_score:
		if config.has_section_key("continue", "live_score"):
			live_score=load_value("continue", "live_score")
	return live_score

func set_current_hexa(b):
	current_hexa=b
	save_value("continue", "current_hexa", b)

func get_current_hexa():
	if !current_hexa:
		if config.has_section_key("continue", "current_hexa"):
			current_hexa=load_value("continue", "current_hexa")
	return current_hexa

func set_next_hexa(b):
	next_hexa=b
	save_value("continue", "next_hexa", b)

func get_next_hexa():
	if !next_hexa:
		if config.has_section_key("continue", "next_hexa"):
			next_hexa=load_value("continue", "next_hexa")
	return next_hexa

func set_nhexa_placed(n):
	nhexa_placed=n
	save_value("continue", "nhexa_placed", n)
	
func get_nhexa_placed():
	if !nhexa_placed:
		if config.has_section_key("continue", "nhexa_placed"):
			nhexa_placed=load_value("continue", "nhexa_placed")
	return nhexa_placed

func set_main_increasing_level(inc):
	main_increasing_level=inc
	save_value("continue", "main_increasing_level", inc)

func get_main_increasing_level():
	if !main_increasing_level:
		if config.has_section_key("continue", "main_increasing_level"):
			main_increasing_level=load_value("continue", "main_increasing_level")
		else: self.main_increasing_level=true
	return main_increasing_level

#SCORES
func set_classic_high_score(value):
	classic_hscore=value
	save_value("scores", "classic_hscore", value)

func get_classic_high_score():
	if !classic_hscore:
		if config.has_section_key("scores", "classic_hscore"): 
			classic_hscore=load_value("scores", "classic_hscore")
		else: self.classic_hscore=0
	return classic_hscore

#SETTINGS
func set_sound(value):
	sound=value
	save_value("settings", "sound", value)

func get_sound():
	if !sound:
		if config.has_section_key("settings", "sound"): 
			sound=load_value("settings", "sound")
		else: self.sound=true
	return sound

func set_music(value):
	music=value
	save_value("settings", "music", value)

func get_music():
	if !music:
		if config.has_section_key("settings", "music"): 
			music=load_value("settings", "music")
		else: self.music=true
	return music

func set_guide_on_startup(value):
	guide_on_startup=value
	save_value("settings", "guide_on_startup", value)

func get_guide_on_startup():
	if !guide_on_startup:
		if config.has_section_key("settings", "guide_on_startup"): 
			guide_on_startup=load_value("settings", "guide_on_startup")
		else: self.guide_on_startup=true
	return guide_on_startup

func set_n_for_show(value):
	n_for_show=value
	save_value("settings", "n_for_show", value)

func get_n_for_show():
	if !n_for_show:
		if config.has_section_key("settings", "n_for_show"): 
			n_for_show=load_value("settings", "n_for_show")
		else: self.n_for_show=0
	return n_for_show

func set_show_rate(value):
	show_rate=value
	save_value("settings", "show_rate", value)

func get_show_rate():
	if !show_rate:
		if config.has_section_key("settings", "show_rate"): 
			show_rate=load_value("settings", "show_rate")
		else: self.show_rate=true
	return show_rate