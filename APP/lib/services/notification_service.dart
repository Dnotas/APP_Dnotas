import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static Future<void> initialize() async {
    // Não inicializar notificações na web
    if (kIsWeb) {
      print('Notificações não disponíveis na web');
      return;
    }
    
    // Inicializar Firebase
    try {
      await Firebase.initializeApp();
      print('✅ Firebase inicializado');
      
      // Inicializar FCM
      await _initializeFCM();
    } catch (e) {
      print('❌ Erro ao inicializar Firebase: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permissões no iOS
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // Solicitar permissões no Android 13+
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    // TODO: Implementar navegação baseada no payload
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dnotas_channel',
      'DNOTAS Notifications',
      channelDescription: 'Notificações do app DNOTAS',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Notificação de nova mensagem
  static Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
  }) async {
    await showNotification(
      id: 1,
      title: 'Nova mensagem de $senderName',
      body: message,
      payload: 'chat',
    );
  }

  // Notificação de boleto vencendo
  static Future<void> showBoletoExpiringNotification({
    required String boletoNumber,
    required double amount,
    required int daysToExpire,
  }) async {
    await showNotification(
      id: 2,
      title: 'Boleto vencendo em $daysToExpire dias',
      body: 'Boleto $boletoNumber - R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
      payload: 'financial',
    );
  }

  // Notificação de relatório disponível
  static Future<void> showReportAvailableNotification({
    required String reportType,
  }) async {
    await showNotification(
      id: 3,
      title: 'Novo relatório disponível',
      body: '$reportType está pronto para download',
      payload: 'reports',
    );
  }

  // Notificação de NF-e processada
  static Future<void> showNFeProcessedNotification({
    required String nfeNumber,
    required String status,
  }) async {
    await showNotification(
      id: 4,
      title: 'NF-e $status',
      body: 'NF-e $nfeNumber foi $status com sucesso',
      payload: 'nfe',
    );
  }

  // Cancelar notificação específica
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancelar todas as notificações
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Verificar se notificações estão habilitadas
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false; // Web não suporta notificações locais
    
    if (Platform.isAndroid) {
      final bool? enabled = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    return true; // iOS sempre retorna true se permissão foi concedida
  }

  // Abrir configurações de notificação
  static Future<void> openNotificationSettings() async {
    if (kIsWeb) return; // Web não suporta
    
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'dnotas_channel',
              'DNOTAS Notifications',
              description: 'Notificações do app DNOTAS',
              importance: Importance.max,
            ),
          );
    }
  }

  // ===============================
  // FIREBASE CLOUD MESSAGING (FCM)
  // ===============================
  
  // Inicializar FCM
  static Future<void> _initializeFCM() async {
    try {
      // Solicitar permissões
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permissão FCM concedida');
      } else {
        print('❌ Permissão FCM negada');
        return;
      }
      
      // Obter token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔥 Token FCM: $_fcmToken');
      
      // Configurar handlers de mensagens
      _setupFCMHandlers();
      
    } catch (e) {
      print('❌ Erro ao inicializar FCM: $e');
    }
  }
  
  // Configurar handlers do FCM
  static void _setupFCMHandlers() {
    // Mensagens em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 FCM - Mensagem em primeiro plano: ${message.notification?.title}');
      
      // Mostrar notificação local quando app estiver em primeiro plano
      if (message.notification != null) {
        showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title ?? 'DNOTAS',
          body: message.notification!.body ?? 'Nova notificação',
          payload: jsonEncode(message.data),
        );
      }
    });
    
    // Mensagens quando app está em segundo plano (clique abre o app)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 FCM - App aberto por notificação: ${message.notification?.title}');
      _handleFCMNavigation(message.data);
    });
    
    // Verificar se app foi aberto por notificação (app estava fechado)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 FCM - App iniciado por notificação: ${message.notification?.title}');
        _handleFCMNavigation(message.data);
      }
    });
  }
  
  // Tratar navegação baseada nos dados da notificação
  static void _handleFCMNavigation(Map<String, dynamic> data) {
    final String? tipo = data['tipo'];
    
    if (tipo == 'relatorio_pronto') {
      print('🎯 Navegar para relatórios - ID: ${data['relatorio_id']}');
      // TODO: Implementar navegação
    }
  }
  
  // Registrar token FCM no backend
  static Future<void> registerFCMToken(String cnpj) async {
    if (_fcmToken == null) {
      print('❌ Token FCM não disponível');
      return;
    }
    
    try {
      const String apiUrl = 'https://api.dnotas.com.br:9999/api/fcm/register';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cnpj': cnpj,
          'fcm_token': _fcmToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Token FCM registrado no backend para CNPJ: $cnpj');
      } else {
        print('❌ Erro ao registrar token FCM: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao registrar token FCM: $e');
    }
  }
  
  // Obter token FCM
  static String? get fcmToken => _fcmToken;
  
  // Notificação específica para relatório pronto
  static Future<void> showReportReadyNotification({
    required String reportId,
    required String period,
  }) async {
    await showNotification(
      id: 999, // ID específico para relatórios
      title: '📊 Relatório Pronto!',
      body: 'Seu relatório de vendas ($period) está disponível para visualização.',
      payload: jsonEncode({
        'tipo': 'relatorio_pronto',
        'relatorio_id': reportId,
        'screen': 'reports'
      }),
    );
  }
}

// Handler para mensagens em background (deve ser função top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 FCM Background: ${message.notification?.title}');
}