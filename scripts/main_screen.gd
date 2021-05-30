extends Control

var high_score_label
var version_label

func _ready():
	print(OS.get_screen_size())
	sng.main_screen=self
	main_screen_run()

func main_screen_run():
	shared_audio.play_music("music2")
	if save_system.guide_on_startup:
		var guide=sng.guide.instance(); add_child(guide)
	else: ads.show_banner(true)
	high_score_label=get_node("graphics/high_score/label")
	version_label=get_node("graphics/version")
	high_score_label.text=String(save_system.classic_hscore)
	version_label.text="v0.2.2"

func _on_play_button_up():
	shared_audio.play_sound_fx("button_click")
	get_node("theme_panel").open_panel()

func _on_settings_button_up():
	shared_audio.play_sound_fx("button_click")
	get_node("settings_panel").open_panel()

func _on_about_button_up():
	shared_audio.play_sound_fx("button_click")
	get_node("about_panel").open_panel()

func _on_exit_button_up():
	shared_audio.play_sound_fx("button_click")
	get_node("leave_panel").open_panel()
