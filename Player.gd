extends KinematicBody2D

const MAX_SPEED = 200
const ACCELERATION = 450
const DECELERATION = 16
const JUMP_IMPULSE = 296
const MAX_JUMPS = 1
const MAX_TIMER = 5
const MAX_JUMP_TIME = 10

var velocity = Vector2.ZERO
var jumps_left = MAX_JUMPS
var wolf_timer = MAX_TIMER
var jump_timer = MAX_JUMP_TIME
var gravity = 1800
var wall_jumped = false
var wall_timer = 0
var directionRight = null

func _ready():
	$PurplePete.play("default")
	
func _physics_process(delta):
	
	update_velocity(delta)
	if !Input.is_action_pressed("dash"):
		if velocity.x > 120:
			velocity.x = 120
		if velocity.x < -120:
			velocity.x = -120

	if is_on_floor():
		jumps_left = MAX_JUMPS
		wolf_timer = MAX_TIMER
	else: 
		tick_wolf_timer()

	wall_cling()

	if Input.is_action_just_pressed("jump"):
		if jumps_left > 0:
			jump()
			gravity = 0
			
		elif (wall_timer > 0) and !is_on_floor():
			wall_jump()
		
	elif is_on_ceiling():
		velocity.y = 0
		release_jump()

	# if not (just pressed jump or on ceiling) and jump is pressed and not on floor 
	elif Input.is_action_pressed("jump") and !is_on_floor():
		if wall_jumped == true:
			hold_wall_jump()
		if !is_on_wall():
			hold_jump()

	elif Input.is_action_just_released("jump") or is_on_floor() or is_on_wall():
		release_jump()
		wall_jumped = false
		jumps_left = 0

	else:
		destick()
		
	animation_logic()


func update_velocity(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()
	
	if input_vector.x != 0:
		if (velocity.x < 0 and input_vector.x > 0) or (velocity.x > 0 and input_vector.x < 0):
			velocity.x += input_vector.x * ACCELERATION*1.5 * delta
		else: 
			velocity.x += input_vector.x * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			
	else:
		velocity.x = clamp(lerp(velocity.x, 0, DECELERATION * delta), -MAX_SPEED, MAX_SPEED)
		static_friction()

	if velocity.y < 1000:
		velocity.y += gravity * delta
	else:
		velocity.y = 1000
	velocity = move_and_slide(velocity, Vector2.UP)


func static_friction():
	if velocity.x < 3 and velocity.x > -3:
		velocity.x = 0
		


func jump():
	velocity.y = - JUMP_IMPULSE - (0.25*abs(velocity.x))


func hold_jump():
	gravity = 0
	if velocity.y < 300:
		velocity.y += 12


func release_jump():
	gravity = 1000
	jumps_left = 0
	if velocity.y < 0:
		velocity.y -= velocity.y/1.5


func wall_cling():
	if is_on_wall() and !is_on_floor():
		
		if velocity.y <= 50:
			velocity.y += 8
		else:
			velocity.y = 50
		wall_timer = MAX_TIMER
	else:
		wall_timer -= 1


func wall_jump():
	if !test_move(get_transform(), Vector2(2, 0)):
		jump()
		velocity.y -= JUMP_IMPULSE*0.07
		velocity.x += 125
		wall_jumped = true
		directionRight = true

	elif !test_move(get_transform(), Vector2(-2, 0)):
		jump()
		velocity.y -= JUMP_IMPULSE*0.07
		velocity.x -= 125
		wall_jumped = true
		directionRight = false

func hold_wall_jump():
	gravity = 400
	velocity.x += velocity.x/1.9
	
	if Input.is_action_pressed("ui_left"):
		if directionRight == false:
			velocity.x += velocity.x/1.65
		else:
			velocity.x -= velocity.x/3.5
	elif Input.is_action_pressed("ui_right"):
		if directionRight == true:
			velocity.x += velocity.x/1.65
		else:
			velocity.x -= velocity.x/3.5

	else:
		velocity.x -= velocity.x/14
		if velocity.x > 140:
			velocity.x = 140
		if velocity.x < -140:
			velocity.x = -140

func destick():
	if is_on_ceiling(): # Prevent the player from sticking to the ceiling
		velocity.y = 0

	if is_on_wall(): # Prevent the player from sticking to walls
		velocity.x = 0


func tick_wolf_timer():
	if wolf_timer == 0:
		jumps_left = 0
	else:
		wolf_timer -= 1


func _on_Area2D_body_entered(body):
	 get_tree().change_scene("res://Node2D.tscn")


func kill():
	$PurplePete.play("death")
	

func animation_logic():
	var peter = $PurplePete
	if peter.get_animation() == "death":
		return

	#facing left or right.
	if velocity.x < 0:
		peter.set_flip_h(true)
	elif velocity.x > 0:
		peter.set_flip_h(false)
		
	if !is_on_floor():
		#wall slide
		if is_on_wall():
			peter.play("cling")
			if Input.is_action_pressed("ui_left"):
				peter.set_flip_h(false)
			elif Input.is_action_pressed("ui_right"):
				peter.set_flip_h(true)
			return
		else:
			peter.play("air")
		return
	#mid-air

	if abs(velocity.x) > 0:
		peter.play("walk")
		
	elif Input.is_action_pressed("ui_down") and is_on_floor():
		peter.play("crouch")
		
	else:
		peter.play("default")



func _on_DeathBox_body_entered(body):
	if body == self:
		kill()


func _on_Button_pressed():
	kill()
	

func _on_PurplePete_animation_finished():
	if $PurplePete.get_animation() == "death":
		get_tree().reload_current_scene()
	
