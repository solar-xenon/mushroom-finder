extends CharacterBody2D

@export var speed: float = 80.0
@export var gravity: float = 900.0
@export var max_fall_speed: float = 900.0
@export var health: int = 3

var vel: Vector2 = Vector2.ZERO
var facing_right: bool = true

# Node refs
var anim: AnimatedSprite2D
var front: RayCast2D
var collision_shape: CollisionShape2D

# Tuning
const FRONT_ORIGIN = Vector2(8, 8)
const FRONT_TARGET_X = 14
const FRONT_TARGET_Y = 12
const IGNORE_CLOSE_DIST = 6.0

func _ready() -> void:
	anim = get_node_or_null("AnimatedSprite") as AnimatedSprite2D
	front = get_node_or_null("FrontCheck") as RayCast2D
	collision_shape = get_node_or_null("CollisionShape2D")

	if front:
		front.enabled = true
		front.position = FRONT_ORIGIN
		_update_front_target()
		front.add_exception(self)
		front.collision_mask = 1

	var headbox = get_node_or_null("Headbox")
	if headbox:
		headbox.connect("body_entered", Callable(self, "_on_headbox_entered"))

	var hurtbox = get_node_or_null("Hurtbox")
	if hurtbox:
		hurtbox.connect("body_entered", Callable(self, "_on_hurtbox_entered"))

	_play_animation("walk")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		vel.y = min(vel.y + gravity * delta, max_fall_speed)
	else:
		vel.y = 0.0

	var dir: int = 1 if facing_right else -1
	vel.x = speed * dir

	velocity = vel
	move_and_slide()

	if not _is_block_in_front():
		_flip_direction()

	_play_animation("walk")
	_update_sprite_flip()

func _is_block_in_front() -> bool:
	if not front or not front.is_colliding():
		return false
	var hit_pos = front.get_collision_point()
	var dist = hit_pos.distance_to(global_position)
	return dist >= IGNORE_CLOSE_DIST

func _flip_direction() -> void:
	facing_right = not facing_right
	_update_front_target()
	_update_sprite_flip()

func _update_front_target() -> void:
	if front:
		front.target_position = Vector2(FRONT_TARGET_X, FRONT_TARGET_Y) if facing_right else Vector2(-FRONT_TARGET_X, FRONT_TARGET_Y)

func _update_sprite_flip() -> void:
	if anim:
		anim.flip_h = not facing_right

func _play_animation(anim_name: String) -> void:
	if anim and anim.animation != anim_name:
		anim.animation = anim_name
		anim.play()

func apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_die()
	else:
		_play_animation("hurt")
		vel.y = -120

func _die() -> void:
	_play_animation("death")
	if collision_shape:
		collision_shape.disabled = true
	await get_tree().create_timer(0.4).timeout
	queue_free()

#  Stomp detection
func _on_headbox_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("bounce"):
			body.bounce()
		_die()

#  Damage detection
func _on_hurtbox_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("apply_damage"):
			body.apply_damage(1)
