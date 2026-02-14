extends Label


var time = 0.0
export var shake_speed = 1.0    # Скорость покачивания
export var shake_intensity = 5.0 # Амплитуда движения (в пикселях)
export var scale_speed = 1.0    # Скорость пульсации
export var scale_amount = 0.1   # Насколько сильно увеличивается (0.1 = 10%)

onready var original_position = rect_position

func _process(delta):
	time += delta
	

	var offset_x = sin(time * shake_speed) * shake_intensity
	var offset_y = cos(time * shake_speed * 0.7) * shake_intensity
	rect_position = original_position + Vector2(offset_x, offset_y)
	

	var pulse = 1.0 + sin(time * scale_speed) * scale_amount
	rect_scale = Vector2(pulse, pulse)

	rect_rotation = sin(time * 2.0) * 2.0
