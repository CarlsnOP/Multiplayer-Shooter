extends PlayerCharecter
class_name PlayerLocal


const IDLE_ANIM := "Idle"
const AIR_ANIM := "Jump_Idle"
const WALK_ANIM := "Walk_Shoot"
const RUN_ANIM := "Run_Shoot"
const FOOTSTEP_AUDIO_INTERVAL_WALK := 0.5
const FOOTSTEP_AUDIO_INTERVAL_RUN := 0.37


@export var grenade_amount_label: Label
@export var normal_speed := 3.0
@export var sprint_speed := 5.0
@export var jump_velocity := 4.0
@export var gravity := 0.2
@export var mouse_sensitivity := 0.005


@onready var head: Node3D = $Head
@onready var footstep_timer: Timer = %FootstepTimer
@onready var pause_screen: Control = %PauseScreen


var is_grounded := true
var is_sprinting := false
var current_anim: String
var auto_freeze := false
var is_frozen: bool
var is_paused := false
var nearby_grenades: Array[Grenade] = []


func _ready() -> void:
	super()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if auto_freeze:
		freeze()
	
	pause_screen.hide()

func pause() -> void:
	set_processes(false)
	is_paused = true
	pause_screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause() -> void:
	if not is_frozen:
		set_processes(true)
		
	is_paused = false
	pause_screen.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func freeze() -> void:
	set_processes(false)
	is_frozen = true

func unfreeze() -> void:
	if not is_paused:
		set_processes(true)
		
	is_frozen = false

func set_processes(enabled: bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)
	set_process_input(enabled)

func _physics_process(_delta: float) -> void:
	move()
	choose_anim()
	check_shoot_input()
	check_throw_grenade_input()
	show_nearby_grenades()

func move():
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		is_sprinting = Input.is_action_pressed("sprint")
	
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
		if not direction.is_zero_approx() and footstep_timer.is_stopped():
			AudioManager.play_sfx(AudioManager.SFXKeys.Footstep, Vector3.ZERO, 0.2)
			footstep_timer.start(FOOTSTEP_AUDIO_INTERVAL_WALK if not is_sprinting else FOOTSTEP_AUDIO_INTERVAL_RUN)
		
		if not is_grounded:
			is_grounded = true
			AudioManager.play_sfx(AudioManager.SFXKeys.JumpLand, Vector3.ZERO, 0.2)
	
	else:
		velocity.y -= gravity
	
		if is_grounded:
			is_grounded = false
	
	var speed := normal_speed if not is_sprinting else sprint_speed
	
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed
	
	move_and_slide()

func choose_anim() -> void:
	if not is_grounded:
		current_anim = AIR_ANIM
		return
	
	if velocity.x or velocity.z:
		current_anim = RUN_ANIM if is_sprinting else WALK_ANIM
		return
	
	current_anim = IDLE_ANIM

func check_shoot_input() -> void:
	if Input.is_action_just_pressed("shoot"):
		weapon_holder.start_trigger_press()
	
	elif Input.is_action_just_released("shoot"):
		weapon_holder.end_trigger_press()

func check_throw_grenade_input() -> void:
	if Input.is_action_just_pressed("throw_grenade"):
		get_tree().call_group("Lobby", "try_throw_grenade")

func show_nearby_grenades() -> void:
	var grenades_data := {}
	var own_pos := Vector2(global_position.x, global_position.z)
	
	for grenade in nearby_grenades:
		var grenade_pos := Vector2(grenade.global_position.x, grenade.global_position.z)
		grenades_data[grenade.name] = own_pos.angle_to_point(grenade_pos) + PI / 2 + rotation.y
	
	get_tree().call_group("GrenadePromptControl", "update_grenade_prompts", grenades_data)

func update_grenades_left(grenades_left: int) -> void:
	grenade_amount_label.text = str(grenades_left)

func update_health_bar(current_health: int, max_health: int, changed_amount: int) -> void:
	super(current_health, max_health, changed_amount)
	
	if changed_amount < 0:
		get_tree().call_group("CameraShakeComponent", "add_noise", absi(changed_amount) / float(max_health))
	
	get_tree().call_group("HealthChangeMask", "update_mask", current_health / float(max_health))
	
func _input(event) -> void:
	if event is InputEventMouseMotion:
		look_around(event.relative)

func look_around(relative:Vector2):
	rotate_y(-relative.x * mouse_sensitivity)
	head.rotate_x(-relative.y * mouse_sensitivity)
	head.rotation.x = clampf(head.rotation.x, -PI/2, PI/2)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause() if not is_paused else unpause()

func _on_grenade_detection_area_3d_area_entered(area: Area3D) -> void:
	nearby_grenades.append(area.get_parent())

func _on_grenade_detection_area_3d_area_exited(area: Area3D) -> void:
	nearby_grenades.erase(area.get_parent())
