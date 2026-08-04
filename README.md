# Templo Elemental

RPG retro por turnos para Android, inspirado en **D&D 3.5** (reglas basadas en
el SRD/OGL de libre uso) y ambientado en un templo dedicado a los cuatro
elementos. Proyecto **personal / no comercial** — no reutiliza texto, mapas ni
arte de ningún módulo con copyright; la ambientación (nombres de salas,
enemigos, trama) es original.

Construido con **[Godot 4.3+](https://godotengine.org/)**, con gráficos
retro generados por código (bloques de color, sin dependencias de arte
externo) y pensado para exportarse a Android en **arquitectura de 32 bits
(armeabi-v7a)**.

## Características implementadas

- **Motor de reglas D&D 3.5 simplificado**: características (FUE/DES/CON/
  INT/SAB/CAR), modificadores, Bonificador Base de Ataque, salvaciones
  (Fortaleza/Reflejos/Voluntad), Clase de Armadura, tiradas de dados
  (`XdY+Z`), ataques críticos y ataque furtivo del pícaro.
- **4 razas** (Humano, Elfo, Enano, Mediano) y **4 clases** (Guerrero,
  Clérigo, Mago, Pícaro) con progresiones de BAB/salvaciones fieles al SRD.
- **Creación de personaje** con tirada de atributos (4d6, se descarta el
  menor) y grupo de hasta 4 aventureros (héroe + compañeros).
- **Exploración por rejilla** estilo RPG clásico, con las 4 alas elementales
  (Fuego, Agua, Aire, Tierra) conectadas a un vestíbulo central, y una
  cámara final que requiere las 4 llaves elementales.
- **Combate por turnos** con iniciativa (d20 + DES), selección de objetivo,
  uso de pociones, huida y experiencia/nivel al vencer.
- **Guardado/carga** de partida en JSON (`user://`), compatible con Android.

## Estructura del proyecto

```
project.godot
autoload/            GameManager (estado global), EventBus (señales)
scripts/rules/        Motor de reglas D&D 3.5 (Dice, AbilityScores, RaceDB,
                       ClassDB, SkillDB, Character, CombatEngine)
scripts/data/          Contenido: MonsterDB, ItemDB, LevelData (mapas)
scripts/systems/       Inventory, SaveSystem
scripts/world/         DungeonBuilder (mapa retro por bloques), Player
scripts/scenes/        Lógica de cada escena jugable
scenes/                 MainMenu, CharacterCreation, Dungeon, Combat (.tscn)
export_presets.cfg     Preset de exportación Android (32-bit / armeabi-v7a)
```

## Cómo abrir y probar el proyecto

1. Instala [Godot 4.3 o superior](https://godotengine.org/download).
2. Abre Godot → *Import* → selecciona la carpeta del repositorio
   (`project.godot`).
3. Pulsa ▶ (F5) para jugar. Los controles de teclado (flechas) funcionan
   para probar en escritorio; en Android se usa el D-pad táctil en pantalla.

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
the Coast) — la ambientación, nombres propios y diseño de niveles de este
repositorio son originales. Uso personal y no comercial.

## Próximos pasos sugeridos

- Sistema de conjuros para Clérigo/Mago (actualmente solo tienen daño
  cuerpo a cuerpo).
- Más dotes, objetos mágicos y una tienda en el vestíbulo.
- Arte pixel-art real (actualmente son bloques de color como placeholder).
- Sonidos y música retro (chiptune).
