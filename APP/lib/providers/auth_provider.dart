import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/boleto_notification_service.dart';
import '../services/webhook_service.dart';
import '../config/webhook_config.dart';
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
        print('Tentando criar UserModel com: $response');
        _currentUser = UserModel.fromJson(response);
        print('UserModel criado com sucesso: ${_currentUser?.nomeEmpresa}');
        
        // Registrar token FCM após login bem-sucedido
        if (_currentUser?.cnpj != null) {
          NotificationService.registerFCMToken(_currentUser!.cnpj);
          
          // Inicializar sistema de notificações de boletos
          await _initializeBoletoNotifications(_currentUser!.cnpj);
          
          // Configurar webhooks automaticamente
          await setupWebhooks();
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Login falhou - response é null');
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
      // Parar monitoramento de boletos
      BoletoNotificationService.stopPeriodicCheck();
      
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

  /// Inicializar notificações de boletos após login
  Future<void> _initializeBoletoNotifications(String userCnpj) async {
    try {
      // Inicializar serviço de notificações de boletos
      await BoletoNotificationService.initialize();
      
      // Iniciar monitoramento periódico
      BoletoNotificationService.startPeriodicCheck(userCnpj);
      
      // Fazer verificação inicial
      await BoletoNotificationService.manualCheck(userCnpj);
      
      print('✅ Sistema de notificações de boletos inicializado para $userCnpj');
    } catch (e) {
      print('❌ Erro ao inicializar notificações de boletos: $e');
    }
  }

  /// Verificar manualmente boletos (para pull-to-refresh)
  Future<void> checkBoletos() async {
    if (_currentUser?.cnpj != null) {
      await BoletoNotificationService.manualCheck(_currentUser!.cnpj);
    }
  }

  /// Limpar notificações antigas
  Future<void> clearOldNotifications() async {
    await BoletoNotificationService.clearOldNotifications();
  }

  /// Configurar webhooks automaticamente
  Future<void> setupWebhooks() async {
    if (_currentUser?.cnpj != null) {
      try {
        final webhookUrl = WebhookConfig.webhookUrl;
        
        // Determinar tipo de documento
        final cleanCnpj = _currentUser!.cnpj.replaceAll(RegExp(r'[^0-9]'), '');
        final isCpf = cleanCnpj.length == 11;
        
        // Só configurar webhook em produção ou se explicitamente solicitado
        if (WebhookConfig.isProd || WebhookConfig.isDev) {
          bool success;
          if (isCpf) {
            success = await WebhookService.setupCpfWebhook(webhookUrl);
          } else {
            success = await WebhookService.setupCnpjWebhook(webhookUrl);
          }
          
          if (success) {
            print('✅ Webhook configurado com sucesso para ${isCpf ? 'CPF' : 'CNPJ'}');
          } else {
            print('❌ Falha ao configurar webhook para ${isCpf ? 'CPF' : 'CNPJ'}');
          }
        } else {
          print('⚠️ Webhook não configurado - ambiente de desenvolvimento');
        }
      } catch (e) {
        print('❌ Erro ao configurar webhook: $e');
      }
    }
  }

  /// Listar webhooks existentes
  Future<List<Map<String, dynamic>>> getExistingWebhooks() async {
    if (_currentUser?.cnpj != null) {
      final cleanCnpj = _currentUser!.cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      final documentType = cleanCnpj.length == 11 ? 'cpf' : 'cnpj';
      
      return await WebhookService.listWebhooks(documentType);
    }
    
    return [];
  }

  /// Remover webhooks existentes
  Future<bool> removeWebhook(String webhookId) async {
    if (_currentUser?.cnpj != null) {
      final cleanCnpj = _currentUser!.cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      final documentType = cleanCnpj.length == 11 ? 'cpf' : 'cnpj';
      
      return await WebhookService.deleteWebhook(webhookId, documentType);
    }
    
    return false;
  }
}