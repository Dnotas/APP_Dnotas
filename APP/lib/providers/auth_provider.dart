import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  String? _authToken;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  String? get token => _authToken ?? Supabase.instance.client.auth.currentSession?.accessToken;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Verificar se há um usuário logado
      if (SupabaseService.isAuthenticated) {
        _currentUser = await SupabaseService.getCurrentUserData();
      }
    } catch (e) {
      _errorMessage = 'Erro ao inicializar: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String cnpj,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Login direto com Supabase
      final response = await SupabaseService.signInWithCnpjAndPassword(
        cnpj: cnpj,
        password: password,
      );

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'CNPJ ou senha inválidos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String cnpj,
    required String nomeEmpresa,
    required String email,
    required String password,
    required String filialId,
    String? telefone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await SupabaseService.signUpWithCnpj(
        cnpj: cnpj,
        nomeEmpresa: nomeEmpresa,
        email: email,
        password: password,
        filialId: filialId,
        telefone: telefone,
      );

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao criar conta';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    return 'Erro: ${error.toString()}';
  }
}