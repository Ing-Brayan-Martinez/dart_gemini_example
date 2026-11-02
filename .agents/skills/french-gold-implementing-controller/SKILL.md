---
name: french-gold-implementing-controller
description: Guía paso a paso para crear controladores de dominio en French Gold ERP y conectarlos con las pantallas (Screens) y el contenedor de dependencias (Provider). Usar al implementar lógica de negocio, métodos CRUD o interacción entre UI y repositorios.
---

# Implementación de Controllers y relación con Screens y Provider (French Gold ERP)

## Contenido

- [Resumen de arquitectura y flujo](#resumen-de-arquitectura-y-flujo)
- [1. Creación del Controller de Dominio (Pure Dart)](#1-creación-del-controller-de-dominio-pure-dart)
- [2. Registro en Provider (app_provider.dart)](#2-registro-en-provider-app_providerdart)
- [3. Consumo en las Screens de Presentación](#3-consumo-en-las-screens-de-presentación)
  - [Lectura reactiva con Streams (WarehouseScreen)](#lectura-reactiva-con-streams-warehousescreen)
  - [Acción y envío de datos (CreateWarehouseScreen)](#acción-y-envío-de-datos-createwarehousescreen)
- [Flujo de implementación paso a paso](#flujo-de-implementación-paso-a-paso)
- [Reglas críticas y de arquitectura](#reglas-críticas-y-de-arquitectura)
- [Referencias](#referencias)

---

## Resumen de arquitectura y flujo

Los controladores de dominio encapsulan la lógica de negocio y actúan como intermediarios entre las fuentes de datos (repositorios) y la interfaz de usuario.

```
[ Interfaz de Usuario (Screens / Signals) ]
                      │
                      │ 1. context.read<XxxController>()
                      ▼
[ MultiProvider (app_provider.dart) ] ──► Inyecta dependencias
                      │
                      │ 2. Ejecuta operaciones / Emite cambios vía Stream
                      ▼
[ Controller de Dominio (Pure Dart) ]
                      │
                      │ 3. Consultas SQL / Manejo de transacciones
                      ▼
[ Repositorios (XxxRepositoryImpl) ] ──► Base de datos PostgreSQL
```

---

## 1. Creación del Controller de Dominio (Pure Dart)

- **Ubicación:** `lib/domain/controllers/<modulo>/<entidad>_controller.dart`.
- **Pureza de Dominio:** La clase debe ser **Dart puro**. Queda prohibido importar `package:flutter` o `package:get`.
- **Inyección por constructor:** Inyectar los helpers (`ContextHelper`, `TransactionHelper`) y los repositorios necesarios.
- **Gestión de estado mediante Streams:** Utilizar `BehaviorSubject` de `rxdart` para mantener el estado de lectura activo y exponer un `Stream`.

Ejemplo oficial de controlador (`WarehouseController`):

```dart
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';
import 'package:signale/signale.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repository/product_warehouse_repository.dart';
import '../../../data/repository/warehouse_repository.dart';
import '../../config/context_helper.dart';
import '../../config/enums.dart';
import '../../config/transaction_helper.dart';
import '../../model/wharehouse/warehouse.dart';

class WarehouseController {
  final ContextHelper _contextHelper;
  final TransactionHelper _transactionHelper;
  final WarehouseRepository _warehouseRepository;
  final ProductWarehouseRepository _productWarehouseRepository;

  // StreamSubject para exponer cambios a las pantallas
  final _subject = BehaviorSubject<GetWarehouseDataModel>.seeded(
    const GetWarehouseDataModel(LoadState.loading),
  );

  Stream<GetWarehouseDataModel> get warehouseStream => _subject.stream;

  WarehouseController(
    this._contextHelper,
    this._transactionHelper,
    this._warehouseRepository,
    this._productWarehouseRepository,
  );

  // Consulta de datos con emisión al Stream
  Future<void> getWarehouses() async {
    try {
      Log.i('getWarehouses()');
      if (_contextHelper.isNotValidContext) {
        throw Exception('Contexto de aplicación no válido');
      }

      final companyId = _contextHelper.companyId;
      final warehouses = await _warehouseRepository.findByCompanyID(companyId);
      final activeWarehouses = warehouses.where((w) => w.isActive).toList();
      activeWarehouses.sort((a, b) => a.name.compareTo(b.name));

      if (activeWarehouses.isEmpty) {
        _subject.add(const GetWarehouseDataModel(
          LoadState.empty,
          warehouseList: <Warehouse>[],
        ));
        return;
      }

      _subject.add(GetWarehouseDataModel(
        LoadState.completed,
        warehouseList: activeWarehouses,
      ));
    } catch (e) {
      Log.e(e);
      _subject.add(GetWarehouseDataModel(LoadState.error, error: e));
    }
  }

  // Operación de creación con transacción SQL y actualización del Stream
  Future<Warehouse> createWarehouse(CreateWarehouseInput data) async {
    try {
      Log.i('createWarehouse()');
      if (_contextHelper.isNotValidContext) {
        throw Exception('Contexto de aplicación no válido');
      }

      final companyId = _contextHelper.companyId;
      final now = DateTime.now();
      const uuid = Uuid();

      await _transactionHelper.dealLocated();
      await _transactionHelper.beginTransaction();

      final warehouse = Warehouse(
        uuid.v4(),
        companyId,
        true,
        now,
        now,
        data.nombre.trim(),
        data.direccion.trim(),
      );

      final Optional<Warehouse> result = await _warehouseRepository.create(warehouse);
      if (result.isEmpty) {
        throw Exception('No se pudo crear el almacén');
      }

      await _transactionHelper.commit();

      // Refrescar el stream automáticamente
      await getWarehouses();

      return result.first;
    } catch (e) {
      Log.e(e);
      await _transactionHelper.rollback();
      rethrow;
    }
  }
}
```

---

## 2. Registro en Provider (`app_provider.dart`)

En `lib/presentation/provider/app_provider.dart`, registrar la fábrica del controlador resolviendo sus dependencias mediante `context.read<T>()`:

```dart
Provider(
  create: (context) => WarehouseController(
    context.read<ContextHelperImpl>(),
    context.read<TransactionHelperImpl>(),
    context.read<WarehouseRepositoryImpl>(),
    context.read<ProductWarehouseRepositoryImpl>(),
  ),
),
```

---

## 3. Consumo en las Screens de Presentación

### Lectura reactiva con Streams (`WarehouseScreen`)

Para pantallas de consulta que reaccionan a cambios de datos emitidos por el controlador:

1. Obtener el controlador usando `context.read<WarehouseController>()`.
2. Suscribirse a `controller.warehouseStream` en `initState()`.
3. Almacenar el valor en una señal local `_model` y reconstruir mediante `SignalBuilder`.
4. Cancelar la suscripción en `dispose()`.

```dart
class _WarehouseScreenState extends State<WarehouseScreen> {
  StreamSubscription<GetWarehouseDataModel>? _warehouseSubscription;
  final _model = signal<GetWarehouseDataModel>(
    const GetWarehouseDataModel(LoadState.loading),
  );

  @override
  void initState() {
    super.initState();
    _subscribeToListStream();
    _loadData();
  }

  @override
  void dispose() {
    _warehouseSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToListStream() {
    final controller = context.read<WarehouseController>();
    _warehouseSubscription = controller.warehouseStream.listen(
      (value) {
        if (!mounted) return;
        _model.value = value;
      },
      onError: (error) {
        if (!mounted) return;
        _model.value = GetWarehouseDataModel(LoadState.error, error: error);
      },
    );
  }

  Future<void> _loadData() async {
    _model.value = const GetWarehouseDataModel(LoadState.loading);
    final controller = context.read<WarehouseController>();
    await controller.getWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignalBuilder(
        builder: (context) {
          final model = _model.value;
          return switch (model.state) {
            LoadState.loading => const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorWidget(error: model.error),
            LoadState.empty => const EmptyWidget(),
            LoadState.completed => ListView.builder(
                itemCount: model.warehouseList!.length,
                itemBuilder: (context, index) => WarehouseCard(
                  warehouse: model.warehouseList![index],
                ),
              ),
          };
        },
      ),
    );
  }
}
```

### Acción y envío de datos (`CreateWarehouseScreen`)

En formularios o pantallas de acción, obtener el controlador usando `context.read<XxxController>()` en el evento de envío (`_onSubmitForm`):

```dart
void _onSubmitForm() {
  isLoading.value = true;

  final data = CreateWarehouseInput(_name.value.trim(), _address.value.trim());
  final controller = context.read<WarehouseController>();

  controller
      .createWarehouse(data)
      .then((value) {
        if (!mounted) return;
        isLoading.value = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Almacén ${value.name} creado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        context.go(WarehouseScreen.routeName);
      })
      .catchError((e) {
        if (!mounted) return;
        isLoading.value = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
}
```

---

## Flujo de implementación paso a paso

- [ ] **1. Crear Controller de Dominio:** Escribir la clase pura Dart en `lib/domain/controllers/<modulo>/` solicitando dependencias por constructor.
- [ ] **2. Exponer Stream con BehaviorSubject:** Configurar un `BehaviorSubject` para propagar modelos de estado (`GetXxxDataModel`).
- [ ] **3. Implementar métodos CRUD:** Envolver mutaciones en transacciones (`beginTransaction`, `commit`, `rollback`) y llamar a `getEntities()` para refrescar el stream.
- [ ] **4. Registrar en `app_provider.dart`:** Añadir el `Provider` inyectando dependencias mediante `context.read<T>()`.
- [ ] **5. Conectar Pantalla de Consulta (Stream):** Suscribirse al stream en `initState()`, guardar eventos en un `signal()` y renderizar con `SignalBuilder`.
- [ ] **6. Conectar Pantalla de Acción (Formulario):** Invocación directa del controlador con `context.read<XxxController>()`, controlando `isLoading` y mostrando mensajes con `ScaffoldMessenger`.

---

## Reglas críticas y de arquitectura

1. **Pureza de Dominio:** Queda **estrictamente prohibido** importar `package:flutter` o `package:get` dentro de los controladores de dominio en `lib/domain/controllers/`.
2. **Inyección con Provider:** La vinculación entre controladores y UI debe realizarse exclusivamente a través de `Provider` con `context.read<XxxController>()`.
3. **Manejo de Transacciones y Logs:** Todas las operaciones de modificación en la base de datos deben utilizar `_transactionHelper` (`beginTransaction`, `commit`, `rollback`) y registrar eventos con `Log.i()` / `Log.e()`.
4. **Actualización Reactiva tras Mutaciones:** Todo método de creación, edición o eliminación en el controlador debe llamar al método de consulta (p. ej. `getWarehouses()`) para notificar automáticamente a los suscriptores del stream.
5. **Verificación Obligatoria:** Ejecutar `dart format lib/` y `flutter analyze` asegurando 0 errores y advertencias antes de concluir la tarea.

---

## Referencias

- Controller de referencia: [lib/domain/controllers/warehouse/warehouse_controller.dart](lib/domain/controllers/warehouse/warehouse_controller.dart)
- Registro de proveedores: [lib/presentation/provider/app_provider.dart](lib/presentation/provider/app_provider.dart)
- Pantalla de consulta (Stream): [lib/presentation/screens/warehouse/warehouse_screen/warehouse_screen.dart](lib/presentation/screens/warehouse/warehouse_screen/warehouse_screen.dart)
- Pantalla de formulario (Acción): [lib/presentation/screens/warehouse/create_warehouse_screen/create_warehouse_screen.dart](lib/presentation/screens/warehouse/create_warehouse_screen/create_warehouse_screen.dart)
- Reglas generales: [AGENTS.md](AGENTS.md)
- Skill Inyección con MultiProvider: [french-gold-implementing-provider](.agents/skills/french-gold-implementing-provider/SKILL.md)
