extends Control

signal tutorial_ended

var tween: Tween

func reset_tutorial() -> void:
	modulate = Color(1,1,1,1)

func _on_end_button_pressed() -> void:
	PrintUtility.print_info("User finished tutorial")
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1)
	await tween.finished
	tutorial_ended.emit()
