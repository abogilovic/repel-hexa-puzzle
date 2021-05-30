extends Control

export(Color) var pnl_clr
export(Array, NodePath) var buttons
onready var anim_player=get_node("animation_player")
onready var music_slider=get_node("core/music")
onready var sound_slider=get_node("core/sound")

func _ready():
	for button in buttons:
		button=get_node(button)
		if button.fixed_highlight:
			if button.highlight: button.button_color=pnl_clr
			else: button.button_color=button.unhiglighted_color
	music_slider.set_slider(pnl_clr, self, "update_music")
	music_slider.value=save_system.music
	sound_slider.set_slider(pnl_clr, self, "update_sound")
	sound_slider.value=save_system.sound

func open_panel():
	music_slider.value=save_system.music
	sound_slider.value=save_system.sound
	anim_player.play("open_panel")

func close_panel():
	anim_player.play_backwards("open_panel")

func update_music(v):
	save_system.music=v
	save_system.save_all()
	shared_audio.pause_music_stream(not v)
	AudioServer.set_bus_mute(2, not v) #2-Music Bus

func update_sound(v):
	save_system.sound=v
	save_system.save_all()
	AudioServer.set_bus_mute(1, not v) #1-Sound Bus

func _on_play_tutorial_pressed():
	pass # Replace with function body.

func _on_guide_pressed():
	var guide=sng.guide.instance()
	add_child(guide)
