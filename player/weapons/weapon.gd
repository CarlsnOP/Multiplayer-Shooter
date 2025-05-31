extends Node3D
class_name Weapon


@export var is_automatic := false
@export var shot_cooldown := 0.3


@onready var shoot_particles = %ShootParticles
@onready var shoot_light = %ShootLight


var weapon_id: int


func _ready() -> void:
	shoot_light.hide()
	shoot_particles.finished.connect(shoot_light.hide)

func play_shoot_fx(is_local := false) -> void:
	shoot_particles.emitting = true
	shoot_light.show()
	
	var sfx_key: AudioManager.SFXKeys
	
	match weapon_id:
		0:
			sfx_key = AudioManager.SFXKeys.ShootPistol
			
		1:
			sfx_key = AudioManager.SFXKeys.ShootSMG
			
		2:
			sfx_key = AudioManager.SFXKeys.ShootShotgun
	
	AudioManager.play_sfx(sfx_key, global_position if not is_local else Vector3.ZERO, 0.1)
