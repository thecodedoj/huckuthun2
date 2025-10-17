extends Node3D

# How often the cannon fires (seconds)
@export var fire_rate: float = 1.5
# Reference to the Garbage projectile scene
@export var projectile_scene: PackedScene
# Projectile speed in 3D units
@export var projectile_speed: float = 30.0
# Damage per projectile
@export var damage: int = 30

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
	# Shoot forward along the cannon's local -Z axis
	garbage.linear_velocity = -global_transform.basis.z * projectile_speed
