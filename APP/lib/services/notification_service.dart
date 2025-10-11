import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
}