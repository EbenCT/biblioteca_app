// lib/config/app_config.dart
class AppConfig {
  // URLs del backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    //defaultValue: 'http://10.0.2.2:8080', // Android Emulator
    // defaultValue: 'http://localhost:8080', // iOS Simulator  
    defaultValue: 'http://192.168.100.4:8080', // Physical device
  );
  
  static const String graphqlEndpoint = '$baseUrl/graphql';
  
  // Configuración QR
  static const String qrEntradaPrefix = 'ENTRADA_';
  static const String qrSalidaPrefix = 'SALIDA_';
  static const String qrBibliotecaId = 'BIBLIOTECA_CENTRAL';
  
  // Configuración de la app
  static const String appName = 'Biblioteca App';
  static const String appVersion = '1.0.0';
  
  // Duración de tokens y sesiones
  static const Duration tokenRefreshInterval = Duration(minutes: 30);
  static const Duration sessionTimeout = Duration(hours: 8);
  
  // Configuración de notificaciones
  static const String notificationChannelId = 'biblioteca_notifications';
  static const String notificationChannelName = 'Biblioteca Notifications';
  static const String notificationChannelDescription = 'Notificaciones del sistema de biblioteca';
  
  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxLoginAttempts = 3;
  
  // Configuración QR Scanner
  static const double qrScanArea = 0.7; // 70% del área de la pantalla
  static const Duration qrScanTimeout = Duration(seconds: 30);
}