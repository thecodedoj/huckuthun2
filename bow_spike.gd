extends RigidBody3D

@export var damage: int = 40

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
