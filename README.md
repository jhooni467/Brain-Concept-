# Concept of the Brain

Videojuego 3D de exploración para Android en orientación horizontal. Proyecto desarrollado con **Godot 4.7.2 estable** y **GDScript**.

## Dirección visual

- Personajes 3D Low Poly.
- Entornos 3D con estética retro inspirada en PS1/PS2.
- Atmósferas liminales, Dreamcore, Weirdcore y Backrooms.
- El escenario inicial es un mundo provisional explorable que se ampliará y recibirá más detalle durante las siguientes iteraciones.

## Estado actual — Etapa 2 en desarrollo

La versión en desarrollo incluye:
- Axel rediseñado con cabeza de capucha en caja cerrada y dos orejas triangulares independientes, ojos ámbar, cuerpo corto y cola de bufanda desplazada al lado derecho. La geometría de las orejas se construye como prismas cerrados para evitar triangulación de polígonos cóncavos.
- Movimiento en tercera persona relativo a la cámara.
- Cámara orbital táctil: arrastrar desde el lado derecho para mirar a izquierda, derecha, arriba y abajo.
- Joystick de movimiento con opacidad visual del 10%, mayor radio y zona táctil ampliada.
- Botón de salto aumentado para facilitar el uso en teléfonos.
- Contador de FPS sencillo en la esquina superior izquierda, con 90% de opacidad.
- Colisiones físicas del personaje con suelo, paredes, máquinas, árboles, mobiliario, caseta, barrera, rocas, piscina y objetos de escenario relevantes.
- Lavandería inicial conectada a una zona exterior amplia.
- Zona exterior con caminos, bosque low-poly, banca, caseta de control, barrera, ATM en una formación rocosa, piscina con monitores CRT, señal morada y palmera.
- Optimización inicial: árboles repetidos mediante MultiMesh, menos luces dinámicas y glow desactivado para reducir trabajo de renderizado en Android.
- Texturas de suelo, paredes, terreno y asfalto con ruido de varias escalas y coordenadas de textura ajustadas para evitar mosaicos y líneas repetitivas visibles.
- Renderizador Mobile, orientación horizontal y exportación Android ARM64.
- GitHub Actions valida los scripts y escenas, ejecuta una prueba rápida y genera un APK de depuración.

La escena sigue siendo un prototipo. El contador de FPS ayuda a medir el rendimiento, pero el rendimiento real debe comprobarse en el teléfono; una compilación correcta no garantiza una tasa de cuadros determinada.

## Controles

### Android
- Joystick: zona inferior izquierda.
- Cámara: arrastrar desde el lado derecho de la pantalla.
- Saltar: botón grande de la esquina inferior derecha.

### Teclado y ratón
- WASD o flechas: moverse.
- Espacio: saltar.
- Mantener el botón derecho del ratón y arrastrar: mover la cámara.

## Colisiones

El personaje es un `CharacterBody3D` con cápsula de colisión. Su movimiento se resuelve con `move_and_slide()`. Los objetos sólidos usan cuerpos estáticos y formas de colisión; los elementos decorativos ligeros pueden no tener colisión.

## Abrir el proyecto

1. Instalar Godot **4.7.2 estable**.
2. Clonar o descargar este repositorio.
3. Abrir la carpeta raíz (donde está `project.godot`) desde Godot.
4. Ejecutar la escena principal.

El editor para Android está en acceso temprano y su interfaz táctil tiene limitaciones conocidas. Se recomienda guardar copias de seguridad y revisar cada cambio antes de continuar.

## Compilaciones

GitHub Actions valida la apertura del proyecto, realiza una prueba rápida de ejecución y genera un **APK de depuración ARM64** al actualizar `main` o ejecutar el workflow manualmente. El APK aparece como artefacto de la ejecución; no es todavía una versión firmada para distribución pública.

## Hoja de ruta

- **Etapa 1 — Fundación técnica y primer escenario provisional:** completada.
- **Etapa 2 — Renovación visual, físicas, controles, rendimiento y expansión del mundo:** en desarrollo.
- **Etapa 3 — Gameplay:** definir y ampliar exploración libre, objetivos, interacciones y actividades.
- **Etapas posteriores:** más mundos, sistemas, audio, optimización final y lanzamiento.

## Estructura

- `scenes/`: escenas del juego.
- `scripts/`: lógica de juego y construcción del prototipo.
- `scripts/ui/`: controles táctiles.
- `.github/workflows/`: automatización de validación y compilación.
