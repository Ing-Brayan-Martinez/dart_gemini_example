---
name: flutter-embedding-native-views
description: Incrusta vistas nativas de Android, iOS o macOS en una app Flutter. Usar al integrar componentes nativos complejos como mapas o web views.
---

# Vistas de plataforma y contenido web

## Contenido

- [Arquitectura de Platform Views](#arquitectura-de-platform-views)
- [Vistas web](#vistas-web)
- [Android](#android)
- [iOS y macOS](#ios-y-macos)
- [Rendimiento](#rendimiento)

## Arquitectura de Platform Views

Las Platform Views permiten incrustar vistas nativas (Android `View`, iOS `UIView`, macOS `NSView`) dentro del árbol de widgets Flutter, aplicando transformaciones, recortes y opacidad desde Dart.

### Android (API 23+)

- **Híbrida (Hybrid Composition):** Flutter pinta en una textura y se compone con la vista nativa. Mejor fidelidad; puede reducir FPS global y algunas transformaciones Flutter no se aplican a la vista nativa.
- **Capa de textura (Texture Layer):** La vista nativa se pinta en una textura; Flutter la dibuja y pinta su contenido en un Surface. Mejor rendimiento para Flutter y todas las transformaciones funcionan; scroll rápido (p. ej. WebView) puede dar jank. `SurfaceView` puede dar problemas de accesibilidad.

### iOS y macOS

- **iOS:** Solo Hybrid Composition; la `UIView` se añade a la jerarquía. Limitaciones: `ShaderMask` y `ColorFiltered` no soportados; `BackdropFilter` con limitaciones de composición.
- **macOS:** Hybrid Composition con `NSView`; en versiones recientes puede haber limitaciones (p. ej. gestos).

## Vistas web

Para contenido web incrustado usar el paquete `webview_flutter` (o similar), que utiliza Platform Views en cada plataforma. Configurar según la documentación del paquete.

## Rendimiento

En animaciones Dart complejas que incluyen vistas nativas, se puede mitigar la caída de FPS renderizando una captura de la vista nativa como textura placeholder mientras dura la animación.

## Referencias

- [Documentación Flutter: Platform views](https://docs.flutter.dev/platform-integration/platform-views)
- [webview_flutter](https://pub.dev/packages/webview_flutter)
