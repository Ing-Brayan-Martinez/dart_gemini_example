---
name: flutter-improving-accessibility
description: Configura una app Flutter para tecnologías de asistencia (lectores de pantalla). Usar al garantizar que la aplicación sea usable para personas con discapacidad.
---

# Accesibilidad en Flutter

## Contenido

- [Diseño y estilo UI](#diseño-y-estilo-ui)
- [Widgets de accesibilidad](#widgets-de-accesibilidad)
- [Accesibilidad web](#accesibilidad-web)
- [Diseño adaptativo y responsivo](#diseño-adaptativo-y-responsivo)
- [Flujo de implementación](#flujo-de-implementación)

## Diseño y estilo UI

- **Escalado de fuente:** Dejar espacio suficiente para que el contenido se renderice con el tamaño de fuente máximo del SO. Evitar alturas fijas en contenedores de texto.
- **Contraste de color:** Mantener ratio de contraste mínimo 4.5:1 para texto pequeño y 3.0:1 para texto grande (≥18pt normal o ≥14pt negrita), según estándares W3C.
- **Áreas táctiles:** Tamaño mínimo de 48x48 píxeles lógicos para elementos interactivos. En French Gold ERP ver **french-gold-ui-ux** (áreas táctiles y contraste).

## Widgets de accesibilidad

- **`Semantics`:** Anotar el árbol de widgets con descripción y significado. Asignar `SemanticsRole` (button, link, heading, listItem, etc.) en componentes custom.
- **`MergeSemantics`:** Envolver widgets compuestos para unir la semántica de los hijos en un solo nodo para el lector de pantalla.
- **`ExcludeSemantics`:** Ocultar widgets decorativos o redundantes de las herramientas de accesibilidad.

## Accesibilidad web

Flutter web pinta en un solo canvas; la estructura se expone al navegador mediante una capa DOM de semántica.

- La accesibilidad web puede estar desactivada por defecto (rendimiento). El usuario puede activarla con el botón invisible (`aria-label="Enable accessibility"`).
- Para activar por defecto en una app web-first: llamar a `SemanticsBinding.instance.ensureSemantics()` al inicio (p. ej. en `main()` si `kIsWeb`).
- Usar widgets estándar (`TabBar`, `MenuAnchor`, `Table`) para mapeo ARIA automático; en componentes custom, asignar `SemanticsRole` explícitamente.

## Diseño adaptativo y responsivo

- **Responsivo:** Ajustar disposición y tamaños al espacio disponible.
- **Adaptativo:** Elegir layout e input según factor de forma (navegación inferior en móvil, panel lateral en tablet/desktop).

## Flujo de implementación

- [ ] Comprobar que todos los elementos interactivos tengan área táctil ≥ 48x48 px.
- [ ] Probar el layout con el tamaño de fuente máximo del SO (sin recortes ni overflow).
- [ ] Validar ratios de contraste (4.5:1 texto normal, 3.0:1 texto grande).
- [ ] Envolver widgets interactivos custom en `Semantics` con el `SemanticsRole` adecuado.
- [ ] Agrupar widgets compuestos con `MergeSemantics`; ocultar decorativos con `ExcludeSemantics`.
- [ ] En web: verificar roles ARIA y considerar activación programática del árbol de semántica.
- [ ] Validar con lectores de pantalla (VoiceOver/TalkBack) y corregir hasta que el recorrido sea claro y lógico.

## Referencias

- Skill **french-gold-ui-ux** (áreas táctiles y contraste en el proyecto)
- [Documentación Flutter: Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
