extends TextureRect

export var wave_speed = 2.0      
export var wave_height = 50.0    
export var wave_delay = 1.0      


export var glow_speed = 2.0

onready var buttons = [$Control/Button2, $Control/Button3, $Control/Button4, $Control/Button5] 

var time = 0.0
var original_y_positions = []

func _ready():
	mouse_filter = MOUSE_FILTER_IGNORE 
	for btn in buttons:
		original_y_positions.append(btn.rect_position.y)

func _process(delta):
	time += delta
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		var new_y = original_y_positions[i] + sin(time * wave_speed + i * wave_delay) * wave_height
		btn.rect_position.y = new_y
	
