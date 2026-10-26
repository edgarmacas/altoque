# AGENTS.md — Reglas del proyecto AlToque

Este archivo lo leen los agentes de código (Claude Code, Codex, Antigravity…) al abrir este proyecto. Es el **archivo de contexto** del proyecto: lo que un agente nuevo necesita saber para trabajar bien aquí. Se mantiene corto, concreto y estructurado.

## Qué es el proyecto

AlToque es una aplicación móvil (Android) y web para la gestión personal de tareas y productividad con límite de trabajo en curso (WIP limits).
- **Estado de la aplicación:** Gestionado centralizadamente con **GetX** (`Obx`, `RxList`, `RxString`).
- **Persistencia remota:** Cliente HTTP con `Dio` contra un backend propio en **FastAPI** con autenticación JWT.
- **Persistencia local:** Cajas de **Hive** (`tareas_destacadas` y `tareas_cache`) con patrón «Hive guarda, Rx notifica».
- **Almacenamiento seguro:** Token de acceso persistido en `FlutterSecureStorage`.
- **Asistente de productividad:** Conectado al backend propio (`/asistente/consultar`) sin claves ni credenciales en el cliente móvil.
- **Calidad de diseño:** Interfaz corporativa limpia y profesional, sin emojis, basada en Material 3 con paleta vibrante en tonos turquesa/cian (`#1DCED8`, `#0E8E98`) y acento coral (`#FF467A`).

## Dónde está cada cosa

- `lib/controllers/` — Estado compartido de la aplicación (controladores GetX).
- `lib/services/` — Clientes de red (`ApiClient`, `AuthApiService`, `TareasApiService`, `AsistenteApiService`).
- `lib/repositories/` — Capa de datos y orquestación local/remota (`TareasRepository` con fallback a caché Hive).
- `lib/screens/` — Pantallas completas (`LoginScreen`, `RegistroScreen`, `HomeScreen`, `TareasScreen`, `DestacadasScreen`, `AsistenteScreen`, `PerfilScreen`, `TareaFormScreen`).
- `lib/widgets/` — Piezas de interfaz reutilizables (`TareaCard`, `LoadingView`, `EmptyView`, `ErrorView`, `ErrorPantallaView`).
- `lib/models/` y `lib/utils/` — Modelos inmutables (`Usuario`, `Tarea`, `MensajeChat`) y utilidades.
- `backend/` — API REST en FastAPI, base de datos SQLite y servidor de herramientas MCP.
- `test/` — Pruebas automatizadas unitarias, de integración y de widgets.
- `.github/workflows/` — Tuberías de CI (`ci.yml`) y CD para compilación de APK (`release-apk.yml`).

## Cómo verificar (siempre, antes de dar un cambio por terminado)

```bash
# Frontend Flutter
flutter analyze
flutter test

# Backend FastAPI (opcional si se modificó el backend)
cd backend && uv run pytest
```

Los comandos deben terminar con código 0 y sin errores ni advertencias. Si fallan, corrige el código; no desactives el análisis ni borres pruebas para forzar que pasen.

## Convenciones

- El estado compartido vive en un controlador GetX; las vistas nunca llaman directamente a APIs remotas ni a Hive.
- Todo texto visible para el usuario va en español neutro, claro y profesional.
- Toda pantalla interactiva con datos cubre los tres estados obligatorios: cargando (`CircularProgressIndicator`), vacío (vista amistosa) y error (`ErrorView` con reintento).
- Cada comportamiento nuevo va acompañado de su prueba automatizada correspondiente.
- No se utilizan emoticonos ni emojis; se emplean exclusivamente íconos vectoriales del catálogo de Material (`Icons.*`).

## Prohibido

- Escribir claves, tokens, secretos o contraseñas en el código, en registros de consola o en este archivo. Nunca leer ni modificar `.env`.
- Agregar dependencias nuevas sin avisar antes y justificar por qué hacen falta.
- Ejecutar `git push` o crear etiquetas de versión sin confirmación explícita de la persona a cargo.

## Reglas del estudiante

- Las tareas, filtros y métricas siempre se gestionan a través de `TareasController`; las pantallas observan reactivamente mediante `Obx` y nunca realizan mutaciones o filtrados independientes.
- Toda pantalla interactiva debe contemplar de forma explícita los tres estados UX: cargando, vacío con acción recomendada y error con botón de reintento.
- El asistente de productividad se comunica exclusivamente con el backend propio; el cliente Flutter nunca almacena ni transmite llaves de API externas.
