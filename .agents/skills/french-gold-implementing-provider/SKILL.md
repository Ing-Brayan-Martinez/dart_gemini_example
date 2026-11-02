---
name: french-gold-implementing-provider
description: Guía paso a paso para configurar e implementar la inyección de dependencias con MultiProvider en French Gold ERP (lib/main.dart, lib/presentation/provider/app_provider.dart y controladores de dominio). Usar al agregar nuevos repositorios, helpers o controladores que se deban proveer a toda la aplicación.
---

# Implementación de MultiProvider y DI (French Gold ERP)

## Contenido

- [Resumen de arquitectura DI](#resumen-de-arquitectura-di)
- [Estructura en app_provider.dart](#estructura-en-app_providerdart)
- [Inicialización en main.dart](#inicialización-en-maindart)
- [Consumo de dependencias en UI](#consumo-de-dependencias-en-ui)
- [Flujo de paso a paso para registrar una nueva dependencia](#flujo-de-paso-a-paso-para-registrar-una-nueva-dependencia)
- [Reglas críticas y de arquitectura](#reglas-críticas-y-de-arquitectura)
- [Referencias](#referencias)

---

## Resumen de arquitectura DI

French Gold ERP utiliza el paquete `provider` (`MultiProvider`) a nivel raíz de la aplicación para gestionar la Inyección de Dependencias (DI) de forma centralizada.

El flujo de inyección respeta la jerarquía de dependencias del proyecto:

```
[ ContextHelperImpl / TransactionHelperImpl ]  (Helpers globales)
                      │
                      ▼
[ Repositorios (XxxRepositoryImpl) ]          (Acceso a datos)
                      │
                      ▼
[ Controladores (XxxController) ]             (Lógica de dominio puro)
                      │
                      ▼
[ Interfaz de Usuario (Screens / Widgets) ]   (Capa de presentación)
```

---

## Estructura en app_provider.dart

En `lib/presentation/provider/app_provider.dart` se define la lista global `providers`. El orden de los elementos es jerárquico y obligatorio: los elementos dependientes deben declararse **después** de sus dependencias.

Ejemplo de configuración oficial:

```dart
import 'package:provider/provider.dart';

// Repositorios
import '../../data/repository/warehouse_repository.dart';
import '../../data/repository/product_warehouse_repository.dart';

// Helpers y Controladores
import '../../domain/config/context_helper.dart';
import '../../domain/config/transaction_helper.dart';
import '../../domain/controllers/warehouse/warehouse_controller.dart';

final providers = [
  // 1. Helpers Globales de Infraestructura
  Provider(create: (context) => ContextHelperImpl()),
  Provider(create: (context) => TransactionHelperImpl()),

  // 2. Repositorios de Datos
  Provider(create: (context) => WarehouseRepositoryImpl()),
  Provider(create: (context) => ProductWarehouseRepositoryImpl()),

  // 3. Controladores de Dominio (Inyección por constructor)
  Provider(
    create: (context) => WarehouseController(
      context.read<ContextHelperImpl>(),
      context.read<TransactionHelperImpl>(),
      context.read<WarehouseRepositoryImpl>(),
      context.read<ProductWarehouseRepositoryImpl>(),
    ),
  ),
];
```

---

## Inicialización en main.dart

En `lib/main.dart`, la lista `providers` se le pasa al widget `MultiProvider` que envuelve toda la jerarquía de la aplicación dentro de la función `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frenchs_gold_erp/presentation/provider/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializaciones del sistema (WindowManager, Dotenv, Supabase, etc.)
  ...

  // Punto de arranque con MultiProvider
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'French Gold Erp',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: AppRoutes.router,
    );
  }
}
```

---

## Consumo de dependencias en UI

Para obtener instancias de los controladores o repositorios dentro de la capa de presentación (widgets, pantallas, callbacks):

### En callbacks de acciones (`onPressed`, `onSubmit`, etc.)
Utilizar `context.read<T>()` para obtener la instancia sin suscribirse a reconstrucciones:

```dart
void _onSubmitForm() {
  final controller = context.read<WarehouseController>();
  controller.createWarehouse(data);
}
```

### En el método `build` o `initState`
Si se requiere obtener el controlador durante el ciclo de vida del widget:

```dart
@override
void initState() {
  super.initState();
  _controller = context.read<WarehouseController>();
}
```

---

## Flujo de paso a paso para registrar una nueva dependencia

Seguir esta lista de verificación cada vez que se agregue una nueva entidad, repositorio o controlador:

- [ ] **1. Crear Repositorio y Controlador:** Asegurarse de que el controlador de dominio acepte sus dependencias a través del constructor.
- [ ] **2. Importar en `app_provider.dart`:** Importar las clases de repositorio y controlador en `lib/presentation/provider/app_provider.dart`.
- [ ] **3. Registrar Repositorio:** Agregar `Provider(create: (context) => XxxRepositoryImpl())` en el bloque de repositorios de `providers`.
- [ ] **4. Registrar Controller:** Agregar `Provider(create: (context) => XxxController(context.read<...>() ...))` resolviendo sus argumentos mediante `context.read<Type>()`.
- [ ] **5. Verificar `main.dart`:** Confirmar que `runApp` mantenga `MultiProvider(providers: providers, child: const MyApp())`.
- [ ] **6. Consumir en Presentation:** En los widgets de la pantalla, acceder a la dependencia usando `context.read<XxxController>()`.

---

## Reglas críticas y de arquitectura

1. **Orden Obligatorio de Registro:** Registrar siempre en el orden: Helpers -> Repositorios -> Controladores. De lo contrario, `context.read<T>()` fallará con un error de tipo `ProviderNotFoundException`.
2. **Pureza de Dominio:** Los controladores de dominio en `lib/domain/controllers/` deben ser **Dart puro**. No deben importar `package:provider` ni `package:flutter`. La inyección se resuelve en `app_provider.dart`.
3. **Inyección por Constructor:** Las dependencias deben ser solicitadas obligatoriamente en el constructor del controlador o repositorio.
4. **Verificación Obligatoria:** Antes de finalizar cualquier tarea, ejecutar `dart format lib/` y `flutter analyze` asegurando 0 errores y advertencias.

---

## Referencias

- Proveedores de la aplicación: [lib/presentation/provider/app_provider.dart](lib/presentation/provider/app_provider.dart)
- Punto de entrada: [lib/main.dart](lib/main.dart)
- Reglas generales del proyecto: [AGENTS.md](AGENTS.md)
- Skill Entidades CRUD: [french-gold-implementing-crud-entity](.agents/skills/french-gold-implementing-crud-entity/SKILL.md)
- Skill Formularios Reactivos: [french-gold-implementing-reactive-forms](.agents/skills/french-gold-implementing-reactive-forms/SKILL.md)
