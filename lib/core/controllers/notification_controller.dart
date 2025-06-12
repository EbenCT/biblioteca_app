// lib/core/controllers/notification_controller.dart

import '../services/local_notification_service.dart';
import '../../data/mock_data.dart';

class NotificationController {
  static NotificationController? _instance;
  NotificationController._internal();
  
  static NotificationController get instance {
    _instance ??= NotificationController._internal();
    return _instance!;
  }

  bool _isInitialized = false;

  // Inicializar cuando la app arranca
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Inicializando controlador de notificaciones');
    
    // Inicializar el servicio de notificaciones locales
    await LocalNotificationService.instance.initialize();
    
    // Verificar si hay préstamos próximos a vencer
    _checkAndScheduleNotifications();
    
    _isInitialized = true;
  }

  // Verificar préstamos y programar notificaciones
  void _checkAndScheduleNotifications() {
    final expiringSoon = MockData.getLoansExpiringSoon(daysThreshold: 3);
    
    print('📊 Préstamos próximos a vencer: ${expiringSoon.length}');
    
    if (expiringSoon.isNotEmpty) {
      final nextLoan = MockData.getNextExpiringLoan();
      
      if (nextLoan != null) {
        final daysLeft = nextLoan.dueDate.difference(DateTime.now()).inDays;
        print('⚠️ Préstamo "${nextLoan.bookTitle}" vence en $daysLeft días');
        
        // Iniciar temporizador de 10 segundos
        LocalNotificationService.instance.startLoanNotificationTimer();
      }
    } else {
      print('✅ No hay préstamos próximos a vencer');
    }
  }

  // Reiniciar para nueva sesión
  void resetForNewSession() {
    _isInitialized = false;
    LocalNotificationService.instance.resetForNewSession();
  }

  // Limpiar recursos
  void dispose() {
    LocalNotificationService.instance.dispose();
    _isInitialized = false;
  }
}