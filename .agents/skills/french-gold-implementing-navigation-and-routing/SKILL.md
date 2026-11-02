---
name: french-gold-implementing-navigation-and-routing
description: Gestiona rutas, navegación y enlaces profundos en French Gold ERP con GoRouter. Usar para registrar nuevas rutas, navegar entre pantallas y pasar/recibir argumentos.
---

# Navegación y rutas en Flutter (French Gold ERP)

## Contenido

- [Conceptos en el proyecto](#conceptos-en-el-proyecto)
- [Navegación con GoRouter](#navegación-con-gorouter)
- [Registro de rutas](#registro-de-rutas)
- [Pasar y recibir argumentos](#pasar-y-recibir-argumentos)
- [Flujo de implementación](#flujo-de-implementación)
- [Reglas críticas y de arquitectura](#reglas-críticas-y-de-arquitectura)
- [Referencias](#referencias)

---

## Conceptos en el proyecto

- **GoRouter:** El estándar oficial del proyecto para la navegación y deep linking. Se configura de manera centralizada en `lib/presentation/routes/app_routes.dart`.
- **Rutas constantes (`routeName`):** Toda pantalla expone su identificador de ruta como una constante estática (`static const String routeName = '/ruta';`).
- **Transiciones personalizadas:** Las rutas en `app_routes.dart` utilizan `CustomTransitionPage` con `FadeTransition` para mantener una experiencia visual fluida e uniforme.

---

## Navegación con GoRouter

Para navegar entre pantallas se deben utilizar los métodos de extensión de `go_router` sobre el `BuildContext`:

- **Ir a una pantalla manteniendo historial (Push):**
  ```dart
  context.push(CustomerScreen.routeName);
  ```
- **Ir a una pantalla enviando argumentos:**
  ```dart
  context.push(ViewCustomerDetailsScreen.routeName, extra: customer);
  ```
- **Reemplazar la pantalla actual (Go):**
  ```dart
  context.go(HomeScreen.routeName);
  ```
  *Útil para navegación principal o redirecciones donde no se deba permitir volver atrás.*
- **Volver a la pantalla anterior:**
  ```dart
  context.pop();
  ```
- **Volver devolviendo un resultado:**
  ```dart
  context.pop(true);
  ```
- **Esperar resultado de una pantalla:**
  ```dart
  final result = await context.push<bool>(CreateCustomerScreen.routeName);
  ```

---

## Registro de rutas

En `lib/presentation/routes/app_routes.dart` se declaran las rutas en la propiedad `routes` de `GoRouter`.

Ejemplo de registro oficial:
```dart
GoRoute(
  path: CustomerScreen.routeName,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const CustomerScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
),
```

---

## Pasar y recibir argumentos

### Envío de argumentos
Se utiliza el parámetro nombrado `extra` en los métodos de `go_router`:
```dart
context.push(ViewProductDetailsScreen.routeName, extra: product);
```

### Recepción de argumentos
Los datos pasados en `extra` se pueden extraer desde la definición de la ruta en `app_routes.dart` o directamente en el widget:

```dart
GoRoute(
  path: ViewProductDetailsScreen.routeName,
  pageBuilder: (context, state) {
    final product = state.extra as Product?;
    return CustomTransitionPage(
      key: state.pageKey,
      child: ViewProductDetailsScreen(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  },
),
```

---

## Flujo de implementación

Seguir este checklist al agregar una nueva pantalla o ruta:

- [ ] **1. Definir constante de ruta:** En la pantalla (`lib/presentation/screens/<modulo>/<nombre>_screen.dart`), declarar `static const String routeName = '/<nombre>';`.
- [ ] **2. Importar pantalla:** En `lib/presentation/routes/app_routes.dart`, importar el archivo de la pantalla.
- [ ] **3. Registrar `GoRoute`:** Añadir el `GoRoute` dentro de `AppRoutes.router` utilizando `CustomTransitionPage` y `FadeTransition`.
- [ ] **4. Invocar navegación:** Usar `context.push()` o `context.go()` desde el componente o pantalla de origen.
- [ ] **5. Manejar argumentos (si aplica):** Pasar los objetos mediante el parámetro `extra` y procesarlos en el destino.

---

## Reglas críticas y de arquitectura

1. **Uso Exclusivo de GoRouter:** Usar exclusivamente `GoRouter` vía `BuildContext` (`context.push`, `context.go`, `context.pop`). No utilizar el `Navigator` clásico de Flutter.
2. **Nombres de Ruta Estáticos:** Toda pantalla DEBE exponer una propiedad `static const String routeName`.
3. **Purity & Capas:** La navegación pertenece exclusivamente a la capa de `Presentation`. No incluir llamadas a `BuildContext` ni `GoRouter` dentro de controladores de dominio (`lib/domain/controllers/`).
4. **Verificación Obligatoria:** Antes de dar por completada una tarea, ejecutar `dart format lib/` y `flutter analyze` asegurando 0 errores y advertencias.

---

## Referencias

- Configuración del Router principal: [lib/presentation/routes/app_routes.dart](lib/presentation/routes/app_routes.dart)
- Instrucciones del proyecto: [AGENTS.md](AGENTS.md)
- Skill Entidades CRUD: [french-gold-crud-entity](.agents/skills/french-gold-crud-entity/SKILL.md)
- Skill Gestión de Estado con Signals: [flutter-managing-state](.agents/skills/flutter-managing-state/SKILL.md)
