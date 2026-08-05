extends Node2D
## Silueta dibujada por código (sin assets externos) para distinguir a cada
## personaje y enemigo. Estilo "pixel art por bloques": formas rectangulares
## planas con contorno oscuro y pocos detalles (ojos, cinturón, banda de
## pelo/capucha) en vez de curvas suaves, inspirado en la estética retro de
## los JRPG top-down clásicos — sin reutilizar ningún sprite ni paleta ajena,
## todo generado en tiempo real a partir de datos propios (raza/clase/monstruo).
## La raza define la silueta base (piel, altura, orejas, barba) y la clase
## define el atuendo y el accesorio; los monstruos usan formas propias
## (elemental/golem/humanoide encapuchado). Se dibuja en un espacio local de
## ~16x18 y se escala externamente según el contexto (mapa, combate).
class_name CreatureVisual

const METAL := Color(0.75, 0.76, 0.8)
const WOOD := Color(0.5, 0.32, 0.15)
const OUTLINE := Color(0.07, 0.06, 0.09)
const GOLD := Color(0.95, 0.85, 0.3)

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


## Dibuja un contorno oscuro (rect agrandado) detrás de "rect" antes de rellenarlo.
func _block(rect: Rect2, color: Color, outline_pad: float = 0.5) -> void:
	draw_rect(rect.grow(outline_pad), OUTLINE)
	draw_rect(rect, color)


func _draw_humanoid() -> void:
	var h: float = profile["height"]
	var w: float = profile["width"]
	var skin: Color = profile["skin"]
	var outfit: Color = profile["outfit"]
	var outfit_dark: Color = outfit.darkened(0.35)
	var hood: bool = profile.get("hood", false)

	var head_rect := Rect2(-3.6 * w, -17.0 * h, 7.2 * w, 6.5 * h)
	var body_rect := Rect2(-3.8 * w, -10.3 * h, 7.6 * w, 6.6 * h)
	var leg_gap := 1.0 * w
	var leg_l := Rect2(-3.2 * w, -3.9 * h, 3.2 * w - leg_gap * 0.5, 3.9 * h)
	var leg_r := Rect2(leg_gap * 0.5, -3.9 * h, 3.2 * w - leg_gap * 0.5, 3.9 * h)
	var arm_l := Rect2(-4.9 * w, -9.8 * h, 1.3 * w, 5.2 * h)
	var arm_r := Rect2(3.6 * w, -9.8 * h, 1.3 * w, 5.2 * h)

	_block(arm_l, skin.darkened(0.05))
	_block(arm_r, skin.darkened(0.05))
	_block(leg_l, outfit_dark)
	_block(leg_r, outfit_dark)
	_block(body_rect, outfit)
	_block(head_rect, skin)

	# Cinturón (franja inferior del torso)
	draw_rect(Rect2(body_rect.position.x, body_rect.end.y - 1.2 * h, body_rect.size.x, 1.2 * h), outfit_dark)

	# Banda de pelo/capucha (más ancha y oscura si lleva capucha)
	var band_frac: float = 0.75 if hood else 0.4
	var hair_color: Color = outfit.darkened(0.4) if hood else skin.darkened(0.55)
	draw_rect(Rect2(head_rect.position.x, head_rect.position.y, head_rect.size.x, head_rect.size.y * band_frac), hair_color)

	# Ojos
	var eye_y: float = head_rect.position.y + head_rect.size.y * 0.66
	draw_rect(Rect2(-2.1 * w, eye_y, 1.1 * w, 1.1 * h), OUTLINE)
	draw_rect(Rect2(1.0 * w, eye_y, 1.1 * w, 1.1 * h), OUTLINE)

	if profile.get("ear", "none") == "pointed":
		var ear_pts := PackedVector2Array([
			Vector2(head_rect.end.x - 0.4 * w, head_rect.position.y + head_rect.size.y * 0.3),
			Vector2(head_rect.end.x + 1.6 * w, head_rect.position.y - 0.6 * h),
			Vector2(head_rect.end.x - 0.4 * w, head_rect.position.y + head_rect.size.y * 0.55),
		])
		draw_colored_polygon(ear_pts, skin)
		draw_polyline(ear_pts, OUTLINE, 0.4, false)

	if profile.get("beard", false):
		draw_rect(Rect2(-1.8 * w, head_rect.end.y - 1.0 * h, 3.6 * w, 2.2 * h), Color(0.92, 0.92, 0.92))

	if profile.get("halo", false):
		var halo_r := 3.8 * w
		var halo_cy := -18.4 * h
		for i in range(8):
			var ang := TAU * i / 8.0
			var p := Vector2(cos(ang) * halo_r, halo_cy + sin(ang) * halo_r * 0.45)
			draw_rect(Rect2(p.x - 0.4 * w, p.y - 0.4 * w, 0.8 * w, 0.8 * w), GOLD)

	_draw_accessory(profile.get("accessory", "none"), h, w, outfit_dark)


func _draw_accessory(accessory: String, h: float, w: float, outfit_dark: Color) -> void:
	match accessory:
		"sword":
			_block(Rect2(5.7 * w, -11.2 * h, 0.9 * w, 7.4 * h), METAL, 0.3)
			draw_rect(Rect2(4.9 * w, -5.3 * h, 2.5 * w, 0.9 * h), WOOD)
		"staff":
			_block(Rect2(5.7 * w, -16.0 * h, 0.8 * w, 13.4 * h), WOOD, 0.25)
			_block(Rect2(4.7 * w, -17.4 * h, 2.6 * w, 2.6 * w), Color(0.55, 0.78, 1.0), 0.3)
		"bow":
			draw_rect(Rect2(6.4 * w, -10.2 * h, 0.8 * w, 2.2 * h), WOOD)
			draw_rect(Rect2(7.3 * w, -8.4 * h, 0.8 * w, 2.4 * h), WOOD)
			draw_rect(Rect2(6.4 * w, -6.4 * h, 0.8 * w, 2.2 * h), WOOD)
		"shield":
			var s := Rect2(4.6 * w, -10.6 * h, 3.2 * w, 5.4 * h)
			_block(s, METAL, 0.3)
			draw_rect(Rect2(s.position.x + 0.8 * w, s.position.y + 1.8 * h, s.size.x - 1.6 * w, 1.4 * h), outfit_dark)
		"holy_symbol":
			var cx := 0.0
			var cy := -18.0 * h
			draw_rect(Rect2(cx - 0.5 * w, cy - 1.7 * w, 1.0 * w, 3.4 * w), GOLD)
			draw_rect(Rect2(cx - 1.5 * w, cy - 0.5 * w, 3.0 * w, 1.0 * w), GOLD)
		"dagger":
			_block(Rect2(5.3 * w, -8.6 * h, 0.8 * w, 4.4 * h), METAL, 0.25)
		"trident":
			draw_rect(Rect2(5.7 * w, -16.0 * h, 0.8 * w, 13.4 * h), METAL)
			draw_rect(Rect2(4.6 * w, -16.4 * h, 0.8 * w, 1.6 * h), METAL)
			draw_rect(Rect2(6.8 * w, -16.4 * h, 0.8 * w, 1.6 * h), METAL)


func _draw_flame() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var base := PackedVector2Array([
		Vector2(-4.5 * w, 0), Vector2(4.5 * w, 0), Vector2(3.0 * w, -8.0 * h), Vector2(0, -6.0 * h), Vector2(-3.0 * w, -8.0 * h),
	])
	var mid := PackedVector2Array([
		Vector2(-3.0 * w, -6.0 * h), Vector2(3.0 * w, -6.0 * h), Vector2(1.6 * w, -12.5 * h), Vector2(0, -10.0 * h), Vector2(-1.6 * w, -12.5 * h),
	])
	var tip := PackedVector2Array([
		Vector2(-1.4 * w, -11.5 * h), Vector2(1.4 * w, -11.5 * h), Vector2(0, -16.5 * h),
	])
	draw_colored_polygon(base, accent)
	draw_polyline(base + PackedVector2Array([base[0]]), OUTLINE, 0.5, false)
	draw_colored_polygon(mid, primary)
	draw_colored_polygon(tip, Color(1.0, 0.9, 0.5))


func _draw_droplet() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var pts := PackedVector2Array()
	var segments := 12
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := PI + t * PI
		pts.append(Vector2(cos(angle) * 4.2 * w, -5.0 * h + sin(angle) * 4.2 * h))
	pts.append(Vector2(0, -14.0 * h))
	draw_colored_polygon(pts, primary)
	draw_polyline(pts + PackedVector2Array([pts[0]]), OUTLINE, 0.5, false)
	_block(Rect2(-1.8 * w, -6.9 * h, 1.6 * w, 1.6 * w), accent.lightened(0.3), 0.2)


func _draw_swirl() -> void:
	var primary: Color = profile["skin"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	var centers := [Vector2(0, -4.0 * h), Vector2(2.4 * w, -8.0 * h), Vector2(-2.0 * w, -10.5 * h), Vector2(1.6 * w, -13.5 * h)]
	var radii := [4.2, 3.4, 2.8, 2.0]
	for i in range(centers.size()):
		draw_circle(centers[i], radii[i] * w, Color(primary.r, primary.g, primary.b, 0.72))
		draw_arc(centers[i], radii[i] * w, 0, TAU, 16, Color(primary.r, primary.g, primary.b, 0.9), 0.4)


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
	draw_polyline(pts + PackedVector2Array([pts[0]]), OUTLINE, 0.5, false)
	draw_line(Vector2(-2.0 * w, -11.0 * h), Vector2(0.5 * w, -4.0 * h), accent, 0.6)
	draw_line(Vector2(4.2 * w, -9.5 * h), Vector2(1.0 * w, -6.0 * h), accent, 0.6)


func _draw_golem() -> void:
	var primary: Color = profile["skin"]
	var accent: Color = profile["outfit"]
	var h: float = profile["height"]
	var w: float = profile["width"]
	_block(Rect2(-5.5 * w, -12.0 * h, 4.0 * w, 12.0 * h), primary)
	_block(Rect2(1.5 * w, -12.0 * h, 4.0 * w, 12.0 * h), primary)
	_block(Rect2(-4.5 * w, -15.0 * h, 9.0 * w, 5.0 * h), primary.lightened(0.05))
	draw_rect(Rect2(-3.0 * w, -13.8 * h, 6.0 * w, 0.8 * h), accent)
	draw_rect(Rect2(-2.2 * w, -13.3 * h, 1.4 * w, 1.4 * w), accent)
	draw_rect(Rect2(0.8 * w, -13.3 * h, 1.4 * w, 1.4 * w), accent)
