extends Area2D

var health : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reduce_health():
	health -= 1
	if health == 0:
		$BoxCol.disabled = true
		$AnimatedSprite2D.play("break_apart")
