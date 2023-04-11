extends Light2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	t += 3*delta
	set_energy(0.25*sin(t)+0.25)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
