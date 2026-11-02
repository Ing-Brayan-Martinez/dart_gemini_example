---
name: french-gold-implementing-crud-entity
description: Guía paso a paso para implementar una entidad CRUD completa en French Gold ERP (tabla SQL, modelo de dominio BaseDocument, servicio PostgreSQL con Mutex y Optional, repositorio, controlador de dominio puro con Signals, Binding de GetX para DI y pantalla con GoRouter). Usar cuando se pida agregar una entidad, nueva tabla, módulo CRUD o recurso persistente.
---

# Crear entidad CRUD completa (French Gold ERP)

## Contenido

- [Resumen de arquitectura](#resumen-de-arquitectura)
- [Flujo de implementación](#flujo-de-implementación)
- [Paso a paso](#paso-a-paso)
  - [1. Tabla en PostgreSQL](#1-tabla-en-postgresql)
  - [2. Modelo de dominio](#2-modelo-de-dominio)
  - [3. Service PostgreSQL](#3-service-postgresql)
  - [4. Repository](#4-repository)
  - [5. Controller de dominio (Pure Dart)](#5-controller-de-dominio-pure-dart)
  - [6. Binding (GetX para DI)](#6-binding-getx-para-di)
  - [7. Screen y GoRouter](#7-screen-y-gorouter)
- [Reglas críticas y de arquitectura](#reglas-críticas-y-de-arquitectura)
- [Referencias](#referencias)

---

## Resumen de arquitectura

El flujo de datos para una entidad CRUD sigue una estricta separación por capas:

```
[ Presentation: Screen (StatefulWidget + Watch/SignalBuilder) ]
                               │
                               ▼
[ Domain: Controller (Pure Dart) ] ──► Signals State
                               │
                               ▼
[ Domain: Repository Interface / Models (BaseDocument) ]
                               ▲
                               │
[ Data: Repository Impl ] ──► [ Data: PostgreSqlService (Mutex + Optional) ] ──► PostgreSQL
```

---

## Flujo de implementación

Seguir este checklist en orden. Cada paso depende del anterior.

- [ ] **1. Tabla SQL:** Definir la tabla en [.github/sql/table.sql](.github/sql/table.sql) con convención `snake_case`, claves UUID y auditoría (`is_active`, `created_at`, `updated_at`).
- [ ] **2. Modelo de dominio:** Crear la clase en `lib/domain/model/<modulo>/<entidad>.dart` heredando de `BaseDocument` e implementando `fromJson`, `toListSave`, `toListUpdate`, `toMapSave` y `toMapUpdate`.
- [ ] **3. Service PostgreSQL:** Implementar el servicio en `lib/data/postgresql/service/<entidad>_postgresql_service.dart` utilizando `Mutex` para proteger cada consulta y `Optional<T>` para búsquedas unitarias.
- [ ] **4. Repository:** Definir la interfaz en la capa correspondiente e implementar la clase concreta en `lib/data/repository/<entidad>_repository.dart` delegando directamente al servicio.
- [ ] **5. Controller de dominio:** Crear la clase en `lib/domain/controllers/` usando **exclusivamente Dart puro** (sin importar Flutter ni GetX) e inyectando dependencias por constructor.
- [ ] **6. Screen y ruta:** Construir la interfaz reactiva con `SignalBuilder` o `Watch` de `signals_flutter` en `lib/presentation/screens/<modulo>/` y registrar la ruta en `lib/presentation/routes/app_routes.dart` usando `GoRouter`.

---

## Paso a paso

### 1. Tabla en PostgreSQL

- Añadir la definición en [.github/sql/table.sql](.github/sql/table.sql).
- **Convenciones obligatorias:**
  - Nombres de tabla y columnas en **snake_case** (p. ej. `currency_id`, `is_active`, `is_default`).
  - Identificador único UUID (`DEFAULT uuid_generate_v4()`).
  - Columnas estándar de auditoría: `is_active BOOLEAN DEFAULT TRUE`, `created_at TIMESTAMPTZ`, `updated_at TIMESTAMPTZ`.

Ejemplo SQL:
```sql
CREATE TABLE IF NOT EXISTS currency (
  currency_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  name VARCHAR(100) NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  value NUMERIC(18, 6) NOT NULL DEFAULT 1.0,
  is_default BOOLEAN NOT NULL DEFAULT FALSE
);
```

### 2. Modelo de dominio

- Ubicación: `lib/domain/model/<modulo>/<entidad>.dart`.
- La clase debe extender de **`BaseDocument`**.
- Implementar:
  - Constructor posicional.
  - Constructor nombrado `fromJson(Map<String, dynamic> json)` mapeando claves en **snake_case** con `PostgreSqlHelper`.
  - Métodos `toListSave()`, `toListUpdate()`, `toMapSave()` y `toMapUpdate()` mapeando atributos a **camelCase** para los parámetros nombrados de las consultas SQL (`Sql.named`).

Ejemplo de modelo:
```dart
import '../../config/base_document.dart';
import '../../config/postgresql_helper.dart';

class Currency extends BaseDocument {
  String currencyID;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String name;
  String symbol;
  double value;
  bool isDefault;

  Currency(
    this.currencyID,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.symbol,
    this.value,
    this.isDefault,
  );

  Currency.fromJson(Map<String, dynamic> json)
    : currencyID = json['currency_id'],
      isActive = PostgreSqlHelper.postgresToBoolean(json['is_active']),
      createdAt = PostgreSqlHelper.postgresToDate(json['created_at']),
      updatedAt = PostgreSqlHelper.postgresToDate(json['updated_at']),
      name = json['name'],
      symbol = json['symbol'],
      value = PostgreSqlHelper.postgresToDouble(json['value']),
      isDefault = PostgreSqlHelper.postgresToBoolean(json['is_default']);

  @override
  Map<String, dynamic> toMapSave() {
    return {
      'currencyID': currencyID,
      'isActive': PostgreSqlHelper.booleanToPostgres(isActive),
      'createdAt': PostgreSqlHelper.dateToPostgres(createdAt),
      'updatedAt': PostgreSqlHelper.dateToPostgres(updatedAt),
      'name': name,
      'symbol': symbol,
      'value': value,
      'isDefault': PostgreSqlHelper.booleanToPostgres(isDefault),
    };
  }

  @override
  Map<String, dynamic> toMapUpdate() {
    return {
      'isActive': PostgreSqlHelper.booleanToPostgres(isActive),
      'updatedAt': PostgreSqlHelper.dateToPostgres(updatedAt),
      'name': name,
      'symbol': symbol,
      'value': value,
      'isDefault': PostgreSqlHelper.booleanToPostgres(isDefault),
      'currencyID': currencyID,
    };
  }

  @override
  List toListSave() => [currencyID, isActive, createdAt, updatedAt, name, symbol, value, isDefault];

  @override
  List toListUpdate() => [isActive, updatedAt, name, symbol, value, isDefault, currencyID];
}
```

### 3. Service PostgreSQL

- Archivo: `lib/data/postgresql/service/<entidad>_postgresql_service.dart`.
- Definir interfaz: `abstract interface class XxxPostgreSqlService`.
- Definir implementación: `final class XxxPostgreSqlServiceImpl extends PostgreSqlBase implements XxxPostgreSqlService`.
- **Obligatorio:** Toda consulta a la base de datos DEBE protegerse con `Mutex`:
  `final Mutex _mutex = Mutex(); return _mutex.protect(() async { ... });`.
- Para búsquedas unitarias retornar `Optional<T>` de `package:optional`.
- Usar `Sql.named(query)` con parámetros nombrados.

Ejemplo de servicio:
```dart
import 'package:optional/optional.dart';
import 'package:postgres/postgres.dart';
import '../../../domain/config/mutex.dart';
import '../../../domain/config/postgresql_helper.dart';
import '../../../domain/model/auth/currency.dart';
import '../configuration/postgresql.dart';

abstract interface class CurrencyPostgreSqlService {
  Future<Optional<Currency>> create(Currency param);
  Future<Optional<Currency>> findByID(String currencyID);
  Future<List<Currency>> findAll();
}

final class CurrencyPostgreSqlServiceImpl extends PostgreSqlBase
    implements CurrencyPostgreSqlService {
  final Mutex _mutex = Mutex();

  @override
  Future<Optional<Currency>> findByID(String currencyID) async {
    return _mutex.protect(() async {
      final conn = await getDbConnection();
      const String query = '''
        SELECT * FROM currency
        WHERE currency_id = @currencyID AND is_active = TRUE;
      ''';

      final result = await conn.execute(
        Sql.named(query),
        parameters: {'currencyID': currencyID},
      );

      if (result.isEmpty) return const Optional.empty();

      final row = PostgreSqlHelper.createJson(result);
      return Optional.of(Currency.fromJson(row));
    });
  }

  @override
  Future<List<Currency>> findAll() async {
    return _mutex.protect(() async {
      final conn = await getDbConnection();
      const String query = '''
        SELECT * FROM currency
        WHERE is_active = TRUE
        ORDER BY name;
      ''';

      final result = await conn.execute(Sql.named(query));
      return result.map((ResultRow row) {
        return Currency.fromJson(PostgreSqlHelper.createJson2(result, row));
      }).toList();
    });
  }

  @override
  Future<Optional<Currency>> create(Currency param) async {
    return _mutex.protect(() async {
      final conn = await getDbConnection();
      const String query = '''
        INSERT INTO currency (
          currency_id, is_active, created_at, updated_at, name, symbol, value, is_default
        ) VALUES (
          @currencyID, @isActive, @createdAt, @updatedAt, @name, @symbol, @value, @isDefault
        );
      ''';

      await conn.execute(Sql.named(query), parameters: param.toMapSave());
      return findByID(param.currencyID);
    });
  }
}
```

### 4. Repository

- Archivo: `lib/data/repository/<entidad>_repository.dart`.
- Definir la interfaz `abstract interface class XxxRepository` y la implementación `final class XxxRepositoryImpl implements XxxRepository`.
- Inyectar o instanciar la dependencia del servicio PostgreSQL por constructor.
- Delegar las consultas directamente al servicio sin incluir lógica de negocio.

Ejemplo:
```dart
import 'package:optional/optional.dart';
import '../../domain/model/auth/currency.dart';
import '../postgresql/service/currency_postgresql_service.dart';

abstract interface class CurrencyRepository {
  Future<Optional<Currency>> create(Currency param);
  Future<Optional<Currency>> findByID(String currencyID);
  Future<List<Currency>> findAll();
}

final class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyPostgreSqlService _service;

  CurrencyRepositoryImpl([CurrencyPostgreSqlService? service])
      : _service = service ?? CurrencyPostgreSqlServiceImpl();

  @override
  Future<Optional<Currency>> create(Currency param) => _service.create(param);

  @override
  Future<Optional<Currency>> findByID(String currencyID) => _service.findByID(currencyID);

  @override
  Future<List<Currency>> findAll() => _service.findAll();
}
```

### 5. Controller de dominio (Pure Dart)

- Ubicación: `lib/domain/controllers/<modulo>/<entidad>_controller.dart`.
- **REGLA DE ORO:** La clase debe ser **Dart puro**. Queda **estrictamente prohibido** importar `package:flutter` o `package:get`.
- Inyectar helpers (`ContextHelper`, `TransactionHelper`) y repositorios por constructor.
- Utilizar `Log.i()`, `Log.e()` para el registro unificado con Signale.

Ejemplo:
```dart
import 'package:optional/optional.dart';
import 'package:signale/signale.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repository/currency_repository.dart';
import '../../config/context_helper.dart';
import '../../config/enums.dart';
import '../../config/transaction_helper.dart';
import '../../model/auth/currency.dart';

class CurrencyDataModel {
  final LoadState state;
  final List<Currency>? currencies;
  final Object? error;

  const CurrencyDataModel(this.state, {this.currencies, this.error});
}

class CurrencyController {
  final ContextHelper _contextHelper;
  final TransactionHelper _transactionHelper;
  final CurrencyRepository _currencyRepository;

  CurrencyController(
    this._contextHelper,
    this._transactionHelper,
    this._currencyRepository,
  );

  Future<CurrencyDataModel> getCurrencies() async {
    try {
      Log.i('getCurrencies()');
      if (_contextHelper.isNotValidContext) {
        throw Exception('Contexto de aplicación no válido');
      }
      final currencies = await _currencyRepository.findAll();
      return CurrencyDataModel(LoadState.completed, currencies: currencies);
    } catch (e) {
      Log.e(e);
      return CurrencyDataModel(LoadState.error, error: e);
    }
  }
}
```

### 6. Screen y GoRouter

- Pantalla: `lib/presentation/screens/<modulo>/<nombre>_screen/<nombre>_screen.dart`.
- Usar `StatefulWidget` con `SignalBuilder` o `Watch` de `package:signals_flutter/signals_flutter.dart` para manejo de estado reactivo.
- **PROHIBIDO:** Usar `Obx`, `Rx` o `GetxController` para estado en UI.
- Registrar la ruta en `lib/presentation/routes/app_routes.dart` con `GoRouter`.

Ejemplo de Pantalla:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../domain/config/enums.dart';
import '../../../../domain/controllers/settings/currency_controller.dart';

class CurrencyScreen extends StatefulWidget {
  static const String routeName = '/currencies';

  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  late final CurrencyController _controller;
  final _model = signal<CurrencyDataModel>(const CurrencyDataModel(LoadState.loading));

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CurrencyController>();
    _loadData();
  }

  Future<void> _loadData() async {
    _model.value = await _controller.getCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monedas')),
      body: SignalBuilder(
        builder: (context) {
          final model = _model.value;
          return switch (model.state) {
            LoadState.loading => const Center(child: CircularProgressIndicator()),
            LoadState.error => Center(child: Text('Error: ${model.error}')),
            LoadState.completed => ListView.builder(
                itemCount: model.currencies?.length ?? 0,
                itemBuilder: (context, index) {
                  final currency = model.currencies![index];
                  return ListTile(
                    title: Text(currency.name),
                    subtitle: Text(currency.symbol),
                  );
                },
              ),
          };
        },
      ),
    );
  }
}
```

Ruta en `app_routes.dart`:
```dart
GoRoute(
  path: CurrencyScreen.routeName,
  builder: (context, state) => const CurrencyScreen(),
),
```

---

## Reglas críticas y de arquitectura

1. **Mutex en PostgreSQL:** Todos los métodos de servicios PostgreSQL DEBEN estar protegidos con `_mutex.protect(() async { ... })` para prevenir colisiones de conexión.
2. **Signals para Estado:** Estado gestionado **únicamente** con `Signals` (`signal()`, `computed()`, `SignalBuilder`, `Watch`). Prohibido usar `Rx`, `Obx` o `GetxController`.
3. **Pureza de Dominio:** Los controladores en `lib/domain/controllers/` deben ser **Dart puro**. Prohibido importar `package:flutter` o `package:get` en esta capa.
4. **DI por Constructor:** Repositorios, Servicios y Controllers inyectan sus dependencias por constructor.
5. **GetX Exclusivo para DI:** GetX solo se usa mediante `Bindings` para inyección de dependencias (`Get.put`, `Get.find`, `Get.lazyPut`).
6. **Logging Unificado:** Usar `Log.i()`, `Log.e()`, `Log.d()` de `Signale` en lugar de `print()` o `debugPrint()`.
7. **Verificación Obligatoria:** Ejecutar `dart format lib/` y `flutter analyze` para asegurar 0 errores/advertencias antes de dar por completada cualquier tarea.

---

## Referencias

- Instrucciones generales del proyecto: [AGENTS.md](AGENTS.md)
- Skill Mapeo PostgreSQL-Dart: [french-gold-postgresql-dart-mapping](.agents/skills/french-gold-postgresql-dart-mapping/SKILL.md)
- Skill Consultas PostgreSQL: [french-gold-postgresql-queries](.agents/skills/french-gold-postgresql-queries/SKILL.md)
- Skill Gestión de Estado con Signals: [flutter-managing-state](.agents/skills/flutter-managing-state/SKILL.md)
- Skill Navegación y Enrutamiento: [french-gold-implementing-navigation-and-routing](.agents/skills/french-gold-implementing-navigation-and-routing/SKILL.md)
