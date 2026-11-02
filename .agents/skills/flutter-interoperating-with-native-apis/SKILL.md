---
name: flutter-interoperating-with-native-apis
description: Interopera con APIs nativas en Android, iOS y web. Usar al acceder a funciones del dispositivo no disponibles en Dart o al llamar código nativo existente.
---

# Integración de código específico de plataforma en Flutter

## Contenido

- [Conceptos y terminología](#conceptos-y-terminología)
- [Enlace a código C/C++ (FFI)](#enlace-a-código-cc-ffi)
- [Platform Channels y Pigeon](#platform-channels-y-pigeon)
- [Platform Views](#platform-views)
- [Web y Wasm](#web-y-wasm)
- [Flujos de trabajo](#flujos-de-trabajo)

## Conceptos y terminología

- **FFI (Foreign Function Interface):** Librería `dart:ffi` para enlazar Dart con APIs nativas C/C++.
- **Platform Channel:** Sistema de mensajería asíncrona (`MethodChannel`, `BasicMessageChannel`) entre Dart y la plataforma (Kotlin/Java, Swift/Objective-C, C++).
- **Pigeon:** Herramienta de generación de código que crea Platform Channels con tipos seguros.
- **Platform View:** Mecanismo para incrustar componentes de UI nativos (Android `View`, iOS `UIView`) en el árbol de widgets Flutter.
- **JS Interop:** En web, uso de `package:web` y `dart:js_interop` para interactuar con JavaScript y DOM (compatible con Wasm).

## Enlace a código C/C++ (FFI)

Usar FFI para ejecutar código nativo de alto rendimiento o reutilizar librerías C/C++ sin el coste de los Platform Channels asíncronos.

- **Plantilla recomendada (Flutter 3.38+):** `flutter create --template=package_ffi <nombre>`. Usa hooks `build.dart` para compilar el código nativo.
- **Si se necesita API de plugins Flutter o Play Services:** `flutter create --template=plugin_ffi <nombre>`.
- **Símbolos C++:** Marcar con `extern "C"` y atributos de visibilidad para evitar que el linker descarte en LTO.
- **Bindings Dart:** Usar `package:ffigen` y `ffigen.yaml` para generar bindings desde los headers C.

## Platform Channels y Pigeon

Para APIs específicas de plataforma (Batería, Bluetooth, servicios del SO) usar el lenguaje nativo del SO.

- **Pigeon:** Preferir Pigeon frente a `MethodChannel` manual para APIs complejas o muy usadas. Definir el protocolo en un archivo Dart con anotaciones `@HostApi()`, generar código para host (Kotlin/Swift) y cliente (Dart), e implementar las interfaces generadas en nativo.
- **Hilos:** Invocar métodos del canal que vayan a Flutter en el hilo principal (UI) de la plataforma. Si los handlers se ejecutan en segundo plano, usar la Task Queue API. Para usar plugins/canales desde un Isolate en Dart, registrar con `BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken)`.

## Platform Views

Para incrustar UI nativa (mapas, reproductor de vídeo nativo): ver skill **flutter-embedding-native-views**. En Android elegir entre Hybrid Composition (mejor fidelidad, accesibilidad) y Texture Layer (mejor rendimiento Flutter). En iOS solo Hybrid Composition; implementar `FlutterPlatformViewFactory` y `FlutterPlatformView`; en Dart usar `UiKitView`.

## Web y Wasm

- **Compilación Wasm:** `flutter build web --wasm`. Para multi-hilo, configurar el servidor HTTP con cabeceras `Cross-Origin-Embedder-Policy` y `Cross-Origin-Opener-Policy`. WasmGC no está soportado en navegadores iOS (WebKit); Flutter hace fallback a JavaScript.
- **Interop web:** Usar solo `package:web` y `dart:js_interop`. No usar `dart:html`, `dart:js` ni `package:js` (incompatibles con Wasm). Para incrustar HTML usar `HtmlElementView.fromTagName`.

## Flujos de trabajo

### Integración FFI nativa

- [ ] Ejecutar `flutter create --template=package_ffi <nombre>`.
- [ ] Colocar código C/C++ en `src/`; exportar con `extern "C"` y atributos de visibilidad.
- [ ] Configurar `ffigen.yaml` y ejecutar `dart run ffigen`.
- [ ] Ajustar `hook/build.dart` si se enlaza con librerías precompiladas o del sistema.
- [ ] Ejecutar `flutter test` y corregir errores.

### Platform Channel con Pigeon

- [ ] Añadir `pigeon` a `dev_dependencies`.
- [ ] Crear `pigeons/messages.dart` con clases de datos y APIs `@HostApi()`.
- [ ] Ejecutar el generador Pigeon; implementar las interfaces en Android (Kotlin) e iOS (Swift); en Dart importar el archivo generado y llamar a los métodos.
- [ ] Verificar compilación en todas las plataformas.

### Incrustar una Platform View

- [ ] En Dart: widget que según `defaultTargetPlatform` devuelva `AndroidView`/`PlatformViewLink` (Android) o `UiKitView` (iOS).
- [ ] Android: clase que implemente `PlatformView` y devuelva la `View` nativa; `PlatformViewFactory` registrada en `configureFlutterEngine`.
- [ ] iOS: clase que implemente `FlutterPlatformView` y devuelva la `UIView`; `FlutterPlatformViewFactory` registrada en el AppDelegate.
- [ ] Probar en dispositivos físicos y revisar recortes y scroll.

## Referencias

- Skill **flutter-embedding-native-views**
- [Documentación Flutter: Platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Documentación Flutter: FFI](https://dart.dev/interop/c-interop)
