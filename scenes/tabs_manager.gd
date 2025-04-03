extends VBoxContainer

signal ask_tab_change(type)

var active_tab: int = -1

func _ready() -> void:
	for c in get_children():
		c.ask_tab_change.connect(_on_tab_pressed)
	initialize_tabs(TabButton.TabType.FOLDER_MANAGER)

func _on_tab_pressed(type) -> void:
	if active_tab != type:
		go_to_tab(type)

func go_to_tab(new_tab: int) -> void:
	PrintUtility.print_info("Going from tab " + str(active_tab) + " to " + str(new_tab))
	for t: TabButton in get_children():
		if t.tab_type == active_tab:
			t.change_is_selected(false)
		elif t.tab_type == new_tab:
			t.change_is_selected(true)
	active_tab = new_tab
	ask_tab_change.emit(new_tab)

func initialize_tabs(new_type) -> void:
	for t: TabButton in get_children():
		if t.tab_type == new_type:
			t.change_is_selected(true)
		else:
			t.change_is_selected(false)
	active_tab = new_type
