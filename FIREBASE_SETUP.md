# Configuración de Firebase Service Account

Este documento explica cómo configurar el Firebase Service Account para generar tokens de autenticación en tu aplicación TrailoGo.

## ¿Qué es un Service Account?

Un Firebase Service Account te permite autenticarte con Firebase desde tu aplicación del lado del servidor o backend, lo cual es necesario para:

- Generar custom tokens de Firebase
- Acceder a Firebase Admin SDK
- Verificar tokens de ID desde tu backend
- Gestionar usuarios desde el lado del servidor

## Paso 1: Crear un Service Account en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto TrailoGo
3. Ve a **Configuración del proyecto** (ícono de engranaje)
4. Selecciona la pestaña **Cuentas de servicio**
5. Haz clic en **Generar nueva clave privada**
6. Se descargará un archivo JSON con tus credenciales

## Paso 2: Configurar el archivo en tu proyecto

1. **Renombra** el archivo descargado a: `firebase-service-account.json`
2. **Colócalo** en la raíz de tu proyecto Flutter (mismo nivel que `pubspec.yaml`)
3. **Verifica** que el archivo esté en `.gitignore` (ya está configurado)

```
tu-proyecto/
├── android/
├── ios/
├── lib/
├── firebase-service-account.json  ← Aquí
├── pubspec.yaml
└── README.md
```

## Paso 3: Estructura del archivo

Tu `firebase-service-account.json` debe tener esta estructura:

```json
{
  "type": "service_account",
  "project_id": "tu-project-id",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQ...tu-clave-privada...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@tu-project-id.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40tu-project-id.iam.gserviceaccount.com"
}
```

## Paso 4: Verificar la configuración

Puedes verificar que todo esté configurado correctamente usando el código en tu app:

```dart
final firebaseService = FirebaseAuthService();

// Verificar si está configurado
final isConfigured = await firebaseService.isAdminServiceConfigured();
print('Service account configured: $isConfigured');

// Obtener información
final info = await firebaseService.getServiceAccountInfo();
print('Project ID: ${info['project_id']}');
print('Client Email: ${info['client_email']}');
```

## Funciones disponibles

Una vez configurado, tendrás acceso a estas funciones:

### 1. Generar Admin Access Token
```dart
final adminToken = await firebaseService.getAdminAccessToken();
```

### 2. Crear Custom Token para usuario actual
```dart
final customToken = await firebaseService.createCustomTokenForCurrentUser();
```

### 3. Crear Custom Token para usuario específico
```dart
final customToken = await firebaseService.createCustomTokenForUser(
  'user-uid-here',
  claims: {'role': 'admin'}
);
```

## Seguridad 🔒

**⚠️ IMPORTANTE: Nunca subas el archivo `firebase-service-account.json` a Git**

- El archivo contiene credenciales sensibles
- Ya está incluido en `.gitignore`
- Si lo subes accidentalmente, regenera las credenciales inmediatamente

## Uso en tu aplicación

El service account se usa automáticamente en el flujo de registro:

1. Usuario se registra en Firebase Auth
2. Se obtiene el ID token del usuario
3. Se verifica el token con tu backend usando `POST /api/v1/auth/verify-token`
4. Si es válido, se crea el usuario en tu backend

## Solución de problemas

### Error: "firebase-service-account.json no encontrado"
- Verifica que el archivo esté en la raíz del proyecto
- Verifica que el nombre sea exactamente `firebase-service-account.json`

### Error: "Service account no válido"
- Verifica que el archivo JSON tenga la estructura correcta
- Regenera las credenciales en Firebase Console si es necesario

### Error: "Project ID no coincide"
- Verifica que el `project_id` en el archivo coincida con tu proyecto Firebase
- Verifica que estés usando el proyecto correcto en Firebase Console

## Archivos relacionados

- `lib/services/firebase_admin_service.dart` - Servicio para manejar el service account
- `lib/services/firebase_auth_service.dart` - Servicio principal de Firebase Auth
- `firebase-service-account.example.json` - Ejemplo de estructura del archivo
- `.gitignore` - Configurado para excluir el service account