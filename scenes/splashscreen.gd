extends Control

var tween: Tween

func _ready() -> void:
	get_node("VBoxContainer/VersionLabel").text = "Version " + ProjectSettings.get_setting("application/config/version")
	if tween:
		tween.kill()
	
	if OS.has_feature("editor"):
		enable(false)
	elif OS.has_feature("release") or OS.has_feature("debug"):
		enable(true)
		tween = get_tree().create_tween()
		tween.finished.connect(_on_tween_finished)
		tween.tween_interval(3)
		tween.tween_property(self, "modulate", Color(1,1,1,0), 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if tween:
				tween.kill()
			enable(false)

func _on_tween_finished() -> void:
	enable(false)

func enable(value: bool) -> void:
	if value:
		modulate = Color(1,1,1,1)
		mouse_filter = Control.MOUSE_FILTER_STOP
		visible = true
	else:
		modulate = Color(1,1,1,0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false
