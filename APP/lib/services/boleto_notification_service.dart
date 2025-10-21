import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boleto.dart';
import '../services/asaas_service.dart';
import 'dart:convert';

class BoletoNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static Timer? _periodicTimer;
  static const String _lastCheckKey = 'last_boleto_check';
  static const String _notifiedBoletosKey = 'notified_boletos';

  /// Inicializar serviço de notificações de boletos
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

    await _notificationsPlugin.initialize(initializationSettings);
    
    print('✅ Serviço de notificações de boletos inicializado');
  }

  /// Iniciar monitoramento periódico de boletos
  static void startPeriodicCheck(String userCnpj) {
    // Verificar a cada 30 minutos
    _periodicTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkForNewBoletos(userCnpj);
      _checkDueBoletos(userCnpj);
    });
    
    // Fazer verificação inicial
    _checkForNewBoletos(userCnpj);
    _checkDueBoletos(userCnpj);
    
    print('📅 Monitoramento periódico de boletos iniciado');
  }

  /// Parar monitoramento periódico
  static void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    print('⏹️ Monitoramento periódico de boletos parado');
  }

  /// Verificar novos boletos
  static Future<void> _checkForNewBoletos(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString(_lastCheckKey);
      final DateTime lastCheck = lastCheckString != null 
          ? DateTime.parse(lastCheckString)
          : DateTime.now().subtract(const Duration(days: 1));

      final newBoletos = await AsaasService.checkNewBoletos(userCnpj, lastCheck);
      
      for (final boleto in newBoletos) {
        await _showNewBoletoNotification(boleto);
      }

      // Atualizar último check
      await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
      
      if (newBoletos.isNotEmpty) {
        print('🔔 ${newBoletos.length} novos boletos encontrados');
      }
    } catch (e) {
      print('❌ Erro ao verificar novos boletos: $e');
    }
  }

  /// Verificar boletos próximos do vencimento
  static Future<void> _checkDueBoletos(String userCnpj) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifiedBoletos = _getNotifiedBoletos(prefs);

      // Verificar boletos vencendo em 10, 5, 3 e 1 dias
      final dueDays = [10, 5, 3, 1];
      
      for (final days in dueDays) {
        final boletos = await AsaasService.getBoletosDueInDays(userCnpj, days);
        
        for (final boleto in boletos) {
          final notificationKey = '${boleto.id}_due_$days';
          if (!notifiedBoletos.contains(notificationKey)) {
            await _showDueBoletoNotification(boleto, days);
            notifiedBoletos.add(notificationKey);
          }
        }
      }

      // Verificar boletos vencidos
      final overdueBoletos = await AsaasService.getBoletosOverdue(userCnpj);
      for (final boleto in overdueBoletos) {
        final notificationKey = '${boleto.id}_overdue';
        if (!notifiedBoletos.contains(notificationKey)) {
          await _showOverdueBoletoNotification(boleto);
          notifiedBoletos.add(notificationKey);
        }
      }

      // Salvar boletos notificados
      await _saveNotifiedBoletos(prefs, notifiedBoletos);
      
    } catch (e) {
      print('❌ Erro ao verificar boletos vencendo: $e');
    }
  }

  /// Mostrar notificação de novo boleto
  static Future<void> _showNewBoletoNotification(Boleto boleto) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_boletos',
      'Novos Boletos',
      channelDescription: 'Notificações de novos boletos',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF8B5CF6),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'new_boletos',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      boleto.id.hashCode,
      '💰 Novo Boleto Disponível',
      '${boleto.valueFormatted} - Vence em ${boleto.dueDateFormatted}',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'new_boleto',
        'boleto_id': boleto.id,
      }),
    );
  }

  /// Mostrar notificação de boleto próximo do vencimento
  static Future<void> _showDueBoletoNotification(Boleto boleto, int days) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'due_boletos',
      'Boletos Vencendo',
      channelDescription: 'Notificações de boletos próximos do vencimento',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFF9800),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'due_boletos',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    String title;
    if (days == 1) {
      title = '⚠️ Boleto Vence Amanhã!';
    } else {
      title = '⏰ Boleto Vence em $days Dias';
    }

    await _notificationsPlugin.show(
      '${boleto.id}_due_$days'.hashCode,
      title,
      '${boleto.valueFormatted} - ${boleto.description ?? 'Boleto pendente'}',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'due_boleto',
        'boleto_id': boleto.id,
        'days': days,
      }),
    );
  }

  /// Mostrar notificação de boleto vencido
  static Future<void> _showOverdueBoletoNotification(Boleto boleto) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'overdue_boletos',
      'Boletos Vencidos',
      channelDescription: 'Notificações de boletos vencidos',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFF44336),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'overdue_boletos',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      '${boleto.id}_overdue'.hashCode,
      '🚨 Boleto Vencido!',
      '${boleto.valueFormatted} - Venceu em ${boleto.dueDateFormatted}',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'overdue_boleto',
        'boleto_id': boleto.id,
      }),
    );
  }

  /// Verificação manual de boletos (para pull-to-refresh)
  static Future<void> manualCheck(String userCnpj) async {
    await _checkForNewBoletos(userCnpj);
    await _checkDueBoletos(userCnpj);
  }

  /// Limpar notificações antigas
  static Future<void> clearOldNotifications() async {
    await _notificationsPlugin.cancelAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notifiedBoletosKey);
    
    print('🧹 Notificações antigas limpas');
  }

  /// Obter boletos já notificados
  static Set<String> _getNotifiedBoletos(SharedPreferences prefs) {
    final notifiedList = prefs.getStringList(_notifiedBoletosKey) ?? [];
    return Set.from(notifiedList);
  }

  /// Salvar boletos notificados
  static Future<void> _saveNotifiedBoletos(SharedPreferences prefs, Set<String> notifiedBoletos) async {
    await prefs.setStringList(_notifiedBoletosKey, notifiedBoletos.toList());
  }

  /// Agendar verificação diária
  static Future<void> scheduleDailyCheck(String userCnpj) async {
    // Cancelar agendamentos anteriores
    await _notificationsPlugin.cancelAll();

    // Agendar para 09:00 todos os dias
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_check',
      'Verificação Diária',
      channelDescription: 'Verificação diária de boletos',
      importance: Importance.low,
      priority: Priority.low,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Agendar verificação para as 09:00 de amanhã
    final tomorrow9AM = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 9,
      minute: 0,
      second: 0,
      millisecond: 0,
    );

    print('📅 Verificação diária agendada para ${tomorrow9AM.toString()}');
  }

  /// Notificação de resumo semanal
  static Future<void> showWeeklySummary(String userCnpj) async {
    try {
      final allBoletos = await AsaasService.getBoletosByDocument(userCnpj);
      final pendingBoletos = allBoletos.where((b) => b.status == 'PENDING').length;
      final overdueBoletos = allBoletos.where((b) => b.isOverdue).length;
      
      if (pendingBoletos > 0 || overdueBoletos > 0) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'weekly_summary',
          'Resumo Semanal',
          channelDescription: 'Resumo semanal de boletos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: Color(0xFF8B5CF6),
        );

        const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );

        await _notificationsPlugin.show(
          'weekly_summary'.hashCode,
          '📊 Resumo Semanal de Boletos',
          '$pendingBoletos pendentes, $overdueBoletos vencidos',
          platformChannelSpecifics,
        );
      }
    } catch (e) {
      print('❌ Erro ao gerar resumo semanal: $e');
    }
  }
}