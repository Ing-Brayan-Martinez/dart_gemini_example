---
name: flutter-caching-data
description: Implementa estrategias de caché en French Gold ERP para mejorar rendimiento y soporte offline. Usar al retener datos localmente, reducir peticiones de red o acelerar el arranque.
---

# Caché y arquitectura offline-first (French Gold ERP)

## Contenido

- [Elegir estrategia de caché](#elegir-estrategia-de-caché)
- [Sincronización offline-first](#sincronización-offline-first)
- [Persistencia en archivos y SQLite](#persistencia-en-archivos-y-sqlite)
- [Caché de UI, scroll e imágenes](#caché-de-ui-scroll-e-imágenes)
- [Integración con la capa de datos del proyecto](#integración-con-la-capa-de-datos-del-proyecto)

## Elegir estrategia de caché

- **Preferencias o estado UI pequeño:** `shared_preferences`.
- **Conjuntos de datos estructurados grandes:** Base de datos local (en el proyecto: PostgreSQL y/o SQLite3; ver **flutter-working-with-databases**).
- **Datos binarios o medios grandes:** Caché en sistema de archivos con `path_provider`.
- **Estado de sesión (navegación, scroll):** Usar la restauración de estado de Flutter cuando aplique.
- **Inicialización Android (Flutter embebido):** Pre-calentar y cachear `FlutterEngine` si la app nativa embebe Flutter.

## Sincronización offline-first

Diseñar los **repositorios** como única fuente de verdad, combinando base de datos local y cliente API.

### Lecturas (enfoque Stream)

Emitir primero los datos locales para una UI rápida; luego obtener datos remotos, actualizar la caché local y emitir de nuevo.

### Escrituras

- **Solo online:** Intentar primero la llamada a la API; actualizar la base local solo si la API responde bien.
- **Offline-first:** Escribir en la base local de inmediato; intentar la API; si falla, marcar el registro para sincronización en segundo plano (p. ej. flag `synchronized`).

### Sincronización en segundo plano

Añadir un flag `synchronized` (boolean) en los modelos. Ejecutar una tarea periódica (p. ej. `workmanager` o `Timer`) para enviar los cambios locales no sincronizados al servidor.

## Persistencia en archivos y SQLite

- **Archivos:** Usar `path_provider`: `getApplicationDocumentsDirectory()` para datos persistentes, `getTemporaryDirectory()` para caché que el SO puede borrar.
- **SQLite:** En el proyecto existen servicios SQLite3 en `lib/data/sqlite3/service/`. Usar siempre parámetros (whereArgs) para evitar inyección SQL. Ver **flutter-postgresql-queries-french-gold** para convenciones (en PostgreSQL el proyecto usa `Sql.named` y parámetros nombrados).

## Caché de UI, scroll e imágenes

- **Imágenes:** Usar el paquete `cached_network_image` para caché en disco de imágenes remotas. Ajustar `ImageCache.maxByteSize` si se cargan imágenes muy grandes.
- **Scroll:** Usar `scrollCacheExtent` con `ScrollCacheExtent` en `ListView`, `GridView`, `Viewport` (no usar las propiedades obsoletas `cacheExtent` / `cacheExtentStyle`).
- **Widgets:** Preferir constructores `const` para que el framework evite rebuilds innecesarios. No sobrescribir `operator ==` en widgets salvo en casos muy concretos (widgets hoja, comparación más barata que reconstruir).

## Integración con la capa de datos del proyecto

En French Gold ERP la capa de datos está en `lib/data/`: servicios PostgreSQL/SQLite3 y repositorios. Los repositorios pueden combinar lectura/escritura local con llamadas HTTP; el controller solo conoce el repositorio. Para añadir una entidad con persistencia y opcional sincronización, seguir **flutter-crud-entity-french-gold** y **flutter-working-with-databases**.

## Referencias

- Skill **flutter-working-with-databases**
- Skill **flutter-postgresql-queries-french-gold**
- Skill **flutter-crud-entity-french-gold**
