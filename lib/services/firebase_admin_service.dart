import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class FirebaseAdminService {
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _scope = 'https://www.googleapis.com/auth/firebase.messaging https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/firebase.database';
  
  Map<String, dynamic>? _serviceAccount;
  
  /// Carga el service account desde el archivo JSON
  Future<void> loadServiceAccount() async {
    try {
      // Carga desde assets
      final content = await rootBundle.loadString('firebase-service-account.json');
      _serviceAccount = json.decode(content);
      
      debugPrint('FIREBASE ADMIN: Service account cargado exitosamente');
      debugPrint('Project ID: ${_serviceAccount!['project_id']}');
      debugPrint('Client Email: ${_serviceAccount!['client_email']}');
      
    } catch (e) {
      debugPrint('FIREBASE ADMIN: Error cargando service account: $e');
      rethrow;
    }
  }
  
  /// Genera un JWT (JSON Web Token) para autenticación
  String _generateJWT() {
    if (_serviceAccount == null) {
      throw Exception('Service account no cargado. Llama loadServiceAccount() primero.');
    }
    
    final now = DateTime.now();
    final exp = now.add(const Duration(hours: 1));
    
    // Payload del JWT
    final payload = {
      'iss': _serviceAccount!['client_email'],
      'scope': _scope,
      'aud': _tokenUrl,
      'exp': (exp.millisecondsSinceEpoch / 1000).round(),
      'iat': (now.millisecondsSinceEpoch / 1000).round(),
    };
    
    // Usa la librería dart_jsonwebtoken para generar JWT con RSA256
    final privateKey = _serviceAccount!['private_key'] as String;
    final jwt = JWT(payload);
    final token = jwt.sign(RSAPrivateKey(privateKey), algorithm: JWTAlgorithm.RS256);
    
    return token;
  }
  
  /// Obtiene un access token de Firebase Admin
  Future<String> getAdminAccessToken() async {
    try {
      if (_serviceAccount == null) {
        await loadServiceAccount();
      }
      
      debugPrint('FIREBASE ADMIN: Generando access token...');
      
      final jwt = _generateJWT();
      
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        
        debugPrint('FIREBASE ADMIN: Access token obtenido exitosamente');
        debugPrint('Token: ${accessToken.substring(0, 20)}...');
        
        return accessToken;
      } else {
        debugPrint('FIREBASE ADMIN: Error obteniendo access token');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        throw Exception('Error obteniendo access token: ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('FIREBASE ADMIN: Error: $e');
      rethrow;
    }
  }
  
  /// Crea un custom token para un usuario específico
  Future<String> createCustomToken(String uid, {Map<String, dynamic>? claims}) async {
    try {
      if (_serviceAccount == null) {
        await loadServiceAccount();
      }
      
      debugPrint('FIREBASE ADMIN: Creando custom token para UID: $uid');
      
      final now = DateTime.now();
      final exp = now.add(const Duration(hours: 1));
      
      // Payload del custom token
      final payload = {
        'iss': _serviceAccount!['client_email'],
        'sub': _serviceAccount!['client_email'],
        'aud': 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
        'uid': uid,
        'exp': (exp.millisecondsSinceEpoch / 1000).round(),
        'iat': (now.millisecondsSinceEpoch / 1000).round(),
      };
      
      if (claims != null) {
        payload['claims'] = claims;
      }
      
      // Usa la librería dart_jsonwebtoken para generar custom token con RSA256
      final privateKey = _serviceAccount!['private_key'] as String;
      final jwt = JWT(payload);
      final customToken = jwt.sign(RSAPrivateKey(privateKey), algorithm: JWTAlgorithm.RS256);
      
      debugPrint('FIREBASE ADMIN: Custom token creado exitosamente');
      debugPrint('Token: ${customToken.substring(0, 20)}...');
      
      return customToken;
      
    } catch (e) {
      debugPrint('FIREBASE ADMIN: Error creando custom token: $e');
      rethrow;
    }
  }
  
  /// Verifica si el service account está cargado
  bool get isServiceAccountLoaded => _serviceAccount != null;
  
  /// Obtiene el project ID del service account
  String? get projectId => _serviceAccount?['project_id'];
  
  /// Obtiene el client email del service account
  String? get clientEmail => _serviceAccount?['client_email'];
}