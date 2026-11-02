---
name: flutter-building-plugins
description: Desarrolla plugins de Flutter que ofrecen interoperabilidad nativa para otras apps. Usar al crear paquetes reutilizables que conecten Flutter con funcionalidad específica de plataforma.
---

# Desarrollo de plugins Flutter

## Contenido

- [Arquitectura y patrones](#arquitectura-y-patrones)
- [Crear un nuevo plugin](#crear-un-nuevo-plugin)
- [Código Android](#código-android)
- [Código Windows](#código-windows)
- [Añadir plataformas a un plugin existente](#añadir-plataformas-a-un-plugin-existente)

## Arquitectura y patrones

### Plugins federados

Estructurar en tres partes: (1) paquete principal que expone la API pública, (2) paquete de interfaz de plataforma que define el contrato, (3) paquetes de implementación por plataforma (p. ej. `my_plugin_android`, `my_plugin_windows`).

### FFI frente a plugins estándar

- **Plugins estándar (`--template=plugin`):** Para acceder a APIs de plataforma (Android SDK, iOS) mediante Method Channels.
- **Plugins FFI (`--template=plugin_ffi`):** Para librerías nativas C/C++, servicios de Google Play en Android o enlace estático en iOS/macOS. No incluyen method channels; si se necesitan ambos, usar el template estándar.

## Crear un nuevo plugin

- [ ] Decidir si se necesita FFI o Method Channels estándar.
- [ ] Ejecutar el comando correspondiente de `flutter create`.
- [ ] Verificar la estructura generada.

**Plugin estándar (ejemplo):**
```bash
flutter create --template=plugin \
  --platforms=android,ios,web,linux,macos,windows \
  --org com.ejemplo.organizacion \
  -i objc -a java \
  mi_plugin
```

**Plugin FFI:**
```bash
flutter create --template=plugin_ffi mi_plugin_ffi
```

## Código Android

- Ejecutar al menos un build para generar archivos Gradle (`cd example && flutter build apk --config-only`).
- Abrir el módulo Android en Android Studio para editar con autocompletado y sincronización.
- Implementar la interfaz `FlutterPlugin` y lógica de ciclo de vida. Refactorizar código legacy que use `registerWith`.
- Ubicar el código del plugin en `java/<org>/<PluginName>` (o Kotlin equivalente).

## Código Windows

- El código nativo va en `windows/`. Usar el API de Windows y el canal de métodos para comunicar con Dart.
- Seguir la documentación oficial de Flutter para plugins en Windows (CMake, C++).

## Añadir plataformas a un plugin existente

- Añadir la plataforma al comando de creación o crear la carpeta y archivos necesarios según la plantilla de Flutter.
- Registrar el canal de métodos (o el código nativo) en el punto de entrada de la app para esa plataforma.

## Referencias

- [Documentación Flutter: Developing packages](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Plugin development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#plugin)
