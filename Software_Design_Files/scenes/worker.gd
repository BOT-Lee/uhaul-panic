extends CharacterBody2D

const JUMP_VELOCITY = -1950
const GRAVITY = 4000

var attacking : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# add gravity
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false
			attacking = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
			elif Input.is_action_pressed("ui_right"):
				$AnimatedSprite2D.play("kick")
				attacking = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		# If not on the ground, we are jumping - so play the animation
		$AnimatedSprite2D.play("jump")

	move_and_slide()
