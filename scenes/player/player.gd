extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_velocity: float = -620.0
@export var gravity: float = 1400.0

var coins: int = 0
@onready var anim: AnimatedSprite2D = $AnimatedSprite
@onready var spawn_point: Node2D = get_tree().get_current_scene().get_node("SpawnPoint")
@onready var hud: CanvasLayer = get_tree().get_current_scene().get_node("HUD")

func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	print("Player ready. Groups:", get_groups())

func _physics_process(delta: float) -> void:
	var direction: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	velocity.x = direction * speed
	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: float) -> void:
	if anim == null:
		return

	if direction > 0.1:
		anim.flip_h = false
	elif direction < -0.1:
		anim.flip_h = true

	if not is_on_floor():
		anim.play("jump")
	elif abs(velocity.x) > 10.0:
		anim.play("walk")
	else:
		anim.play("idle")

func bounce() -> void:
	velocity.y = jump_velocity / 2
	print("Enemy stomped!")

func apply_damage(_amount: int) -> void:
	if hud:
		hud.record_attempt()
	if spawn_point:
		print("Took damage! Respawning to:", spawn_point.global_position)
		global_position = spawn_point.global_position
		velocity = Vector2.ZERO
		anim.play("idle")
	else:
		print("SpawnPoint not found — can't respawn.")

func add_coins(n: int) -> void:
	coins += n
	print("Picked up coin! Total coins:", coins)

func apply_heal(amount: int) -> void:
	print("Picked up health! Heal amount:", amount)

func on_pickup(pickup_type: String, value: int) -> void:
	match pickup_type:
		"mushroom":
			if hud:
				hud.add_mushroom(value)
		"coin":
			add_coins(value)
		"health":
			apply_heal(value)
		_:
			print("Unknown pickup:", pickup_type, value)
