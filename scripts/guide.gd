extends CanvasLayer

export(Color) var okay_color
export(Array, NodePath) var cards
export(Array, String) var cards_desc

var active_card=0

func _ready():
	ads.show_banner(false)
	get_node("okay").button_color=okay_color
	get_node(cards[active_card]).get_node("core/label").text=cards_desc[active_card]

func show_next_card():
	get_node(cards[active_card]).get_node("animation_player").play("hide_card")
	active_card+=1
	if active_card<cards.size():
		get_node(cards[active_card]).get_node("core/label").text=cards_desc[active_card]
		get_node(cards[active_card]).get_node("animation_player").play("show_card")
	else: leave_guide()

func leave_guide():
	if save_system.guide_on_startup:
		save_system.guide_on_startup=false
		save_system.save_all()
	ads.show_banner(true)
	queue_free()