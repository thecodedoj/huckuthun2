extends Node3D

# Fire rate in seconds
@export var fire_rate: float = 3.0
# Reference to the Garbage projectile scene
@export var projectile_scene: PackedScene
# Projectile initial speed
@export var projectile_speed: float = 25.0
# Damage per hit
@export var damage: int = 100
# Arc height multiplier (adjust to make the RPG arc higher or lower)
@export var arc_strength: float = 0.3

var time_since_last_shot: float = 0.0

func _process(delta):
	time_since_last_shot += delta
	if time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0

func shoot():
	if not projectile_scene:
		return
	var garbage = projectile_scene.instantiate()
	get_parent().add_child(garbage)
	garbage.global_transform.origin = global_transform.origin

	garbage.damage = damage
	# RPG arc: forward + upward
	var direction = -global_transform.basis.z + Vector3.UP * arc_strength
	garbage.linear_velocity = direction.normalized() * projectile_speed
