extends Control

signal tutorial_ended

@onready var tutorial_container = get_node("TutorialContainer")
@onready var tutorial_001 = get_node("TutorialContainer/Tutorial001_Intro")
@onready var tutorial_002 = get_node("TutorialContainer/Tutorial002")

var tween: Tween
var page_index: int = -1
var page_count: int = -1

func _ready() -> void:
	# Initialize variables
	if page_count < 0:
		page_count = tutorial_container.get_child_count()
	if page_index < 0:
		page_index = 0
	# Connect buttons
	for c in tutorial_container.get_children():
		c.get_node("NextButton").pressed.connect(_on_next_button)
	# Update visibility
	for c in tutorial_container.get_children():
		c.visible = false
	tutorial_001.visible = true

func _on_next_button() -> void:
	if page_index < page_count-1: # Not last page
		next_tutorial_page()
	else:
		end_tutorial()

func reset_tutorial() -> void:
	modulate = Color(1,1,1,1)
	page_index = 0
	page_count = tutorial_container.get_child_count()
	for c in tutorial_container.get_children():
		c.visible = false
	tutorial_001.visible = true

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
