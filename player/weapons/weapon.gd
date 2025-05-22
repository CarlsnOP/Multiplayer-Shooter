extends Node3D
class_name Weapon


@export var is_automatic := false
@export var shot_cooldown := 0.3


@onready var shoot_particles = %ShootParticles
@onready var shoot_light = %ShootLight


func _ready():
	shoot_light.hide()
	shoot_particles.finished.connect(shoot_light.hide)

func play_shoot_fx() -> void:
	shoot_particles.emitting = true
	shoot_light.show()
