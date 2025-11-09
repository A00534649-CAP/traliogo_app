# TrailoGo

Una aplicación móvil multiplataforma diseñada para viajeros que necesitan traducir texto, reconocer objetos y comunicarse efectivamente en diferentes idiomas.

## Características principales

- **Autenticación segura**: Sistema de login con verificación por código de 6 dígitos
- **Reconocimiento de objetos**: Identifica objetos usando la cámara del dispositivo
- **Traducción múltiple**: Soporta traducción manual, OCR desde imágenes y reconocimiento de voz
- **Pronunciación**: Reproduce audio de las traducciones para aprender la pronunciación correcta
- **Historial completo**: Almacena todas las traducciones y objetos reconocidos para consulta posterior
- **Configuración avanzada**: Personalización de idiomas, temas y configuraciones de funcionalidades

## Tecnologías utilizadas

- **Flutter 3.0+** con null safety para desarrollo multiplataforma
- **Riverpod** para manejo de estado reactivo
- **Go Router** para navegación declarativa
- **Dio** para comunicación HTTP con el backend
- **Material Design 3** para una interfaz moderna y consistente

## Requisitos del sistema

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / Xcode para desarrollo en dispositivos
- Backend API ejecutándose en puerto 8080

## Instalación y configuración

### 1. Clonar el repositorio y instalar dependencias

```bash
git clone <repository-url>
cd traliogo_app
flutter pub get
```

### 2. Generar archivos de código necesarios

```bash
dart run build_runner build
```

### 3. Configuración del backend

El proyecto requiere un backend REST API que proporcione los siguientes endpoints:

#### Autenticación
- `POST /api/v1/auth/login-with-password` - Login con email y contraseña
- `POST /api/v1/auth/complete-login` - Completar login con código de verificación
- `POST /api/v1/auth/forgot-password` - Solicitar código de recuperación
- `POST /api/v1/auth/verify-reset-code` - Verificar código de recuperación
- `POST /api/v1/auth/reset-password` - Cambiar contraseña con token

#### Usuarios
- `POST /api/v1/users` - Crear nuevo usuario
- `GET /api/v1/users/{id}` - Obtener información del usuario
- `PUT /api/v1/users/{id}` - Actualizar información del usuario

#### Traducciones
- `GET /api/v1/translations` - Obtener historial de traducciones
- `POST /api/v1/translations` - Guardar nueva traducción
- `DELETE /api/v1/translations/{id}` - Eliminar traducción

#### Reconocimiento de objetos
- `GET /api/v1/objects` - Obtener historial de objetos
- `POST /api/v1/objects` - Guardar objeto reconocido
- `DELETE /api/v1/objects/{id}` - Eliminar objeto

### 4. Configuración de la aplicación

Edita el archivo de configuración de API en `lib/api/api_client.dart` para apuntar a tu backend:

```dart
static const String baseUrl = 'http://your-backend-url:8080';
```

Para desarrollo local, usa:
- Android: `http://10.0.2.2:8080`
- iOS Simulator: `http://127.0.0.1:8080`

## Ejecución de la aplicación

```bash
# Ejecutar en modo desarrollo
flutter run

# Ejecutar en dispositivo Android específico
flutter run -d android

# Ejecutar en simulador iOS
flutter run -d ios

# Ejecutar en modo release
flutter run --release
```

## Estructura del proyecto

```
lib/
├── api/                    # Capa de comunicación con API
│   ├── models/            # Modelos de datos
│   ├── api_client.dart    # Cliente HTTP configurado
│   └── *_api.dart         # APIs específicas por funcionalidad
├── features/              # Funcionalidades organizadas por módulos
│   ├── auth/             # Sistema de autenticación
│   ├── home/             # Pantalla principal
│   ├── translation/      # Módulo de traducción
│   └── objects/          # Reconocimiento de objetos
├── core/                 # Configuración base y utilidades
│   ├── router/           # Configuración de rutas
│   └── theme/            # Tema y estilos
├── providers/            # Proveedores de estado global
└── services/             # Servicios externos
```

## Arquitectura

El proyecto sigue los principios de **Clean Architecture**:

- **Presentation Layer**: Widgets, páginas y controladores de estado
- **Domain Layer**: Entidades de negocio y casos de uso
- **Data Layer**: Repositorios e implementaciones de fuentes de datos

### Manejo de estado

Se utiliza **Riverpod** para el manejo de estado reactivo, proporcionando:
- Providers para estado global
- StateNotifiers para estado complejo con lógica de negocio
- Consumer widgets para reactividad en la UI

## Flujos de autenticación

### Registro de usuario
1. Usuario ingresa datos personales
2. Sistema envía código de verificación azul por email
3. Usuario ingresa código de 6 dígitos
4. Cuenta verificada, redirección a login

### Inicio de sesión
1. Usuario ingresa email y contraseña
2. Sistema valida credenciales
3. Si son correctas, envía código de verificación azul
4. Usuario ingresa código de 6 dígitos
5. Acceso completo al sistema

### Recuperación de contraseña
1. Usuario ingresa email
2. Sistema envía código de recuperación rojo
3. Usuario ingresa código de 6 dígitos
4. Sistema proporciona token de recuperación
5. Usuario establece nueva contraseña
6. Redirección a login

## Solución de problemas comunes

### Error de conexión con el backend
- Verificar que el backend esté ejecutándose
- Confirmar la URL correcta en la configuración
- Revisar conectividad de red

### Problemas de compilación
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Errores de dependencias
```bash
flutter pub deps
flutter pub upgrade
```

## Desarrollo y contribución

### Convenciones de código
- Utilizar nomenclatura en inglés para código
- Seguir las convenciones de Dart/Flutter
- Documentar funciones públicas
- Mantener archivos bajo 300 líneas cuando sea posible

### Testing
```bash
# Ejecutar pruebas unitarias
flutter test

# Ejecutar pruebas de integración
flutter test integration_test/
```

## Recursos adicionales

- [Documentación oficial de Flutter](https://docs.flutter.dev/)
- [Guía de Riverpod](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## Licencia

Este proyecto está bajo una licencia privada. Todos los derechos reservados.