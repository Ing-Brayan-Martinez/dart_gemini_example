---
name: flutter-setting-up-on-linux
description: Configura el entorno Linux para desarrollo Flutter. Usar al preparar una máquina Linux para ejecutar, compilar o desplegar apps Flutter.
---

# Configuración del entorno Linux para Flutter

## Contenido

- [Dependencias del sistema](#dependencias-del-sistema)
- [Configuración del toolchain](#configuración-del-toolchain)
- [Validación](#validación)
- [Distribución (Snapcraft)](#distribución-snapcraft)

## Dependencias del sistema

Para compilar y ejecutar Flutter en Linux desktop se necesitan el toolchain C/C++ y librerías del sistema. Flutter usa `dart:ffi` y GTK para la UI.

En distribuciones basadas en Debian/Ubuntu:

- **Utilidades:** `curl`, `git`, `unzip`, `xz-utils`, `zip`
- **Build:** `clang`, `cmake`, `ninja-build`, `pkg-config`
- **Librerías:** `libglu1-mesa`, `libgtk-3-dev`, `libstdc++-12-dev`

## Configuración del toolchain

- [ ] Actualizar e instalar paquetes:
  ```bash
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
  ```
- [ ] Instalar Flutter SDK y añadir su `bin` al `PATH`.
- [ ] (Opcional) En ChromeOS: activar soporte Linux y actualizar el contenedor Linux con los mismos paquetes.
- [ ] Configurar IDE (VS Code, Android Studio, IntelliJ) con las extensiones/plugins de Flutter y Dart.

## Validación

- [ ] Ejecutar `flutter doctor -v` y corregir lo que indique.
- [ ] `flutter config --enable-linux-desktop` si Linux desktop no está habilitado.
- [ ] `flutter devices`: debe aparecer el dispositivo linux.

## Distribución (Snapcraft)

Para empaquetar la app para distribución en Linux se puede usar Snapcraft. Seguir la documentación de Flutter y de Snapcraft para generar el snap.

## Referencias

- [Documentación Flutter: Linux setup](https://docs.flutter.dev/get-started/install/linux)
