extends CanvasLayer

onready var rect1 = $ColorRect
onready var rect2 = $ColorRect2
onready var rectgame = $ColorGame
onready var cards_container = $ColorGame/GridContainer
onready var clisck_label = $ColorGame/Label
onready var start_btn = $ColorRect/Button
onready var btn_sound = $BtnSound
onready var card_sound = $CardSound
onready var MusicSound = $MusicSound

var pixel_font = DynamicFont.new() 
var skull_icon = preload("res://pngtree-pixel-abstract-glitch-skull-pixel-style-png-image_3515859.png") 

var symbols = []
var card_buttons = []
var opened_cards = []
var matched_count = 0
var TOTAL_CARDS = 4 
var clicks = 0
var is_processing = false

func _ready():
	VisualServer.set_default_clear_color(Color("#1a1a1a"))
	
	var font_res = load("res://Samson.ttf")
	if font_res:
		pixel_font.font_data = font_res
		pixel_font.size = 32

	if rect1: rect1.show()
	if rect2: rect2.hide()
	if rectgame: rectgame.hide()
	if start_btn: start_btn.connect("pressed", self, "_on_start_button")
	

	var sfx_slider = $ColorRect2/SfxSlider
	var music_slider = $ColorRect2/MusicSlider
	
	sfx_slider.connect("value_changed", self, "_on_sfx_volume_changed")
	music_slider.connect("value_changed", self, "_on_music_volume_changed")

	for btn in [$ColorRect2/Control/Button5, $ColorRect2/Control/Button2, $ColorRect2/Control/Button3, $ColorRect2/Control/Button4]:
		btn.connect("pressed", self, "_play_btn_sound")

# --- ЗВУКОВЫЕ ФУНКЦИИ ---

func _play_btn_sound():
	btn_sound.play()

func _play_card_sound():
	card_sound.play()

func _on_sfx_volume_changed(value):
	btn_sound.volume_db = linear2db(value / 100)
	card_sound.volume_db = linear2db(value / 100)

func _on_music_volume_changed(value):
	MusicSound.volume_db = linear2db(value / 100)
	pass


func _on_start_button():
	_play_btn_sound() 
	if rect1: rect1.hide()
	if rectgame: rectgame.hide()
	if rect2: rect2.show()

func _on_card_pressed(index):
	if is_processing: return
	var btn = card_buttons[index]
	if btn.get_meta("matched") or opened_cards.has(btn): return

	_play_card_sound() # Играем звук при нажатии на карточку
	_animate_flip(btn, str(btn.get_meta("symbol")))
	opened_cards.append(btn)

	if opened_cards.size() == 2:
		is_processing = true
		yield(get_tree().create_timer(0.7), "timeout")
		_check_opened_pair()
		is_processing = false

func _animate_flip(btn, target_text, show_icon = false):
	var t = get_tree().create_tween()
	t.tween_property(btn, "rect_scale:x", 0.0, 0.1)
	yield(t, "finished")
	
	if show_icon:
		btn.icon = skull_icon
		btn.text = ""
		btn.self_modulate = Color(0.3, 0.3, 0.3) 
	else:
		btn.icon = null 
		btn.text = target_text
		btn.self_modulate = Color(1, 1, 1)
	
	var t2 = get_tree().create_tween()
	t2.tween_property(btn, "rect_scale:x", 1.0, 0.1)


func _check_opened_pair():
	clicks += 1
	clisck_label.text = "CLICKS: " + str(clicks)
	var a = opened_cards[0]
	var b = opened_cards[1]
	
	if a.get_meta("symbol") == b.get_meta("symbol"):
		a.set_meta("matched", true)
		b.set_meta("matched", true)
		a.disabled = true
		b.disabled = true
		
		var purple = Color(0.7, 0.3, 1.0, 1.0) 
		a.modulate = purple
		b.modulate = purple
		
		matched_count += 2
	else:
		_animate_flip(a, "", true) 
		_animate_flip(b, "", true)
		
	opened_cards.clear()
	_check_win()




func _generate_symbols():
	var needed_pairs = TOTAL_CARDS / 2
	symbols.clear()
	var pool = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","!","@","#","$","%","&","*","?","+","=",":","^",";","-"]
	
	if needed_pairs > pool.size():
		push_error("Слишком много карт для текущего пула символов!")
		return
		
	for i in range(needed_pairs):
		symbols.append(pool[i])
		symbols.append(pool[i])
	symbols.shuffle()

func _create_cards():
	# 1. СБРОС
	cards_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	for child in cards_container.get_children():
		child.queue_free()
	card_buttons.clear()

	var side = int(sqrt(TOTAL_CARDS))
	cards_container.columns = side
	
	# 2. ДИНАМИЧЕСКИЙ РАЗМЕР 
	var screen_size = get_viewport().get_visible_rect().size
	var h_sep = 10
	
	var work_area_w = screen_size.x * 0.9
	var work_area_h = (screen_size.y - 150) * 0.9
	
	var max_grid_size = min(work_area_w, work_area_h)
	
	var manual_card_size = (max_grid_size / side) - h_sep
	
	manual_card_size = clamp(manual_card_size, 40, 150) 
	
	var card_size = Vector2(manual_card_size, manual_card_size)
	
	pixel_font.size = int(manual_card_size * 0.6)

	# 3. СОЗДАНИЕ
	for i in range(TOTAL_CARDS):
		var btn = Button.new()
		btn.rect_min_size = card_size
		btn.rect_pivot_offset = card_size / 2 
		btn.expand_icon = true
		btn.icon = skull_icon 
		btn.self_modulate = Color(0.6, 0.6, 0.6)
		btn.add_font_override("font", pixel_font)
		
		var flat_style = StyleBoxFlat.new()
		flat_style.bg_color = Color("#050505")
		flat_style.set_corner_radius_all(0)
		flat_style.border_color = Color("#000000")
		btn.add_stylebox_override("normal", flat_style)
		btn.add_stylebox_override("disabled", flat_style)
		
		btn.connect("pressed", self, "_on_card_pressed", [i])
		btn.set_meta("symbol", symbols[i])
		btn.set_meta("matched", false)
		cards_container.add_child(btn)
		card_buttons.append(btn)

	# 4. ЦЕНТРИРОВАНИЕ
	cards_container.set_as_toplevel(true) 
	
	yield(get_tree(), "idle_frame") 
	
	cards_container.add_constant_override("hseparation", h_sep)
	cards_container.add_constant_override("vseparation", h_sep)

	var total_w = (side * manual_card_size) + ((side - 1) * h_sep)
	var total_h = (side * manual_card_size) + ((side - 1) * h_sep)

	var final_x = (screen_size.x - total_w) / 2
	var final_y = (screen_size.y - total_h) / 2 + 25
	
	cards_container.anchor_left = 0
	cards_container.anchor_top = 0
	cards_container.anchor_right = 0
	cards_container.anchor_bottom = 0
	
	cards_container.rect_global_position = Vector2(final_x, final_y)
	
	cards_container.rect_size = Vector2(total_w, total_h)










func _on_level_1_button(): _setup_level(16) # 4x4
func _on_level_2_button(): _setup_level(36) # 6x6
func _on_level_3_button(): _setup_level(64) # 8x8
func _on_level_4_button(): _setup_level(100) # 10x10


func _setup_level(count):
	TOTAL_CARDS = count 
	rect2.hide()
	rectgame.show()
	_reset_game()
	_generate_symbols()
	_create_cards()


func _mark_as_matched(a, b):
	a.set_meta("matched", true)
	b.set_meta("matched", true)
	a.disabled = true
	b.disabled = true
	a.modulate = Color(0.3, 1, 0.3, 0.7) 
	b.modulate = Color(0.3, 1, 0.3, 0.7)
	matched_count += 2

func _reset_game():
	for b in card_buttons:
		if is_instance_valid(b):
			b.queue_free()
	card_buttons.clear()
	opened_cards.clear()
	matched_count = 0

func _check_win():
	if matched_count >= TOTAL_CARDS:
		if rect2:
			clicks = 0
			clisck_label.text = "clicks: " + str(clicks)
			rectgame.hide()
			rect2.show()
		print("You win!")
