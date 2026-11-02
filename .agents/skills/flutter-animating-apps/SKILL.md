---
name: flutter-animating-apps
description: Implementa animaciones, transiciones y movimiento en French Gold ERP. Usar al añadir feedback visual, transiciones de elemento compartido o animaciones basadas en física.
---

# Animaciones en Flutter

## Contenido

- [Conceptos](#conceptos)
- [Estrategias de animación](#estrategias-de-animación)
- [Flujos de trabajo](#flujos-de-trabajo)
- [Ejemplos](#ejemplos)

## Conceptos

Usar el sistema tipado de `Animation`. No calcular fotogramas a mano; usar el ticker y las clases de interpolación del framework.

- **`Animation<T>`:** Representación abstracta de un valor que cambia en el tiempo. Tiene estado (completada, descartada) y notifica a los listeners; no conoce la UI.
- **`AnimationController`:** Conduce la animación. Genera valores (típicamente 0.0–1.0) sincronizados con el refresco de pantalla. Siempre proporcionar `vsync` (p. ej. con `SingleTickerProviderStateMixin`) y llamar a `dispose()` para evitar fugas de memoria.
- **`Tween<T>`:** Mapeo sin estado de un rango de entrada (0.0–1.0) a un tipo de salida (Color, Offset, double). Encadenar con curvas usando `.animate()`.
- **`Curve`:** Aplicar timing no lineal (p. ej. `Curves.easeIn`, `Curves.bounceOut`) con `CurvedAnimation` o `CurveTween`.

## Estrategias de animación

- **Cambios simples de propiedad (tamaño, color, opacidad) sin control de reproducción:** Animaciones **implícitas** (`AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`).
- **Control de reproducción (play, pausa, reverse, loop) o varias propiedades:** Animaciones **explícitas** (`AnimationController` con `AnimatedBuilder` o `AnimatedWidget`).
- **Elemento que viaja entre dos rutas:** **Hero** (transiciones de elemento compartido).
- **Movimiento tipo físico (p. ej. rebote tras un arrastre):** Animaciones basadas en **física** (`SpringSimulation`).
- **Secuencia de movimientos solapados o retrasados:** **Staggered animations** (varios `Tween` con un solo `AnimationController` y curvas `Interval`).

## Flujos de trabajo

### Animaciones implícitas

- Identificar las propiedades a animar.
- Sustituir el widget estático por su variante animada (p. ej. `Container` → `AnimatedContainer`).
- Definir `duration` y opcionalmente `curve`.
- Disparar la animación actualizando las propiedades dentro de `setState()` (o en GetX, actualizando una variable reactiva que la UI observe).

### Animaciones explícitas

- Añadir `SingleTickerProviderStateMixin` (o `TickerProviderStateMixin` para varios controllers) al `State`.
- Inicializar `AnimationController` en `initState()` con `vsync: this` y `duration`.
- Definir un `Tween` y enlazarlo al controller con `.animate()`.
- Envolver la UI en `AnimatedBuilder` o un `AnimatedWidget`.
- Controlar con `controller.forward()`, `controller.reverse()`, `controller.repeat()`.
- Llamar a `controller.dispose()` en `dispose()`.

### Transiciones Hero

- Envolver el widget de origen y el de destino en `Hero` con el **mismo** `tag` (único y estable).
- Asegurar que ambos árboles dentro de cada `Hero` sean visualmente similares para evitar saltos.
- Navegar a la ruta destino (en el proyecto: `Get.toNamed(...)`).

### Animaciones basadas en física

- Usar un `AnimationController` sin duración fija.
- Capturar la velocidad del gesto (p. ej. `onPanEnd` con `DragEndDetails`).
- Convertir la velocidad a la coordenada de la propiedad animada.
- Crear una `SpringSimulation` con masa, rigidez, amortiguación y velocidad, y usar `controller.animateWith(simulation)`.

## Ejemplos

**Animación explícita con AnimatedBuilder (staggered):** Varios `Tween` con `CurvedAnimation` y `Interval` distintos, todos con el mismo `AnimationController`; en `build`, un `AnimatedBuilder` que lee los valores de las animaciones y pinta un `Container` (width, color). Llamar a `_controller.dispose()` en `dispose()`.

**Transición de ruta personalizada:** `PageRouteBuilder` con `transitionsBuilder` que use `SlideTransition` (Tween de `Offset(0,1)` a `Offset.zero`) o `FadeTransition`. En el proyecto, las rutas se manejan con GetX; se pueden personalizar transiciones en `GetPage` si se usa un `customTransition`.

## Referencias

- Documentación Flutter: [Animations](https://docs.flutter.dev/development/ui/animations)
- Skill **flutter-implementing-navigation-and-routing** (rutas y GetX)
