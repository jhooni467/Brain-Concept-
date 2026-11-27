# Concept of the Brain

Videojuego 3D para Android en orientación horizontal. Proyecto desarrollado con **Godot 4.7.2 estable** y **GDScript**.

## Dirección visual

- Personajes 3D Low Poly.
- Entornos 3D modelados con estética retro inspirada en PS1/PS2.
- Atmósferas liminales, Dreamcore, Weirdcore y Backrooms.
- Los primeros escenarios sirven como prototipos visuales y de jugabilidad; se podrán reemplazar y mejorar en etapas posteriores.

## Estado actual — Prototipo 0.1.0

La base técnica incluye:
- Proyecto 3D con renderizador Mobile y orientación horizontal.
- Axel como personaje inicial controlable. El modelo actual es un blockout geométrico Low Poly provisional; todavía no es un modelo final ni una réplica exacta de la referencia.
- Movimiento en tercera persona relativo a la orientación de la cámara.
- Cámara orbital: arrastre en la zona derecha de la pantalla para mirar a los lados y arriba/abajo.
- Joystick táctil de movimiento con opacidad visual del 10% y botón de salto.
- Controles de teclado y arrastre con botón derecho para pruebas en escritorio.
- Escenario provisional de lavandería con entrada, pasillo, ventanas, máquinas, zona de espera, mostrador, fregadero, cestos, máquina expendedora y luces de techo.
- Materiales y texturas procedurales sencillas para el suelo y las paredes, más iluminación ambiental y paneles luminosos.
- Flujo de GitHub Actions que valida el proyecto y genera un APK de depuración.

El escenario de lavandería es un espacio de pruebas; no fija la historia, las misiones ni el diseño final de los mundos.

## Controles

### Android
- Joystick: zona inferior izquierda.
- Cámara: arrastrar desde la mitad derecha de la pantalla, evitando el botón de salto.
- Saltar: botón de la esquina inferior derecha.

### Teclado y ratón
- WASD o flechas: moverse.
- Espacio: saltar.
- Mantener el botón derecho del ratón y arrastrar: mover la cámara.

## Abrir el proyecto

1. Instalar Godot **4.7.2 estable**.
2. Clonar o descargar este repositorio.
3. Abrir la carpeta raíz (donde está `project.godot`) desde Godot.
4. Ejecutar la escena principal.

El editor para Android está en acceso temprano y su interfaz táctil tiene limitaciones conocidas. Se recomienda guardar copias de seguridad y revisar cada cambio antes de continuar.

## Compilaciones

GitHub Actions valida la apertura del proyecto, realiza una prueba rápida de ejecución y genera un **APK de depuración ARM64** al actualizar `main` o ejecutar el workflow manualmente. El APK aparece como artefacto de la ejecución; no es todavía una versión firmada para distribución pública.

## Hoja de ruta

- **Etapa 1 — Prototipo jugable:** cámara, controles, iluminación inicial y primer escenario completo provisional.
- **Etapa 2 — Pulido visual:** sustituir blockouts, elevar la calidad de modelos, materiales, texturas, iluminación y efectos, manteniendo un rendimiento adecuado en Android.
- **Etapa 3 — Gameplay:** definir exploración libre, objetivos, interacciones y actividades.
- **Etapas posteriores:** ampliar mundos, sistemas, audio, optimización y lanzamiento.

## Estructura

- `scenes/`: escenas del juego.
- `scripts/`: lógica de juego y construcción del prototipo.
- `scripts/ui/`: controles táctiles.
- `.github/workflows/`: automatización de validación y compilación.
