# Concept of the Brain

Videojuego 3D para Android en orientación horizontal. Proyecto desarrollado con **Godot 4.7.2 estable** y **GDScript**.

## Dirección visual

- Personajes 3D Low Poly.
- Entornos 3D modelados con estética retro inspirada en PS1/PS2.
- Atmósferas liminales, Dreamcore, Weirdcore y Backrooms.
- Referencias visuales: espacios cotidianos extraños, abandonados o surrealistas.

## Estado actual — Prototipo 0.1.0

La primera base técnica incluye:
- Escena 3D de prueba inspirada en la lavandería de la referencia visual.
- Axel como personaje inicial controlable. El modelo actual es un blockout geométrico Low Poly que deberá revisarse visualmente; no se considera el modelo final aprobado.
- Movimiento en tercera persona.
- Joystick virtual y botón de salto en pantallas táctiles.
- Controles de teclado para probar la escena en escritorio.
- Orientación horizontal y renderizador Mobile.
- Flujo de GitHub Actions para validar el proyecto y generar un APK de depuración.

Este escenario es un espacio de pruebas, no define la historia, las misiones ni el diseño definitivo de niveles.

## Abrir el proyecto

1. Instalar Godot **4.7.2 estable**.
2. Clonar o descargar este repositorio.
3. Abrir la carpeta raíz (donde está `project.godot`) desde Godot.
4. Ejecutar la escena principal.

El editor para Android está en acceso temprano y su interfaz táctil tiene limitaciones conocidas. Se recomienda guardar copias de seguridad y revisar cada cambio antes de continuar.

## Controles

- Android: joystick virtual a la izquierda y salto a la derecha.
- Teclado: WASD o flechas para moverse; espacio para saltar.

## Compilaciones

GitHub Actions valida la apertura del proyecto y genera un **APK de depuración** al actualizar `main` o ejecutar el workflow manualmente. El APK aparece como artefacto de la ejecución; no es todavía una versión firmada para distribución pública.

## Estructura

- `scenes/`: escenas del juego.
- `scripts/`: lógica de juego y construcción del prototipo.
- `scripts/ui/`: controles táctiles.
- `.github/workflows/`: automatización de validación y compilación.
