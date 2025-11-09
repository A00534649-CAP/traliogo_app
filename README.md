# TrailoGo App

Una aplicación móvil para viajeros que permite reconocimiento de objetos, traducción de texto y más funcionalidades útiles para viajes.

## Características

- 🔐 **Autenticación**: Login y registro con Firebase
- 📷 **Reconocimiento de objetos**: Usa la cámara para identificar objetos
- 🔤 **Traducción de texto**: Manual, OCR y por voz
- 🔊 **Pronunciación**: Reproduce audio de traducciones
- 📚 **Historial**: Guarda traducciones y objetos reconocidos
- ⚙️ **Configuración**: Idiomas, tema y flags de funcionalidades

## Tecnologías

- **Flutter 3** con null safety
- **Firebase Auth** para autenticación
- **Riverpod** para manejo de estado
- **Go Router** para navegación
- **Dio** para llamadas HTTP
- **Material 3** para UI

## Configuración inicial

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Generar archivos de código
```bash
flutter packages pub run build_runner build
```

### 3. Configurar Firebase Service Account

**⚠️ PASO CRÍTICO para que funcione la autenticación**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Configuración del proyecto** → **Cuentas de servicio**
4. Haz clic en **Generar nueva clave privada**
5. Descarga el archivo JSON
6. **Renómbralo** a `firebase-service-account.json`
7. **Colócalo** en la raíz del proyecto (mismo nivel que `pubspec.yaml`)

```
traliogo_app/
├── android/
├── ios/
├── lib/
├── firebase-service-account.json  ← Aquí
├── pubspec.yaml
└── README.md
```

**🔒 Seguridad**: El archivo ya está en `.gitignore` - nunca lo subas a Git.

### 4. Configurar backend API

Asegúrate de que tu backend esté corriendo en `http://127.0.0.1:8080` con estos endpoints:

- `POST /api/v1/auth/login` - Login de usuarios
- `POST /api/v1/auth/verify-token` - Verificar tokens de Firebase
- `POST /api/v1/users` - Crear usuarios
- Y otros endpoints según [CLAUDE.md](CLAUDE.md)

## Ejecución

```bash
# Desarrollo
flutter run

# Para Android
flutter run -d android

# Para iOS  
flutter run -d ios
```

## Estructura del proyecto

```
lib/
├── api/                    # Capa de API y modelos
├── features/              # Funcionalidades por módulos
│   ├── auth/             # Autenticación
│   ├── home/             # Pantalla principal
│   └── ...
├── core/                 # Configuración base
├── providers/            # Proveedores de Riverpod
└── services/             # Servicios (Firebase, etc.)
```

## Arquitectura

Siguiendo **Clean Architecture**:

- **presentation/**: Widgets, controladores, view models
- **domain/**: Entidades, repositorios, casos de uso  
- **data/**: Fuentes de datos, implementaciones

## Verificar configuración

Puedes verificar que Firebase esté bien configurado:

```dart
final firebaseService = FirebaseAuthService();
final isConfigured = await firebaseService.isAdminServiceConfigured();
print('Firebase configurado: $isConfigured');
```

## Solución de problemas

### "firebase-service-account.json no encontrado"
- Verifica que el archivo esté en la raíz del proyecto
- Verifica que el nombre sea exactamente `firebase-service-account.json`

### "Connection error" en API calls
- Verifica que el backend esté corriendo en `http://127.0.0.1:8080`
- Verifica que los endpoints estén disponibles

### Build errors
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Documentación adicional

- [CLAUDE.md](CLAUDE.md) - Instrucciones detalladas para Claude Code
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuración completa de Firebase

## Getting Started con Flutter

Si es tu primer proyecto Flutter:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
