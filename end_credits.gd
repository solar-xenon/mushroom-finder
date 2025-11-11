extends CanvasLayer

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_1_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
