extends RigidBody3D

@export var damage: int = 30

func _ready():
	# Connect collision signal
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body has a take_damage method
	if body.has_method("take_damage"):
		body.take_damage(damage)
	# Destroy projectile after hitting
	queue_free()
