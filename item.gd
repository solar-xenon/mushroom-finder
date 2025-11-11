extends Area2D

@export var pickup_type: String = "mushroom"  
@export var value: int = 1

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	match pickup_type:
		"coin":
			if body.has_method("add_coins"):
				body.add_coins(value)
		"health":
			if body.has_method("apply_heal"):
				body.apply_heal(value)
		"damage":
			if body.has_method("apply_damage"):
				body.apply_damage(value)
		_:
			if body.has_method("on_pickup"):
				body.on_pickup(pickup_type, value)

	queue_free()
