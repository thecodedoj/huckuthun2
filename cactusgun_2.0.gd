extends Node3D

@export var fire_rate: float = 1.0
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 40.0
@export var damage: int = 20

var time_since_last_shot: float = 0.0

func _process(delta):
	time_since_last_shot += delta
	if time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0

func shoot():
	if not projectile_scene:
		return
	var spike = projectile_scene.instantiate()
	get_parent().add_child(spike)
	spike.global_position = global_position
	spike.damage = damage
	# Shoot forward along -Z local axis
	spike.linear_velocity = -global_transform.basis.z * projectile_speed
