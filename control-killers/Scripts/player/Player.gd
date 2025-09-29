extends CharacterBody2D


#Constants
const ALPHA = 1
const SPEED = 700.0 * ALPHA
const JUMP = -600.0 * ALPHA
const GRAVITY = 5000 * ALPHA


#variables
var direction = 0
var dir = 1
var jumptimer = 0
var jumping = false
var canjump = true
var coyote = 0
var sliding = false



func _ready():
	
	velocity=Vector2.ZERO
	Engine.time_scale=1



func _physics_process(delta: float) -> void:
	$Label.text=" "
	direction = Input.get_axis("moveleft", "moveright")
	gravity(delta)
	jump(delta)
	runandslide()
	if Input.is_action_just_pressed("attack"):
		attack()

	move_and_slide()
	
	animation()



func gravity(delta:float):
	if not is_on_floor() and jumping==false:
		velocity.y = move_toward(velocity.y,GRAVITY,GRAVITY*delta)



func jump(delta:float):
	var timemax=0.15
	if is_on_floor():
		canjump=true
		jumptimer=0
		coyote=0
	elif coyote<timemax:
		coyote+=delta
	else:
		canjump=false
	if Input.is_action_just_pressed("moveup") and canjump==true:
		jumping=true
		velocity.y = JUMP
		if sliding==true:
			velocity.x=min(SPEED,velocity.x*1.5)
		canjump=false
	elif Input.is_action_pressed("moveup") and jumptimer<timemax and jumping==true:
		jumptimer += delta
	elif Input.is_action_just_released("moveup") or not jumptimer<timemax:
		if jumptimer<timemax and jumping==true:
			velocity.y=JUMP*jumptimer/timemax
		jumping=false



func runandslide():
	
	if direction:
		dir=direction
		if Input.is_action_just_pressed("movedown") and sliding==false:
			sliding=true
			velocity.x=direction*SPEED*1.25
		elif sliding==false:
			velocity.x=direction*SPEED
	
	if velocity.x == 0 or (not is_on_floor() and abs(velocity.x)<SPEED*0.8):
			sliding=false
		
	if sliding==false and not direction:
		velocity.x=move_toward(velocity.x,0,SPEED/5)
	elif sliding==true:
		if is_on_floor() and velocity.x*direction>0:
			velocity.x=move_toward(velocity.x,0,SPEED/55)
		elif is_on_floor():
			velocity.x=move_toward(velocity.x,0,SPEED/10)
		else:
			velocity.x=move_toward(velocity.x,0,SPEED/75)



func attack():
	pass



func animation():
	var playsprite=$AnimatedSprite2D
	if sliding==false:
		if direction == -1:
			playsprite.flip_h=false
		elif direction == 1:
			playsprite.flip_h=true
	
	if is_on_floor() and sliding==true:
		playsprite.play("Slide")
	elif is_on_floor() and Input.is_action_pressed("movedown"):
		playsprite.play("Bow")
	elif velocity.x==0 and velocity.y==0:
		playsprite.play("Idle")
	elif velocity.y<0:
		playsprite.play("Jump")
	elif velocity.y>0:
		playsprite.play("Fall")
	else:
		playsprite.play("Run")
