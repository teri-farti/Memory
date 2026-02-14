extends Button


export var shake_speed = 15.0
export var shake_intensity = 2.0
export var scale_amount = 1.1 

var is_hovered = false
var time = 0.0

onready var original_scale = rect_scale

func _ready():
	rect_pivot_offset = rect_size / 2
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _process(delta):
	if is_hovered:
		time += delta
		rect_rotation = sin(time * shake_speed) * shake_intensity
		rect_scale = rect_scale.linear_interpolate(original_scale * scale_amount, 0.2)
	else:
		rect_rotation = lerp(rect_rotation, 0, 0.2)
		rect_scale = rect_scale.linear_interpolate(original_scale, 0.2)

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false
