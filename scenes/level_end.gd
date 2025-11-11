extends Area2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("Level complete! Transitioning to end credits...")
		get_tree().change_scene_to_file("res://scenes/end_credits.tscn")  
