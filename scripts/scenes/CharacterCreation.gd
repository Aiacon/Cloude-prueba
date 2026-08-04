extends Control
## Creación de personaje: nombre, raza, clase, tamaño de grupo (1-6) y tirada de
## atributos (4d6, se descarta el menor). El héroe lidera un grupo de hasta 6
## aventureros (se añaden compañeros predefinidos hasta completar el tamaño elegido).

var name_edit: LineEdit
var race_option: OptionButton
var class_option: OptionButton
var party_size_option: OptionButton
var stats_label: Label
var start_button: Button
var current_abilities: AbilityScores

const COMPANION_PRESETS := [
	{"name": "Kaelen", "race": "human", "class": "fighter", "abilities": [15, 13, 14, 10, 10, 8]},
	{"name": "Hermana Mora", "race": "dwarf", "class": "cleric", "abilities": [12, 10, 15, 10, 15, 10]},
	{"name": "Ithlyn", "race": "elf", "class": "wizard", "abilities": [8, 14, 12, 16, 12, 10]},
	{"name": "Pip", "race": "halfling", "class": "rogue", "abilities": [10, 16, 12, 12, 10, 12]},
	{"name": "Nayeli", "race": "half_elf", "class": "ranger", "abilities": [12, 16, 13, 10, 12, 10]},
	{"name": "Fray Bartolomé", "race": "human", "class": "paladin", "abilities": [15, 10, 14, 8, 12, 13]},
]


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_CENTER)
	layout.custom_minimum_size = Vector2(260, 0)
	layout.add_theme_constant_override("separation", 8)
	add_child(layout)

	var title := Label.new()
	title.text = "Crea tu Héroe"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Nombre del personaje"
	name_edit.text = "Aventurero"
	layout.add_child(name_edit)

	race_option = OptionButton.new()
	for race_id in RaceDB.ids():
		race_option.add_item(RaceDB.get_race(race_id)["name"])
	layout.add_child(race_option)

	class_option = OptionButton.new()
	for class_id in ClassDB.ids():
		class_option.add_item(ClassDB.get_class(class_id)["name"])
	layout.add_child(class_option)

	var party_size_label := Label.new()
	party_size_label.text = "Tamaño del grupo:"
	layout.add_child(party_size_label)

	party_size_option = OptionButton.new()
	for size in range(1, 7):
		party_size_option.add_item("%d aventureros" % size, size)
	party_size_option.select(3)  # 4 aventureros por defecto
	layout.add_child(party_size_option)

	var roll_button := Button.new()
	roll_button.text = "Tirar Atributos (4d6, descarta el menor)"
	roll_button.pressed.connect(_on_roll_pressed)
	layout.add_child(roll_button)

	stats_label = Label.new()
	stats_label.text = "Pulsa 'Tirar Atributos' para generar tu personaje."
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	layout.add_child(stats_label)

	start_button = Button.new()
	start_button.text = "Comenzar Aventura"
	start_button.disabled = true
	start_button.pressed.connect(_on_start_pressed)
	layout.add_child(start_button)

	_on_roll_pressed()


func _on_roll_pressed() -> void:
	current_abilities = AbilityScores.roll_full_array()
	stats_label.text = "FUE %d  DES %d  CON %d\nINT %d  SAB %d  CAR %d" % [
		current_abilities.strength, current_abilities.dexterity, current_abilities.constitution,
		current_abilities.intelligence, current_abilities.wisdom, current_abilities.charisma,
	]
	start_button.disabled = false


func _on_start_pressed() -> void:
	var race_id: String = RaceDB.ids()[race_option.selected]
	var class_id: String = ClassDB.ids()[class_option.selected]
	var hero_name: String = name_edit.text.strip_edges()
	if hero_name == "":
		hero_name = "Aventurero"
	var party_size: int = party_size_option.get_item_id(party_size_option.selected)

	var hero := Character.create_new(hero_name, race_id, class_id, current_abilities)
	GameManager.party = [hero]
	_add_companions(class_id, party_size)
	GameManager.begin_adventure()


## Completa el grupo hasta "party_size" miembros con compañeros predefinidos de las
## clases restantes (nunca duplica la clase elegida por el héroe).
func _add_companions(hero_class_id: String, party_size: int) -> void:
	for preset in COMPANION_PRESETS:
		if GameManager.party.size() >= party_size:
			break
		if preset["class"] == hero_class_id:
			continue
		_append_companion(preset)


func _append_companion(preset: Dictionary) -> void:
	var abilities_arr: Array = preset["abilities"]
	var abilities := AbilityScores.new(
		abilities_arr[0], abilities_arr[1], abilities_arr[2],
		abilities_arr[3], abilities_arr[4], abilities_arr[5]
	)
	var companion := Character.create_new(preset["name"], preset["race"], preset["class"], abilities)
	GameManager.party.append(companion)
