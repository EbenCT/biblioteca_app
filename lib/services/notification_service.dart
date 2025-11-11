// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Solicitar permisos
    await _requestPermissions();
    
    _initialized = true;
    print('📱 NotificationService inicializado correctamente');
  }

  // Solicitar permisos
  static Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Manejar tap en notificación
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    print('📱 Notificación tocada: ${notificationResponse.payload}');
    // Aquí puedes agregar navegación específica según el tipo de notificación
  }

  // Mostrar notificación inmediata
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'biblioteca_notifications',
      'Biblioteca Notifications',
      channelDescription: 'Notificaciones del sistema de biblioteca',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
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

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    print('📱 Notificación enviada: $title - $body');
  }

  // Función simplificada para programar notificaciones usando Timer
  static void scheduleNotificationWithTimer({
    required int id,
    required String title,
    required String body,
    required int delayInSeconds,
    String? payload,
  }) {
    Timer(Duration(seconds: delayInSeconds), () {
      showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    });
    
    print('📅 Notificación programada en ${delayInSeconds}s: $title');
  }

  // Simular notificaciones del backend después del login
  static Future<void> simulateBackendNotificationsAfterLogin() async {
    print('🚀 Iniciando simulación de notificaciones del backend...');

    // Notificación 1: Después de 10 segundos - Devolución de libro
    Timer(const Duration(seconds: 10), () {
      showNotification(
        id: 1,
        title: '📚 Recordatorio de Devolución',
        body: 'Se aproxima la fecha de devolución de tu libro prestado',
        payload: 'book_return_reminder',
      );
    });

    // Notificación 2: Después de 20 segundos - Recomendación de libro
    Timer(const Duration(seconds: 20), () {
      showNotification(
        id: 2,
        title: '💡 Recomendación para ti',
        body: 'Libro Don Quijote disponible - ¡Te podría interesar!',
        payload: 'book_recommendation',
      );
    });

    // Notificación 3: Después de 30 segundos - Recordatorio de acceso
    Timer(const Duration(seconds: 30), () {
      showNotification(
        id: 3,
        title: '🚪 Recordatorio de Acceso',
        body: 'No olvides marcar entrada y salida en la biblioteca',
        payload: 'access_reminder',
      );
    });

    print('⏰ Notificaciones programadas: 10s, 20s y 30s después del login');
  }

  // Cancelar todas las notificaciones programadas
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('🚫 Todas las notificaciones canceladas');
  }

  // Cancelar notificación específica
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('🚫 Notificación $id cancelada');
  }

  // Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Limpiar badge (iOS) - Función simplificada
  static Future<void> clearBadge() async {
    // Esta funcionalidad se puede agregar más tarde si es necesaria
    print('🔢 Badge limpiado (simulado)');
  }
}

// Extensión para facilitar tipos de notificaciones
extension NotificationTypes on NotificationService {
  // Notificación de préstamo próximo a vencer
  static Future<void> showLoanDueNotification(String bookTitle, int daysLeft) async {
    await NotificationService.showNotification(
      id: 100,
      title: '📚 Libro por Devolver',
      body: '$bookTitle debe ser devuelto en $daysLeft días',
      payload: 'loan_due_$bookTitle',
    );
  }

  // Notificación de recomendación de libro
  static Future<void> showBookRecommendation(String bookTitle, String author) async {
    await NotificationService.showNotification(
      id: 200,
      title: '💡 Recomendación para ti',
      body: '$bookTitle por $author - ¡Disponible ahora!',
      payload: 'recommendation_$bookTitle',
    );
  }

  // Notificación de recordatorio de acceso
  static Future<void> showAccessReminder() async {
    await NotificationService.showNotification(
      id: 300,
      title: '🚪 Recordatorio',
      body: 'No olvides marcar tu entrada y salida',
      payload: 'access_reminder',
    );
  }

  // Notificación cuando se marca entrada
  static Future<void> showEntryNotification(String userName) async {
    await NotificationService.showNotification(
      id: 400,
      title: '✅ Entrada Registrada',
      body: '¡Bienvenido/a $userName! Tu entrada ha sido registrada exitosamente',
      payload: 'entry_success',
    );
  }

  // Notificación cuando se marca salida
  static Future<void> showExitNotification(String userName, String duration) async {
    await NotificationService.showNotification(
      id: 500,
      title: '👋 Salida Registrada',
      body: '¡Hasta luego $userName! Tiempo en biblioteca: $duration',
      payload: 'exit_success',
    );
  }

  // Notificación de error en QR
  static Future<void> showQRErrorNotification(String error) async {
    await NotificationService.showNotification(
      id: 600,
      title: '❌ Error de Acceso',
      body: 'No se pudo procesar el código QR: $error',
      payload: 'qr_error',
    );
  }

  // Notificación de registro exitoso
  static Future<void> showRegistrationSuccessNotification(String userName) async {
    await NotificationService.showNotification(
      id: 700,
      title: '🎉 ¡Bienvenido/a!',
      body: '¡Hola $userName! Tu cuenta ha sido creada exitosamente',
      payload: 'registration_success',
    );
  }
}