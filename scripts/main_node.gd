extends Node2D
class_name MainNode

func _ready():
	sng.main_node=self
	sng.main_node_run()
	shared_audio.play_music("music1")