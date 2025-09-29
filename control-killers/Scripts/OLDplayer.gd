extends CharacterBody2D
# set to 4 for real speed
const alpha = 4
const SPEED = 100.0*alpha*1.5
const JUMP_VELOCITY = -125.0*alpha

var can_jump = 1
var is_jump=0
var jump_timer=0
var is_slide=0
var dir=0
var numjumps=2

var atype=0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * alpha *1.5
		print(get_gravity())

	if is_on_floor():
		can_jump = 1
		numjumps=2
		is_jump =0
		jump_timer=0
	else:
		can_jump = move_toward(can_jump,0,.2)
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and numjumps+can_jump>0:
		is_jump=1
		is_slide=0
	
	if Input.is_action_pressed("ui_up") and jump_timer<0.15 and is_jump==1:
		jump_timer+=delta
		velocity.y=JUMP_VELOCITY
		
		
	if Input.is_action_just_released("ui_up") and jump_timer<0.1 and is_jump==1:
		velocity.y=JUMP_VELOCITY*jump_timer/0.1
		numjumps-=1
		jump_timer=0
		is_jump=0
	elif Input.is_action_just_released("ui_up") and jump_timer>0.1 and is_jump==1:
		jump_timer=0
		numjumps-=1
		is_jump=0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_down") and is_slide==0 and not velocity.x==0:
		is_slide=1
		velocity.x=velocity.x*1.5
	elif is_slide==1 and velocity.x==0:
		is_slide=0
	
		
	
	if is_slide==1 and is_on_floor():
		if direction*velocity.x<0:
			velocity.x = move_toward(velocity.x,0,dir*alpha*4500/velocity.x)
		elif direction==0:
			velocity.x = move_toward(velocity.x,0,dir*alpha*3000/velocity.x)
		else:
			velocity.x = move_toward(velocity.x,0,dir*alpha*2000/velocity.x)
	elif is_slide==1:
		velocity.x = move_toward(velocity.x,0,dir*100/velocity.x)
	elif direction:
		dir=direction
		if not Input.is_action_pressed("ui_down"):
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
	
	
	var playsprite = $AnimatedSprite2D
	#anim
	
	if is_slide==0:
		if direction == -1:
			playsprite.flip_h=false
		elif direction == 1:
			playsprite.flip_h=true
	
	if is_on_floor() and is_slide==1:
		playsprite.play("Slide")
	elif is_on_floor() and Input.is_action_pressed("ui_down"):
		playsprite.play("Bow")
	elif velocity.x==0 and velocity.y==0:
		playsprite.play("Idle")
	elif velocity.y<0:
		playsprite.play("Jump")
	elif velocity.y>0:
		playsprite.play("Fall")
	else:
		playsprite.play("Run")
