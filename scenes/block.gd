extends StaticBody2D

@export var item_scene: PackedScene
@export var one_shot: bool = true
@export var respawn_time: float = 5.0
@export var give_if_empty: bool = true

var sprite: AnimatedSprite2D
var bump_detector: Area2D
var spawn_point: Node2D
var reset_timer: Timer

var used: bool = false
var spawned_item: Node = null

func _ready() -> void:
	sprite = $Sprite if has_node("Sprite") else null
	bump_detector = $BumpDetector if has_node("BumpDetector") else null
	spawn_point = $SpawnPoint if has_node("SpawnPoint") else null
	reset_timer = $ResetTimer if has_node("ResetTimer") else null

	if reset_timer:
		reset_timer.one_shot = true
		reset_timer.wait_time = respawn_time
		reset_timer.connect("timeout", Callable(self, "_on_reset_timeout"))

	if is_instance_valid(bump_detector):
		bump_detector.connect("body_entered", Callable(self, "_on_bump_detector_body_entered"))

func _on_bump_detector_body_entered(body: Node) -> void:
	if used and one_shot:
		return
	if not body:
		return
	if not body.is_in_group("player"):
		return
	var player_vel := Vector2.ZERO
	if body.has_method("get_velocity"):
		player_vel = body.get_velocity()
	elif "velocity" in body:
		player_vel = body.velocity
	var valid_bump := player_vel.y < -40.0
	if not valid_bump:
		return
	_on_bump()

func _on_bump() -> void:
	if sprite:
		if sprite.has_animation("bump"):
			sprite.play("bump")
		elif sprite.has_animation("used") and one_shot:
			sprite.play("used")
	if item_scene and (not used or not one_shot or give_if_empty):
		_spawn_item()
	if one_shot:
		used = true
		if sprite and sprite.has_animation("used"):
			sprite.play("used")
	else:
		if reset_timer:
			reset_timer.start()

func _spawn_item() -> void:
	if not item_scene:
		return
	var inst = item_scene.instantiate()
	inst.global_position = spawn_point.global_position if is_instance_valid(spawn_point) else global_position
	if inst.has_method("set_spawner"):
		inst.set_spawner(self)
	elif inst.has_meta("spawner"):
		inst.set("spawner", self)
	get_tree().current_scene.add_child(inst)
	spawned_item = inst

func on_item_taken() -> void:
	spawned_item = null
	if not one_shot and reset_timer:
		reset_timer.start()

func _on_reset_timeout() -> void:
	used = false
	if sprite and sprite.has_animation("idle"):
		sprite.play("idle")
