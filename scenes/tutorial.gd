extends Control

signal tutorial_ended

@onready var tutorial_container = get_node("VBoxContainer/TutorialContainer")
@onready var tutorial_001 = get_node("VBoxContainer/TutorialContainer/Tutorial001_Intro")
@onready var tutorial_002 = get_node("VBoxContainer/TutorialContainer/Tutorial002")
@onready var tutorial_999 = get_node("VBoxContainer/TutorialContainer/Tutorial999_Outro")

@onready var previous_button = get_node("VBoxContainer/MarginContainer/CenterContainer/Buttons/PreviousButton")
@onready var next_button = get_node("VBoxContainer/MarginContainer/CenterContainer/Buttons/NextButton")

var tween: Tween
var page_index: int = -1
var page_count: int = -1

func _ready() -> void:
	# Initialize variables
	if page_count < 0:
		page_count = tutorial_container.get_child_count()
	if page_index < 0:
		page_index = 0
	
	update_visibility()
	update_controls()
	
	initialize_tuto_pages()

func initialize_tuto_pages() -> void:
	var tree = tutorial_002.get_node("FolderTree")
	var root = tree.create_item()
	root.set_text(0, "Ton dossier vidéo")
	
	var art_1: TreeItem = tree.create_item(root)
	art_1.set_text(0, "Artiste 1")
	var tmp_proj: TreeItem = tree.create_item(art_1)
	tmp_proj.set_text(0, "Projet 1")
	tmp_proj = tree.create_item(art_1)
	tmp_proj.set_text(0, "Projet 2")
	
	var art_2: TreeItem = tree.create_item(root)
	art_2.set_text(0, "Artiste 2")
	tmp_proj = tree.create_item(art_2)
	tmp_proj.set_text(0, "Projet 1")
	
	var art_3: TreeItem = tree.create_item(root)
	art_3.set_text(0, "Artiste 3")
	tmp_proj = tree.create_item(art_3)
	tmp_proj.set_text(0, "Projet 1")
	tmp_proj = tree.create_item(art_3)
	tmp_proj.set_text(0, "Projet 2")
	tmp_proj = tree.create_item(art_3)
	tmp_proj.set_text(0, "Projet 3")

func reset_tutorial() -> void:
	modulate = Color(1,1,1,1)
	page_index = 0
	page_count = tutorial_container.get_child_count()
	for c in tutorial_container.get_children():
		c.visible = false
	tutorial_001.visible = true

func update_visibility() -> void:
	for c in tutorial_container.get_children():
		c.visible = false
	tutorial_container.get_children()[page_index].visible = true

func update_controls() -> void:
	previous_button.visible = page_index > 0
	next_button.text = "Suivant" if page_index < page_count-1 else "Terminer"

func previous_tutorial_page() -> void:
	PrintUtility.print_info("User going to previous tutorial page : " + str(page_index-1))
	# Disable current page
	tutorial_container.get_children()[page_index].visible = false
	# Enable next page
	tutorial_container.get_children()[page_index-1].visible = true
	page_index -= 1

func next_tutorial_page() -> void:
	PrintUtility.print_info("User going to next tutorial page : " + str(page_index+1))
	# Disable current page
	tutorial_container.get_children()[page_index].visible = false
	# Enable next page
	tutorial_container.get_children()[page_index+1].visible = true
	page_index += 1

func end_tutorial() -> void:
	PrintUtility.print_info("User finished tutorial")
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1)
	await tween.finished
	PrintUtility.print_signal("Tutorial transition finished")
	tutorial_ended.emit()

func _on_previous_button_pressed() -> void:
	if page_index > 0: # Page is in range
		previous_tutorial_page()
	else: # Page not in range
		PrintUtility.print_error("Issue from tutorial._on_previous_button_pressed() : page is out of range, asked to go previous from page " + str(page_index))
	update_controls()

func _on_next_button_pressed() -> void:
	if page_index < page_count-1: # Not last page
		next_tutorial_page()
	else: # Last page
		end_tutorial()
	update_controls()
