---
name: flutter-managing-state
description: Gestiona el estado de la aplicación y el estado efímero en French Gold ERP usando Signals. Usar al compartir datos entre widgets o manejar transiciones de estado (carga, error, listas).
---

# Gestión de estado en Flutter (French Gold ERP)

## Contenido

- [Conceptos](#conceptos)
- [Arquitectura y flujo de datos](#arquitectura-y-flujo-de-datos)
- [Signals en el proyecto](#signals-en-el-proyecto)
- [Patrones de Carga (LoadState)](#patrones-de-carga-loadstate)
- [Validación de Formularios](#validación-de-formularios)
- [Controladores de Dominio](#controladores-de-dominio)
- [Cuándo usar cada enfoque](#cuándo-usar-cada-enfoque)

## Conceptos

La UI en Flutter es declarativa: refleja el estado actual de la app (`UI = f(estado)`). Cuando el
estado cambia, se reconstruye la UI que depende de ese estado.

- **Estado efímero (local):** Contenido en un solo widget (p. ej. valores de campos de texto,
  validaciones de formularios). Gestionar con señales locales en el `State` de un `StatefulWidget`.
- **Estado de aplicación (compartido):** Datos que persisten entre pantallas (usuario, compañía,
  listas globales). Gestionado en `lib/domain/controler/` mediante señales compartidas o
  controladores de dominio.

## Arquitectura y flujo de datos

El proyecto aplica **flujo unidireccional** y **una sola fuente de verdad**:

1. **UI**: Dispara una acción (ej. llamando a una función del controlador).
2. **Controlador (Domain)**: Ejecuta la lógica, interactúa con Repositorios y maneja transacciones
   usando `TransactionHelper` y `Mutex`.
3. **Señales/Modelos**: El controlador retorna un `DataModel` con el resultado o actualiza señales
   internas.
4. **UI**: Reacciona automáticamente a los cambios usando `watch(context)` o `SignalBuilder`.

## Signals en el proyecto

### Definición de Señales

```dart
// En el State de un widget para estado local
final _email = signal('');
final _isEmailValid = signal(false);

// En un controlador para estado compartido
final userList = signal<List<User>>([]);
```

### Consumo en UI

- **Watch**: `final list = userList.watch(context);` (reconstruye todo el `build`).
- **SignalBuilder**: `SignalBuilder(builder: (context) => ...)` (reconstrucción granular).

## Patrones de Carga (LoadState)

Para peticiones asíncronas, usar un modelo que encapsule el estado:

```dart
// 1. Modelo de datos en lib/domain/controler/
class GetDataModel<T> {
  final LoadState state;
  final T? data;
  final Object? error;
  const GetDataModel(this.state, {this.data, this.error});
}

// 2. Señal en la UI (lib/presentation/screens/...)
final _model = signal(GetDataModel<List<Item>>(LoadState.loading));

// 3. Cargar en initState
@override
void initState() {
  super.initState();
  fetchItems().then((v) => _model.value = v);
}

// 4. Switch exhaustivo en build
SignalBuilder(
  builder: (context) {
    final m = _model.value;
    return switch (m.state) {
      LoadState.loading => const CircularProgressIndicator(),
      LoadState.error => ErrorWidget(error: m.error),
      LoadState.completed => DataList(items: m.data!),
    };
  }
)
```

## Validación de Formularios

Usar señales para feedback instantáneo y deshabilitar botones:

```dart
onChanged: (value) {
  _email.value = value;
  _isEmailValid.value = EmailValidator.isValid(value);
}

// Botón reactivo
SignalBuilder(
  builder: (context) => CustomButton(
    onPressed: _isEmailValid.value && !isLoading.value ? () => submit() : null,
    text: 'Enviar',
  ),
)
```

## Controladores de Dominio

Deben ser **clases Dart puras** en `lib/domain/controler/`.

- **NO** importar `material.dart` o `get.dart`.
- Inyectar repositorios por constructor.
- Usar `signale` para logs.
- Manejar transacciones con `TransactionHelper`.

## Cuándo usar cada enfoque

- **Campos de entrada/Validación local**: Señales dentro del `State`.
- **Lógica de negocio/Acceso a datos**: `lib/domain/controler/` (Funciones o Clases puras).
- **Estado compartido**: Señales en controladores registrados vía `Bindings` y recuperados con
  `Get.find` en la ruta/constructor.

## Referencias

- `AGENTS.md`: Reglas Críticas (Signals, Mutex, Domain Purity).
- `lib/domain/controler/auth/create_company_controller.dart`: Ejemplo de lógica y modelos.
- `lib/presentation/screens/auth/create_company_screen/create_company_screen.dart`: Ejemplo de UI
  reactiva.
