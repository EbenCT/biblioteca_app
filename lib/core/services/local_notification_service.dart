// lib/core/services/local_notification_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static LocalNotificationService? _instance;
  LocalNotificationService._internal();
  
  static LocalNotificationService get instance {
    _instance ??= LocalNotificationService._internal();
    return _instance!;
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _notificationTimer;
  bool _hasShownNotification = false;
  bool _isInitialized = false;

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

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

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    _isInitialized = true;
    print('✅ Servicio de notificaciones locales inicializado');
  }

  // Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Iniciar temporizador de 10 segundos
  void startLoanNotificationTimer() {
    if (_hasShownNotification) {
      print('Notificación ya mostrada en esta sesión');
      return;
    }

    print('⏰ Iniciando temporizador de notificación (10 segundos)');
    
    _notificationTimer?.cancel();
    
    _notificationTimer = Timer(const Duration(seconds: 10), () {
      _showLoanDueNotification();
    });
  }

  // Mostrar notificación de préstamo por vencer
  Future<void> _showLoanDueNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    _hasShownNotification = true;
    print('🔔 Mostrando notificación de préstamo por vencer');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'loan_notifications',
      'Préstamos de Biblioteca',
      channelDescription: 'Notificaciones sobre préstamos próximos a vencer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFD32F2F),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1, // ID único de la notificación
      '📚 Préstamo por vencer',
      'Tienes un libro que vence en 2 días. ¡No olvides devolverlo!',
      notificationDetails,
      payload: 'loan_due_reminder',
    );
  }

  // Manejar cuando se toca la notificación
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    
    if (payload == 'loan_due_reminder') {
      print('🔔 Usuario tocó la notificación de préstamo');
      // Aquí podrías navegar a la página de préstamos si tienes acceso al navigator
    }
  }

  // Cancelar temporizador
  void cancelTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  // Reiniciar para nueva sesión
  void resetForNewSession() {
    _hasShownNotification = false;
    cancelTimer();
    print('🔄 Notificaciones reiniciadas para nueva sesión');
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Limpiar recursos
  void dispose() {
    cancelTimer();
  }
}