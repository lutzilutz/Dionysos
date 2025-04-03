@tool
class_name TabButton extends MarginContainer

signal ask_tab_change(type)

enum TabType {
	FOLDER_MANAGER,
	USER_MANAGER
}

var folder_texture: Texture2D = preload("res://resources/icons/folder_64.png")
var user_texture: Texture2D = preload("res://resources/icons/user_64.png")

@onready var texture_button = get_node("MarginContainer/TextureButton")

@export var tab_type: TabType = TabType.FOLDER_MANAGER: set = set_tab_type
var is_selected: bool = false

func _ready() -> void:
	update_textures()

func set_tab_type(new_type: TabType) -> void:
	tab_type = new_type
	update_textures()

func update_textures() -> void:
	if texture_button != null:
		match tab_type:
			TabType.FOLDER_MANAGER:
				texture_button.texture_normal = folder_texture
			TabType.USER_MANAGER:
				texture_button.texture_normal = user_texture

func _on_texture_button_pressed() -> void:
	ask_tab_change.emit(tab_type)

func change_is_selected(new_selected: bool) -> void:
	is_selected = new_selected
	if new_selected:
		modulate = Color.html("#657f93")
	else:
		modulate = Color.html("#273540")
