---
name: flutter-adding-home-screen-widgets
description: Añade widgets de pantalla de inicio (Android e iOS) a una app Flutter. Usar para mostrar información rápida o acciones directas desde la pantalla de inicio del dispositivo.
---

# Widgets de pantalla de inicio en Flutter

## Contenido

- [Arquitectura y flujo de datos](#arquitectura-y-flujo-de-datos)
- [Integración desde Flutter](#integración-desde-flutter)
- [Implementación iOS](#implementación-ios)
- [Implementación Android](#implementación-android)

## Arquitectura y flujo de datos

Los widgets de pantalla de inicio se implementan en código nativo (SwiftUI en iOS, XML/Kotlin en Android). La app Flutter se comunica con ellos mediante almacenamiento local compartido (`UserDefaults` en iOS, `SharedPreferences` en Android), típicamente con el paquete `home_widget`.

- **Escritura:** La app Flutter escribe pares clave-valor o imágenes en un contenedor compartido.
- **Disparo:** La app Flutter indica al SO que actualice el widget.
- **Lectura:** El widget nativo lee los datos del contenedor y actualiza su UI.

## Integración desde Flutter

- [ ] Inicializar el App Group: llamar a `HomeWidget.setAppGroupId('<APP_GROUP>')` en el arranque (p. ej. `initState` o `main`).
- [ ] Guardar datos: `HomeWidget.saveWidgetData<T>('key', value)`.
- [ ] Notificar actualización: `HomeWidget.updateWidget(iOSName: '...', androidName: '...')`.
- [ ] Verificar: ejecutar build y revisar que el plugin esté registrado.

## Implementación iOS

- Abrir `ios/Runner.xcworkspace` en Xcode y añadir un target **Widget Extension**. Desactivar "Include Live Activity" e "Include Configuration Intent" si no se necesitan.
- Añadir la capacidad **App Groups** al target Runner y al target del Widget; usar el mismo App Group ID que en Dart.
- Implementar la UI del widget en SwiftUI leyendo los datos del App Group.

## Implementación Android

- Añadir el código del widget en el proyecto Android (receptor de actualizaciones y layout del widget).
- Configurar el `AndroidManifest` y los metadatos del widget según la documentación del paquete `home_widget` o del enfoque elegido.

## Referencias

- Paquete [home_widget](https://pub.dev/packages/home_widget) (si se usa)
- [Documentación Flutter: Home screen widgets](https://docs.flutter.dev/platform-integration/platform-channels)
