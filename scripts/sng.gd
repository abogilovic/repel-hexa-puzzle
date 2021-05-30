extends Node
class_name MainSingleton

export(PackedScene) var ps_gc
export(PackedScene) var ps_ui_game
export(PackedScene) var ps_bg_game
export(PackedScene) var guide
export(PackedScene) var rate_us

var color_palette_in_use

var main_screen
var main_node
var gc; var ui_game; var bg_game

func main_node_run():
	gc=ps_gc.instance()
	ui_game=ps_ui_game.instance()
	bg_game=ps_bg_game.instance()
	
	ads.show_banner(true)
	#ads.show_short_video()
	if save_system.show_rate and save_system.n_for_show%3==0:
		var rate=rate_us.instance(); rate.open_panel(); add_child(rate); save_system.n_for_show=0
	main_node.add_child(bg_game);
	main_node.add_child(ui_game);
	main_node.add_child(gc);
