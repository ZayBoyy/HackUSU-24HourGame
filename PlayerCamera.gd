extends Camera2D

export var follow_speed = 10
onready var player = get_node("/root/World/Player")
var speed = 10

func _process(delta):
	if player != null:
		position = position.linear_interpolate(player.position, follow_speed * delta)
