extends Control
## Menú principal: nueva partida, continuar, salir.

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_CENTER)
	layout.grow_horizontal = Control.GROW_DIRECTION_BOTH
	layout.grow_vertical = Control.GROW_DIRECTION_BOTH
	layout.custom_minimum_size = Vector2(220, 0)
	layout.add_theme_constant_override("separation", 12)
	add_child(layout)

	var title := Label.new()
	title.text = "TEMPLO ELEMENTAL"
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "RPG retro d20 - proyecto personal"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.7, 0.7, 0.75)
	layout.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	layout.add_child(spacer)

	var new_game_btn := Button.new()
	new_game_btn.text = "Nueva Partida"
	new_game_btn.pressed.connect(_on_new_game_pressed)
	layout.add_child(new_game_btn)

	var continue_btn := Button.new()
	continue_btn.text = "Continuar"
	continue_btn.disabled = not SaveSystem.has_save()
	continue_btn.pressed.connect(_on_continue_pressed)
	layout.add_child(continue_btn)

	var quit_btn := Button.new()
	quit_btn.text = "Salir"
	quit_btn.pressed.connect(_on_quit_pressed)
	layout.add_child(quit_btn)


func _on_new_game_pressed() -> void:
	GameManager.new_game()


func _on_continue_pressed() -> void:
	if SaveSystem.load_game():
		GameManager.begin_adventure()


func _on_quit_pressed() -> void:
	get_tree().quit()
