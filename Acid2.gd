extends Light2D


var t = 0

func _process(delta):
	t += 3*delta
	set_energy(0.25*sin(t)+0.25)

