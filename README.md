# Templo Elemental

RPG retro por turnos para Android, inspirado en **D&D 3.5** (reglas basadas en
el SRD/OGL de libre uso) y ambientado en un templo dedicado a los cuatro
elementos. Proyecto **personal / no comercial** — no reutiliza texto, mapas ni
arte de ningún módulo con copyright; la ambientación (nombres de salas,
NPC, enemigos, trama) es original.

Construido con **[Godot 4.3+](https://godotengine.org/)** (GDScript). Exporta
a **Android (32-bit)** y a **Web (HTML5)** — jugable desde cualquier
navegador, en cualquier dispositivo, sin instalar nada.

Estilo visual inspirado en los JRPG top-down de la era GBA (Pokémon Rubí):
mapa por rejilla + pantalla de combate dedicada con sprites de cada
combatiente. Los "sprites" son **siluetas dibujadas por código**
(`CreatureVisual.gd`) en vez de pixel-art importado: cada raza aporta
silueta/tono de piel, cada clase aporta atuendo + accesorio (espada, bastón,
arco, escudo, símbolo sagrado...), y cada monstruo tiene su propia forma
(humanoide encapuchado, elemental de llama, gota, remolino, roca, gólem).
Es un paso intermedio honesto entre bloques de color planos y pixel-art real
— no reemplaza arte hecho a mano, pero cada personaje y enemigo ya se
distingue a simple vista.

## Características implementadas

- **Siluetas distinguibles por código**: cada combinación raza+clase (49
  posibles) y cada uno de los 9 monstruos tiene su propia silueta/paleta,
  generadas con `CreatureVisual.gd` — sin depender de sprites importados.
  Pantalla de combate estilo JRPG clásico: enemigos arriba-derecha, grupo
  abajo-izquierda, sobre un fondo con el tinte del elemento de la sala.
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
scripts/rules/          Motor de reglas: Dice, AbilityScores, RaceDB,
                         CharClassDB, SkillDB, FeatDB, ProgressionDB,
                         Character, CombatEngine
scripts/data/            Contenido: MonsterDB, ItemDB, MagicItemDB, SpellDB,
                         NpcDB, QuestDB, LevelData (mapas)
scripts/systems/         Inventory, SaveSystem
scripts/world/           DungeonBuilder (mapa por bloques + siluetas), Player,
                         CreatureVisual (siluetas dibujadas por código)
scripts/scenes/          Lógica de cada escena jugable
scenes/                  MainMenu, CharacterCreation, Dungeon, Combat (.tscn)
export_presets.cfg       Presets de exportación: Android (32-bit) y Web
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

El preset usa exportación "rápida" (`gradle_build/use_gradle_build=false`):
no hace falta un proyecto Gradle/Android Studio completo, pero **sigue
haciendo falta un Android SDK local** (Godot usa `apksigner`/`zipalign` de
las *build-tools* para firmar y alinear el APK).

1. Instala un Android SDK: la forma más simple es instalar **Android Studio**
   (trae el SDK Manager con todo lo necesario), o si solo quieres las
   herramientas de línea de comandos, descarga las *command line tools* desde
   https://developer.android.com/studio#command-tools e instala al menos
   `platform-tools` y `build-tools` con `sdkmanager`.
2. En Godot: *Editor → Editor Settings → Export → Android* y apunta **Android
   SDK Path** a esa instalación.
3. Instala las **plantillas de exportación** de Godot correspondientes a tu
   versión (*Editor → Manage Export Templates*).
4. *Project → Export...* → se detectará el preset **"Android (32-bit)"**
   incluido en `export_presets.cfg` (arquitectura `armeabi-v7a` únicamente,
   sin `arm64-v8a`, para mantener ese perfil "retro"), genera/asigna un
   *keystore* de depuración o de publicación, y pulsa **Export Project**.

## Cómo exportar a Web (jugable en cualquier dispositivo)

Esta es la forma más simple de compartir el juego: no requiere Android SDK
ni ninguna herramienta adicional, solo las plantillas de exportación Web.

1. *Editor → Manage Export Templates* → instala las de tu versión de Godot.
2. *Project → Export...* → preset **"Web"** (ya incluido en
   `export_presets.cfg`) → **Export Project** → genera una carpeta
   `builds/web/` con `index.html` y los archivos del juego.
3. Para probarlo localmente hace falta servirlo por HTTP (no `file://`, los
   navegadores bloquean WebAssembly así): por ejemplo
   `cd builds/web && python3 -m http.server 8060` y abrí
   `http://localhost:8060` en el navegador.
4. Para publicarlo, subí la carpeta `builds/web/` completa a cualquier
   hosting estático (itch.io, GitHub Pages, Netlify, etc.).

## Aviso de propiedad intelectual

Este proyecto usa **mecánicas de juego tipo d20** equivalentes a las
publicadas bajo la *Open Game License* (SRD 3.5), que son de uso libre.
**No** incluye texto, mapas, arte ni contenido narrativo protegido de ningún
módulo comercial (como *Temple of Elemental Evil*, propiedad de Wizards of
the Coast) — la ambientación, nombres propios, NPC, misiones y diseño de
niveles de este repositorio son originales. Uso personal y no comercial.
El estilo visual toma como referencia la *convención de layout* de los JRPG
top-down de la era GBA (mapa por rejilla + pantalla de batalla dedicada) —
no reutiliza ningún sprite, paleta ni asset de Pokémon; todas las siluetas
son generadas por código (`CreatureVisual.gd`).

## Próximos pasos sugeridos

- Pantalla de inventario/equipo manual (elegir qué arma/armadura/anillo
  llevar puesto, usar varitas y pergaminos desde combate).
- Más dotes, conjuros y objetos mágicos (la arquitectura ya lo soporta).
- Arte pixel-art real hecho a mano o un pack de sprites con licencia libre
  (CC0), reemplazando las siluetas por código donde se busque más detalle
  visual (expresiones faciales, animaciones de ataque, etc.).
- Sonidos y música retro (chiptune).
