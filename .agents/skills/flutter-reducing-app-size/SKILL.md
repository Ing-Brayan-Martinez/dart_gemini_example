---
name: flutter-reducing-app-size
description: Mide y optimiza el tamaño de los bundles de la app Flutter para despliegue. Usar al reducir el tamaño de descarga o cumplir límites de las tiendas de aplicaciones.
---

# Reducir el tamaño de la app Flutter

## Contenido

- [Conceptos](#conceptos)
- [Generar análisis de tamaño](#generar-análisis-de-tamaño)
- [Analizar en DevTools](#analizar-en-devtools)
- [Estimación de descarga iOS](#estimación-de-descarga-ios)
- [Estrategias de reducción](#estrategias-de-reducción)

## Conceptos

- **Debug vs Release:** No medir tamaño en builds de debug. Incluyen overhead de la VM y no tienen compilación AOT ni tree-shaking.
- **Tamaño de subida vs descarga:** El tamaño del paquete subido (APK, AAB, IPA) no coincide con el tamaño de descarga para el usuario; las tiendas filtran arquitecturas y densidades según el dispositivo.
- **Tree-shaking AOT:** El compilador AOT de Dart elimina código no usado en builds profile y release.
- **Análisis de tamaño:** La opción `--analyze-size` genera un JSON (`*-code-size-analysis_*.json`) con el tamaño por paquetes, librerías, clases y funciones.

## Generar análisis de tamaño

- [ ] Elegir plataforma destino (apk, appbundle, ios, linux, macos, windows).
- [ ] Ejecutar el build con `--analyze-size`:  
  Android: `flutter build apk --analyze-size` o `flutter build appbundle --analyze-size`.  
  iOS: `flutter build ios --analyze-size`.  
  Desktop: `flutter build [windows|macos|linux] --analyze-size`.
- [ ] Localizar el JSON generado en `build/`.

## Analizar en DevTools

- [ ] Ejecutar `dart devtools` y abrir la herramienta "Open app size tool".
- [ ] Subir el archivo `*-code-size-analysis_*.json`.
- [ ] Inspeccionar el treemap o la vista en árbol para identificar paquetes, librerías o assets grandes.
- [ ] Identificar los mayores contribuyentes; valorar si la dependencia o el asset es imprescindible; eliminar o sustituir y volver a generar el análisis.

## Estimación de descarga iOS

El build `ios --analyze-size` genera un `.app` útil para tamaños relativos, pero no para la descarga final en App Store. Seguir la documentación de Apple y las herramientas de estimación de tamaño de descarga para métricas precisas.

## Estrategias de reducción

- Eliminar dependencias no usadas y assets innecesarios.
- Usar soporte de arquitecturas específicas (split APKs en Android) cuando aplique.
- Reducir recursos (imágenes, fuentes) y usar formatos eficientes.
- Revisar el JSON de tamaño para detectar librerías o código que se pueda sustituir por alternativas más ligeras.

## Referencias

- [Documentación Flutter: Measuring your app’s size](https://docs.flutter.dev/perf/app-size)
