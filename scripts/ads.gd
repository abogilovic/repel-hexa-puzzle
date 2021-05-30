extends Node

var admob = null
var isReal = true #NAKON PUBLISHANJA
var isTop = false
var adBannerId = "ca-app-pub-9356699798664586/2609514608"
#REAL "ca-app-pub-9356699798664586/2609514608" #test: "ca-app-pub-3940256099942544/6300978111"
var adInterstitialId = "ca-app-pub-9356699798664586/6057805022" 
#REAL "ca-app-pub-9356699798664586/6057805022"#test: "ca-app-pub-3940256099942544/1033173712"
#Interstitial ad after great REPEL!
var timer
var wait_for_seconds = 240; #4 minute
var last_interstitial_time = 0;


func _ready():
	last_interstitial_time = OS.get_unix_time()-wait_for_seconds
	timer = Timer.new(); timer.one_shot=true
	timer.connect("timeout", self, "show_short_video"); add_child(timer)
	
	if(Engine.has_singleton("AdMob")):
		admob = Engine.get_singleton("AdMob")
		admob.init(isReal, get_instance_id())
		loadBanner()
		loadInterstitial()
	get_tree().connect("screen_resized", self, "onResize")

#LOADERS
func loadBanner():
	if admob != null: admob.loadBanner(adBannerId, isTop)

func loadInterstitial():
	if admob != null: admob.loadInterstitial(adInterstitialId)

func show_banner(b):
	if admob != null:
		if b: admob.showBanner()
		else: admob.hideBanner()

func show_short_video():
	print("INTERSTITIAL")
	if admob != null:
		admob.showInterstitial()

func show_ad_in_seconds(seconds):
	timer.set_wait_time(seconds)
	timer.start()

#EVENTS
func _on_admob_network_error():
	print("Network Error")

func _on_interstitial_not_loaded():
	pass

func _on_interstitial_loaded():
	pass

func _on_interstitial_close():
	pass

func onResize():
	if admob != null: admob.resize()