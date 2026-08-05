extends Node2D
## Silueta dibujada por código (sin assets externos) para distinguir a cada
## personaje y enemigo: la raza define la silueta base (piel, altura, orejas,
## barba) y la clase define el atuendo y el accesorio; los monstruos usan
## formas propias (elemental/golem/robado). Se dibuja en un espacio local de
## 16x16 y se escala externamente según el contexto (mapa, combate).
class_name CreatureVisual

const METAL := Color(0.75, 0.76, 0.8)
const DARK_OUTLINE := Color(0.05, 0.05, 0.08, 0.5)

var profile: Dictionary = {}


func configure(new_profile: Dictionary) -> void:
	profile = new_profile
	queue_redraw()


static func profile_for_character(character: Character) -> Dictionary:
	var race_visual: Dictionary = RaceDB.get_race(character.race_id).get("visual", {})
	var class_visual: Dictionary = CharClassDB.get_class_data(character.class_id).get("visual", {})
	return {
		"shape": "humanoid",
		"skin": race_visual.get("skin", Color(0.85, 0.7, 0.55)),
		"outfit": class_visual.get("outfit", Color(0.5, 0.5, 0.5)),
		"accessory": class_visual.get("accessory", "none"),
		"hood": class_visual.get("hood", false),
		"ear": race_visual.get("ear", "none"),
		"beard": race_visual.get("beard", false),
		"height": race_visual.get("height", 1.0),
		"width": race_visual.get("width", 1.0),
		"halo": false,
	}


static func profile_for_monster(monster_id: String) -> Dictionary:
	var visual: Dictionary = MonsterDB.get_monster(monster_id).get("visual", {})
	return {
		"shape": visual.get("shape", "humanoid"),
		"skin": visual.get("primary", Color(0.6, 0.6, 0.6)),
		"outfit": visual.get("accent", Color(0.4, 0.4, 0.4)),
		"accessory": visual.get("accessory", "none"),
		"hood": visual.get("hood", false),
		"ear": "none",
		"beard": false,
		"height": visual.get("height", 1.0),
		"width": visual.get("width", 1.0),
		"halo": visual.get("halo", false),
	}


static func profile_for_npc(npc_id: String) -> Dictionary:
	var visual: Dictionary = NpcDB.get_npc(npc_id).get("visual", {})
	return {
		"shape": "humanoid",
		"skin": visual.get("skin", Color(0.85, 0.7, 0.55)),
		"outfit": visual.get("outfit", Color(0.5, 0.5, 0.5)),
		"accessory": visual.get("accessory", "none"),
		"hood": visual.get("hood", false),
		"ear": "none",
		"beard": false,
		"height": 1.0,
		"width": 1.0,
		"halo": false,
	}


func _draw() -> void:
	if profile.is_empty():
		return
	match profile.get("shape", "humanoid"):
		"flame": _draw_flame()
		"droplet": _draw_droplet()
		"swirl": _draw_swirl()
		"rock": _draw_rock()
		"golem": _draw_golem()
		_: _draw_humanoid()


func _draw_humanoid() -> void:
	var h: float = profile["height"]
	var w: float = profile["width"]
	var skin: Color = profile["skin"]
	var outfit: Color = profile["outfit"]

	# Piernas
	draw_rect(Rect2(-3.0 * w, -4.0 * h, 2.4 * w, 4.0 * h), outfit.darkened(0.3))
	draw_rect(Rect2(0.6 * w, -4.0 * h, 2.4 * w, 4.0 * h), outfit.darkened(0.3))

	# Torso
	var torso := Rect2(-3.6 * w, -10.0 * h, 7.2 * w, 6.5 * h)
	draw_rect(torso, outfit)
	draw_rect(torso, DARK_OUTLINE, false, 0.6)

	# Brazos
	draw_rect(Rect2(-5.0 * w, -9.5 * h, 1.6 * w, 5.0 * h), skin.darkened(0.1))
	draw_rect(Rect2(3.4 * w, -9.5 * h, 1.6 * w, 5.0 * h), skin.darkened(0.1))

	# Cabeza
	var head_center := Vector2(0, -13.0 * h)
	var head_radius := 3.1 * w
	draw_circle(head_center, head_radius, skin)

	if profile.get("ear", "none") == "pointed":
		var ear_points := PackedVector2Array([
			Vector2(head_radius * 0.7, -13.0 * h - 0.5),
			Vector2(head_radius * 1.9, -13.0 * h - 2.2 * h),
			Vector2(head_radius * 0.5, -13.0 * h + 1.0),
		])
		draw_colored_polygon(ear_points, skin)

	if profile.get("beard", false):
		draw_rect(Rect2(-1.6 * w, -11.2 * h, 3.2 * w, 2.0 * h), Color(0.9, 0.9, 0.9))

	if profile.get("hood", false):
		var hood_points := PackedVector2Array([
			Vector2(-4.0 * w, -16.0 * h),
			Vector2(4.0 * w, -16.0 * h),
			Vector2(3.2 * w, -11.0 * h),
			Vector2(-3.2 * w, -11.0 * h),
		])
		draw_colored_polygon(hood_points, outfit.darkened(0.35))

	if profile.get("halo", false):
		draw_arc(Vector2(0, -17.0 * h), 3.4 * w, 0, TAU, 24, Color(0.95, 0.85, 0.3), 0.8)

	_draw_accessory(profile.get("accessory", "none"), h, w)


func _draw_accessory(accessory: String, h: float, w: float) -> void:
	match accessory:
		"sword":
			draw_line(Vector2(5.0 * w, -11.0 * h), Vector2(8.0 * w, -2.0 * h), METAL, 1.4)
			draw_line(Vector2(6.1 * w, -8.6 * h), Vector2(7.3 * w, -9.6 * h), Color(0.55, 0.35, 0.15), 1.2)
		"staff":
			draw_line(Vector2(6.0 * w, -16.0 * h), Vector2(6.0 * w, -2.0 * h), Color(0.5, 0.32, 0.15), 1.2)
			draw_circle(Vector2(6.0 * w, -16.5 * h), 1.6 * w, Color(0.5, 0.75, 1.0, 0.85))
		"bow":
			draw_arc(Vector2(6.5 * w, -7.0 * h), 4.5 * w, -PI * 0.4, PI * 0.4, 12, Color(0.5, 0.32, 0.15), 1.0)
		"shield":
			draw_rect(Rect2(4.5 * w, -10.5 * h, 3.4 * w, 5.5 * h), METAL)
			draw_rect(Rect2(4.5 * w, -10.5 * h, 3.4 * w, 5.5 * h), profile["outfit"].darkened(0.2), false, 0.6)
		"holy_symbol":
			var c := Vector2(0, -17.2 * h)
			draw_circle(c, 1.3 * w, Color(0.95, 0.85, 0.3))
			draw_line(c + Vector2(0, -1.6 * w), c + Vector2(0, 1.6 * w), Color(0.95, 0.85, 0.3), 0.7)
			draw_line(c + Vector2(-1.2 * w, 0), c + Vector2(1.2 * w, 0), Color(0.95, 0.85, 0.3), 0.7)
		"dagger":
			draw_line(Vector2(5.0 * w, -9.0 * h), Vector2(7.0 * w, -4.0 * h), METAL, 1.1)
		"trident":
			draw_line(Vector2(6.0 * w, -16.0 * h), Vector2(6.0 * w, -2.0 * h), METAL, 1.1)
			draw_line(Vector2(6.0 * w, -16.0 * h), Vector2(4.6 * w, -14.0 * h), METAL, 0.8)
			draw_line(Vector2(6.0 * w, -16.0 * h), Vector2(7.4 * w, -14.0 * h), METAL, 0.8)


func _draw_flame() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4.5 * w, 0), Vector2(4.5 * w, 0), Vector2(3.0 * w, -8.0 * h), Vector2(0, -6.0 * h), Vector2(-3.0 * w, -8.0 * h),
	]), accent)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3.0 * w, -6.0 * h), Vector2(3.0 * w, -6.0 * h), Vector2(1.6 * w, -12.5 * h), Vector2(0, -10.0 * h), Vector2(-1.6 * w, -12.5 * h),
	]), primary)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-1.4 * w, -11.5 * h), Vector2(1.4 * w, -11.5 * h), Vector2(0, -16.5 * h),
	]), Color(1.0, 0.9, 0.5))


func _draw_droplet() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var pts := PackedVector2Array()
	var segments := 16
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := PI + t * PI
		pts.append(Vector2(cos(angle) * 4.2 * w, -5.0 * h + sin(angle) * 4.2 * h))
	pts.append(Vector2(0, -14.0 * h))
	draw_colored_polygon(pts, primary)
	draw_circle(Vector2(-1.2 * w, -6.0 * h), 1.0 * w, accent.lightened(0.3))


func _draw_swirl() -> void:
	var primary: Color = profile["skin"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var centers := [Vector2(0, -4.0 * h), Vector2(2.4 * w, -8.0 * h), Vector2(-2.0 * w, -10.5 * h), Vector2(1.6 * w, -13.5 * h)]
	var radii := [4.2, 3.4, 2.8, 2.0]
	for i in range(centers.size()):
		draw_circle(centers[i], radii[i] * w, Color(primary.r, primary.g, primary.b, 0.72))


func _draw_rock() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var pts := PackedVector2Array([
		Vector2(-4.6 * w, 0), Vector2(-5.0 * w, -6.0 * h), Vector2(-2.0 * w, -11.0 * h),
		Vector2(1.0 * w, -14.0 * h), Vector2(4.2 * w, -9.5 * h), Vector2(5.0 * w, -3.5 * h),
		Vector2(2.5 * w, 0),
	])
	draw_colored_polygon(pts, primary)
	draw_line(Vector2(-2.0 * w, -11.0 * h), Vector2(0.5 * w, -4.0 * h), accent, 0.6)
	draw_line(Vector2(4.2 * w, -9.5 * h), Vector2(1.0 * w, -6.0 * h), accent, 0.6)


func _draw_golem() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	draw_rect(Rect2(-5.5 * w, -12.0 * h, 4.0 * w, 12.0 * h), primary)
	draw_rect(Rect2(1.5 * w, -12.0 * h, 4.0 * w, 12.0 * h), primary)
	draw_rect(Rect2(-4.5 * w, -15.0 * h, 9.0 * w, 5.0 * h), primary.lightened(0.05))
	draw_line(Vector2(-3.0 * w, -13.5 * h), Vector2(3.0 * w, -13.5 * h), accent, 0.7)
	draw_circle(Vector2(-1.6 * w, -13.0 * h), 0.7 * w, accent)
	draw_circle(Vector2(1.6 * w, -13.0 * h), 0.7 * w, accent)
