# Templo Elemental

RPG retro por turnos para Android, inspirado en **D&D 3.5** (reglas basadas en
el SRD/OGL de libre uso) y ambientado en un templo dedicado a los cuatro
elementos. Proyecto **personal / no comercial** — no reutiliza texto, mapas ni
arte de ningún módulo con copyright; la ambientación (nombres de salas,
NPC, enemigos, trama) es original.

Construido con **[Godot 4.3+](https://godotengine.org/)**, con gráficos
retro generados por código (bloques de color, sin dependencias de arte
externo) y pensado para exportarse a Android en **arquitectura de 32 bits
(armeabi-v7a)**.

## Características implementadas

- **Motor de reglas D&D 3.5**: características (FUE/DES/CON/INT/SAB/CAR),
  modificadores, Bonificador Base de Ataque, salvaciones (Fortaleza/Reflejos/
  Voluntad), Clase de Armadura, tiradas de dados (`XdY+Z`), ataques
  críticos y ataque furtivo del pícaro — **todas las tiradas se muestran
  desglosadas** en el registro de combate (`d20(14)+6 = 20 vs CA 17`).
- **Progresión de nivel 1 a 30** (incluye rango épico 21-30): tabla de XP
  acumulada oficial, dotes cada 3 niveles (+ dotes de bonificación de
  Guerrero), incremento de característica cada 4 niveles.
- **7 razas núcleo** del Manual del Jugador (Humano, Elfo, Enano, Mediano,
  Semielfo, Semiorco, Gnomo) y **6 clases** (Guerrero, Clérigo, Mago,
  Pícaro, Explorador, Paladín).
- **~30 dotes** con prerrequisitos, asignadas automáticamente al subir de
  nivel según la clase.
- **Sistema de conjuros** (Clérigo/Mago/Paladín/Explorador) con conjuros de
  nivel 0 a 9 y progresión de nivel de conjurador fiel al SRD; se lanzan
  gastando **Puntos de Maná** de una reserva diaria (ver nota abajo).
- **Equipo mágico**: armas y armaduras +1/+2/+3, anillos, objetos
  maravillosos, varitas y pergaminos.
- **Creación de personaje** con tirada de atributos (4d6, se descarta el
  menor) y **grupo de 1 a 6 aventureros** (héroe + compañeros de las 6
  clases disponibles).
- **NPC con misiones**: una historia principal de 6 capítulos concatenados
  a través de las 4 alas del templo (dada por el Hermano Ismael) más una
  misión secundaria opcional, con diálogos y recompensas.
- **Pueblo (hub)** inicial con NPC, conectado al Templo Elemental (vestíbulo
  + 4 alas elementales + cámara final).
- **Combate por turnos** con iniciativa (d20 + DES), ataque, conjuros,
  pociones y huida.
- **Recompensas por enemigo**: XP, oro y tabla de botín con probabilidad de
  caída por objeto (incluye objetos mágicos).
- **Guardado/carga** de partida en JSON (`user://`), compatible con Android.
- Todos los textos en **español latinoamericano** neutro.

## Simplificaciones deliberadas (para mantener el proyecto jugable y verificable)

- **Conjuros**: en vez de espacios independientes por nivel de conjuro (regla
  completa del SRD), cada conjurador tiene una reserva de **Puntos de Maná**
  (variante "spell points" de *Unearthed Arcana*) que gasta según el nivel
  del conjuro (costo = `2×nivel-1`, mínimo 1) en cualquier conjuro que
  conozca hasta su nivel máximo. Se descansa con el botón **Descansar**
  (recupera PG y Puntos de Maná).
- **Dotes/conjuros/objetos mágicos**: se implementó un conjunto amplio y
  representativo del SRD (no las ~1000+ entradas completas), sobre una
  arquitectura de datos (`FeatDB`, `SpellDB`, `MagicItemDB`) pensada para
  ampliarse fácilmente.
- **Sin pantalla de inventario/equipo manual todavía**: las pociones se usan
  automáticamente desde el combate y el equipo mágico obtenido como botín se
  autoequipa en el líder del grupo.

## Estructura del proyecto

```
project.godot
autoload/              GameManager (estado global), EventBus (señales)
scripts/rules/          Motor de reglas: Dice, AbilityScores, RaceDB, ClassDB,
                         SkillDB, FeatDB, ProgressionDB, Character, CombatEngine
scripts/data/            Contenido: MonsterDB, ItemDB, MagicItemDB, SpellDB,
                         NpcDB, QuestDB, LevelData (mapas)
scripts/systems/         Inventory, SaveSystem
scripts/world/           DungeonBuilder (mapa retro por bloques + NPC), Player
scripts/scenes/          Lógica de cada escena jugable
scenes/                  MainMenu, CharacterCreation, Dungeon, Combat (.tscn)
export_presets.cfg       Preset de exportación Android (32-bit / armeabi-v7a)
```

## Cómo abrir y probar el proyecto

1. Instala [Godot 4.3 o superior](https://godotengine.org/download).
2. Abre Godot → *Import* → selecciona la carpeta del repositorio
   (`project.godot`).
3. Pulsa ▶ (F5) para jugar. Los controles de teclado (flechas) funcionan
   para probar en escritorio; en Android se usa el D-pad táctil en pantalla.
4. Flujo recomendado: Nueva Partida → crea tu héroe y elige tamaño de grupo
   → hablas con el Alcalde en la Plaza del Pueblo (misión inicial) → entras
   al Templo Elemental → hablas con el Hermano Ismael para las siguientes
   misiones de la cadena principal.

## Cómo exportar el APK (32-bit) a Android

1. En Godot: *Editor → Editor Settings → Export → Android* y configura la
   ruta del Android SDK (o usa el gestor de plantillas integrado).
2. Instala las **plantillas de exportación** de Godot correspondientes a tu
   versión (*Editor → Manage Export Templates*).
3. *Project → Export...* → se detectará el preset **"Android (32-bit)"**
   incluido en `export_presets.cfg` (arquitectura `armeabi-v7a` únicamente,
   sin `arm64-v8a`, para mantener ese perfil "retro").
4. Genera/asigna un *keystore* de depuración o de publicación y pulsa
   **Export Project**.

## Aviso de propiedad intelectual

Este proyecto usa **mecánicas de juego tipo d20** equivalentes a las
publicadas bajo la *Open Game License* (SRD 3.5), que son de uso libre.
**No** incluye texto, mapas, arte ni contenido narrativo protegido de ningún
módulo comercial (como *Temple of Elemental Evil*, propiedad de Wizards of
the Coast) — la ambientación, nombres propios, NPC, misiones y diseño de
niveles de este repositorio son originales. Uso personal y no comercial.

## Próximos pasos sugeridos

- Pantalla de inventario/equipo manual (elegir qué arma/armadura/anillo
  llevar puesto, usar varitas y pergaminos desde combate).
- Más dotes, conjuros y objetos mágicos (la arquitectura ya lo soporta).
- Arte pixel-art real (actualmente son bloques de color como placeholder).
- Sonidos y música retro (chiptune).
