extends Node

export(Dictionary) var sound_effects
export(Dictionary) var music_samples
onready var sound_player=get_node("sound_fx")
onready var music_player=get_node("music")

func play_sound_fx(s, pitch=1):
	if sound_player.playing: sound_player.stop()
	sound_player.stream=sound_effects[s]
	sound_player.pitch_scale=pitch
	sound_player.play()

func play_music(s):
	if music_player.playing: music_player.stop()
	music_player.stream=music_samples[s]
	music_player.play()

func pause_music_stream(p):
	music_player.stream_paused=p
