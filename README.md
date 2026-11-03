# Gemini Chat en Flutter

Aplicación de chat multiplataforma desarrollada con Flutter que permite
conversar con la API de Gemini. El usuario configura su propia clave de API,
que se guarda localmente en el dispositivo y se utiliza para iniciar una
conversación.

La aplicación organiza el inicio, la configuración de la clave y el chat en
pantallas separadas. GoRouter gestiona la navegación, Provider inyecta los
controladores y Signals expone el estado de las operaciones del dominio.

## Características

- Configurar, guardar y volver a cargar una clave de Gemini por dispositivo.
- Enviar mensajes y mantener el contexto de la conversación mientras el chat
  está abierto.
- Mostrar el historial, el indicador de respuesta y los errores de red.
- Inicializar el dispositivo y dirigir al usuario al chat o a la configuración
  de la clave según su estado.
- Persistir los datos del dispositivo y la clave en una base de datos SQLite
  local.
- Navegar entre las pantallas de inicio, configuración de clave y chat con
  GoRouter.
- Gestionar estados de carga, éxito y error mediante Signals.

## Arquitectura

```text
lib/
├── data/
│   └── database/
│       ├── configuration/  # Apertura de SQLite y creación de tablas
│       └── repository/     # Persistencia local del dispositivo
├── domain/
│   ├── config/              # Dispositivo, SQLite, enums y tipos
│   ├── controller/          # Controladores de inicio y clave API con Signals
│   └── model/               # Dispositivo y estado asíncrono
└── presentation/
    ├── provider/            # Inyección de dependencias con Provider
    ├── routes/              # Rutas y transiciones con GoRouter
    ├── screen/              # Inicio, clave API y chat
    ├── theme/               # Tema y estilos
    └── widget/              # Componentes de chat, mensajes e imágenes
```

Los controladores de dominio son clases Dart que utilizan Signals y reciben el
repositorio por constructor. La interfaz observa su estado con
`signals_flutter`. El chat consume la API de Gemini y mantiene su historial en
memoria durante la sesión actual.

## API de Gemini

Antes de usar la aplicación, crea una clave en
[Google AI Studio](https://aistudio.google.com/app/apikey) y configúrala desde
la pantalla de conexión. La clave se almacena en la base de datos SQLite local
del dispositivo; no la incluyas en el código ni la subas al repositorio.

La integración actual utiliza `google_generative_ai` y el modelo
`gemini-3.6-flash`. La biblioteca de Gemini usada por Flutter está obsoleta y
ya no recibe mantenimiento; consulta la
[guía oficial de bibliotecas Gemini](https://ai.google.dev/gemini-api/docs/libraries)
antes de desplegar la integración en producción y considera migrar a Firebase
AI Logic.

## Requisitos

- Flutter SDK instalado.
- Dart SDK `>=3.5.0 <4.0.0`, según `pubspec.yaml`.
- Una clave de API de Gemini para enviar mensajes.

## Desarrollo

Instala las dependencias y verifica el formato, el análisis estático y las
pruebas:

```bash
flutter pub get
dart format lib/ test/
flutter analyze
flutter test
```

Para iniciar la aplicación en el dispositivo disponible:

```bash
flutter run
```
