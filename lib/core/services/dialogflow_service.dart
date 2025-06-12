// lib/core/services/dialogflow_service.dart
// REEMPLAZAR TODO EL CONTENIDO del archivo con esto:

import 'dart:async';
import '../../domain/repositories/repositories.dart';
import '../../di/injection_container.dart' as di;

class SimpleDialogflowService {
  final ChatRepository _chatRepository;
  final StreamController<Map<String, dynamic>> _responseStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onResponse => _responseStreamController.stream;

  SimpleDialogflowService() : _chatRepository = di.sl<ChatRepository>() {
    print("✅ SimpleDialogflowService inicializado con GraphQL + fallback local");
  }

  Future<void> detectIntent(String text) async {
    print("🎤 Procesando texto con Dialogflow GraphQL: $text");
    
    try {
      // Enviar mensaje al backend que tiene Dialogflow
      final result = await _chatRepository.sendMessage(text);
      
      result.fold(
        (failure) {
          print('❌ Error en Dialogflow: ${failure.message}');
          _responseStreamController.add({
            'action': 'ERROR',
            'message': 'No pude entender eso. ¿Podrías repetirlo?',
            'parameters': <String, dynamic>{}, // CORREGIDO: Tipo explícito
            'intent': 'Error',
            'confidence': 0.0,
            'success': false,
          });
        },
        (responseMessage) {
          print('✅ Respuesta de Dialogflow: $responseMessage');
          
          // CORREGIDO: Extraer acción del mensaje usando el formato "ACCION: mensaje"
          final action = _extractActionFromMessage(responseMessage);
          
          _responseStreamController.add({
            'action': action,
            'message': responseMessage,
            'parameters': <String, dynamic>{}, // CORREGIDO: Tipo explícito
            'intent': 'DialogflowIntent',
            'confidence': 1.0,
            'success': true,
          });
        },
      );
      
    } catch (e) {
      print('❌ Error en detectIntent: $e');
      _responseStreamController.add({
        'action': 'ERROR',
        'message': 'Ocurrió un error al procesar tu solicitud.',
        'parameters': <String, dynamic>{}, // CORREGIDO: Tipo explícito
        'intent': 'Error',
        'confidence': 0.0,
        'success': false,
      });
    }
  }

  // NUEVO: Método para extraer acción del formato "ACCION: mensaje"
  String _extractActionFromMessage(String message) {
    if (message.contains(':')) {
      final parts = message.split(':');
      if (parts.isNotEmpty) {
        final action = parts[0].trim().toUpperCase();
        print('🎯 Acción extraída del mensaje: $action');
        return action;
      }
    }
    
    // Si no hay ":", inferir de las palabras clave
    final inferredAction = _inferActionFromMessage(message);
    print('🎯 Acción inferida: $inferredAction');
    return inferredAction;
  }

  // MEJORADO: Método para inferir acción basado en palabras clave
  String _inferActionFromMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('bienvenido') || lowerMessage.contains('hola')) {
      return 'BIENVENIDA';
    } else if (lowerMessage.contains('búsqueda') || lowerMessage.contains('buscar') || lowerMessage.contains('buscar libros')) {
      return 'BUSCAR';
    } else if (lowerMessage.contains('préstamos') || lowerMessage.contains('prestamos')) {
      return 'PRESTAMOS';
    } else if (lowerMessage.contains('reservas')) {
      return 'RESERVAS';
    } else if (lowerMessage.contains('perfil')) {
      return 'PERFIL';
    } else if (lowerMessage.contains('categorías') || lowerMessage.contains('categorias')) {
      return 'CATEGORIAS';
    } else if (lowerMessage.contains('ayuda')) {
      return 'AYUDA';
    } else if (lowerMessage.contains('adiós') || lowerMessage.contains('hasta luego') || lowerMessage.contains('bye')) {
      return 'DESPEDIDA';
    }
    
    return 'RESPUESTA_INFORMATIVA';
  }
  
  void dispose() {
    _responseStreamController.close();
  }
}