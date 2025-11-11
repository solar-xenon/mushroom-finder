extends CanvasLayer

func _on_start_game_pressed() -> void:
	print("Start button pressed!")
	get_tree().change_scene_to_file("res://levels/level_1_1.tscn")
