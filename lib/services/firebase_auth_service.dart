import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_admin_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAdminService _adminService = FirebaseAdminService();

  User? get currentUser => _firebaseAuth.currentUser;
  
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('FIREBASE: Attempting to create user with email: $email');
      
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('FIREBASE: User created successfully!');
      debugPrint('User ID: ${userCredential.user?.uid}');
      debugPrint('Email: ${userCredential.user?.email}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'weak-password':
          throw Exception('La contraseña es muy débil');
        case 'email-already-in-use':
          throw Exception('Ya existe una cuenta con este email');
        case 'invalid-email':
          throw Exception('El email no es válido');
        default:
          throw Exception('Error al crear cuenta: ${e.message}');
      }
    } catch (e) {
      debugPrint('FIREBASE UNKNOWN ERROR: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('FIREBASE: Attempting to sign in with email: $email');
      
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('FIREBASE: Sign in successful!');
      debugPrint('User ID: ${userCredential.user?.uid}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No existe una cuenta con este email');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'invalid-email':
          throw Exception('El email no es válido');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        default:
          throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      debugPrint('FIREBASE UNKNOWN ERROR: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('FIREBASE: No user logged in');
        return null;
      }
      
      debugPrint('FIREBASE: Getting ID token for user: ${user.uid}');
      final idToken = await user.getIdToken(forceRefresh);
      if (idToken != null && idToken.length >= 20) {
        debugPrint('FIREBASE: ID token obtained: ${idToken.substring(0, 20)}...');
      } else {
        debugPrint('FIREBASE: ID token obtained (short token)');
      }
      
      return idToken;
    } catch (e) {
      debugPrint('FIREBASE: Error getting ID token: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('FIREBASE: Signing out user');
      await _firebaseAuth.signOut();
      debugPrint('FIREBASE: User signed out successfully');
    } catch (e) {
      debugPrint('FIREBASE: Error signing out: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        debugPrint('FIREBASE: Updating display name to: $displayName');
        await user.updateDisplayName(displayName);
        debugPrint('FIREBASE: Display name updated successfully');
      }
    } catch (e) {
      debugPrint('FIREBASE: Error updating display name: $e');
    }
  }

  /// Obtiene un access token de Firebase Admin usando service account
  Future<String?> getAdminAccessToken() async {
    try {
      debugPrint('FIREBASE: Getting admin access token...');
      return await _adminService.getAdminAccessToken();
    } catch (e) {
      debugPrint('FIREBASE: Error getting admin access token: $e');
      return null;
    }
  }

  /// Crea un custom token para un usuario usando Firebase Admin
  Future<String?> createCustomTokenForUser(String uid, {Map<String, dynamic>? claims}) async {
    try {
      debugPrint('FIREBASE: Creating custom token for user: $uid');
      return await _adminService.createCustomToken(uid, claims: claims);
    } catch (e) {
      debugPrint('FIREBASE: Error creating custom token: $e');
      return null;
    }
  }

  /// Crea un custom token para el usuario actual
  Future<String?> createCustomTokenForCurrentUser({Map<String, dynamic>? claims}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('FIREBASE: No current user for custom token');
      return null;
    }
    
    return await createCustomTokenForUser(user.uid, claims: claims);
  }

  /// Verifica si el admin service está configurado
  Future<bool> isAdminServiceConfigured() async {
    try {
      if (!_adminService.isServiceAccountLoaded) {
        await _adminService.loadServiceAccount();
      }
      return _adminService.isServiceAccountLoaded;
    } catch (e) {
      debugPrint('FIREBASE: Admin service not configured: $e');
      return false;
    }
  }

  /// Obtiene información del service account
  Future<Map<String, String?>> getServiceAccountInfo() async {
    try {
      if (!_adminService.isServiceAccountLoaded) {
        await _adminService.loadServiceAccount();
      }
      
      return {
        'project_id': _adminService.projectId,
        'client_email': _adminService.clientEmail,
      };
    } catch (e) {
      debugPrint('FIREBASE: Error getting service account info: $e');
      return {
        'project_id': null,
        'client_email': null,
      };
    }
  }
}