---
name: flutter-building-layouts
description: Construye layouts en Flutter usando el sistema de restricciones y widgets de layout. Usar al crear o refinar la estructura visual de una pantalla en French Gold ERP.
---

# Diseño de layouts en Flutter

## Contenido

- [Principios de layout](#principios-de-layout)
- [Widgets estructurales](#widgets-estructurales)
- [Diseño adaptativo y responsivo](#diseño-adaptativo-y-responsivo)
- [Alineación con el proyecto](#alineación-con-el-proyecto)

## Principios de layout

Regla fundamental: **Las restricciones bajan. Los tamaños suben. El padre fija la posición.**

- **Restricciones hacia abajo:** El padre pasa restricciones (min/max de ancho y alto) a los hijos. Un widget no puede elegir su tamaño al margen de las restricciones del padre.
- **Tamaños hacia arriba:** El hijo calcula su tamaño deseado dentro de esas restricciones y lo comunica al padre.
- **Posición:** Las coordenadas del hijo las define el padre. Los hijos no conocen su posición en pantalla.
- **Evitar restricciones infinitas:** No usar `double.infinity` en el eje cruzado de un `Row`/`Column` ni dentro de regiones desplazables (`ListView`) sin acotar; provoca excepciones de render.

## Widgets estructurales

- **Row y Column:** Para disposiciones lineales horizontal y vertical. Usar `mainAxisAlignment` y `crossAxisAlignment`.
- **Expanded y Flexible:** En hijos de `Row`/`Column`, usar `Expanded` para ocupar el espacio disponible o `Flexible` para permitir que se dimensionen hasta ese espacio.
- **Container:** Para padding, márgenes, bordes o color de fondo.
- **Stack:** Cuando los widgets deben superponerse en el eje Z. Usar `Positioned` para anclar hijos.
- **SizedBox:** Para restricciones fijas (width/height) o espaciado (p. ej. `SizedBox(height: 16)`).

En French Gold ERP usar espaciado consistente (p. ej. `EdgeInsets.all(16)`, `SizedBox(height: 16)`) según **french-gold-ui-ux**.

## Diseño adaptativo y responsivo

- **Responsivo:** Usar `LayoutBuilder`, `Expanded` y `Flexible` para adaptar tamaños y disposición según las restricciones del padre.
- **Adaptativo:** Cambiar la estructura según factor de forma (p. ej. barra inferior en móvil, rail lateral en tablet/desktop).

**Ejemplo:** Evitar overflow al poner un `ListView` dentro de un `Column` envolviendo el `ListView` en `Expanded`.

## Alineación con el proyecto

- **Scaffold:** Usar `Scaffold` con `appBar` (elevation 0 cuando aplique), `body` y `drawer` si la pantalla lo requiere. Ver estructura en **french-gold-ui-ux**.
- **Body:** Contenido que puede crecer dentro de `SingleChildScrollView` con `padding: EdgeInsets.all(16)` o `ListView.builder` para listas largas.
- **Referencias:** [lib/presentation/theme/](lib/presentation/theme/), skill **french-gold-ui-ux**.
