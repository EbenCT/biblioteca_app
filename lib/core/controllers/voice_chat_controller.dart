// lib/core/controllers/voice_chat_controller.dart (CORREGIDO)

import 'dart:async';
import '../services/dialogflow_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

class VoiceChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  VoiceChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class VoiceChatController {
  final SpeechService _speechService;
  final SimpleDialogflowService _dialogflowService;
  final TTSService _ttsService;
  
  final List<VoiceChatMessage> _messages = [];
  final StreamController<List<VoiceChatMessage>> _messagesController = 
      StreamController<List<VoiceChatMessage>>.broadcast();
  
  Stream<List<VoiceChatMessage>> get messagesStream => _messagesController.stream;
  List<VoiceChatMessage> get messages => List.unmodifiable(_messages);
  
  VoiceChatController({
    required SpeechService speechService,
    required SimpleDialogflowService dialogflowService,
    required TTSService ttsService,
  }) : _speechService = speechService,
       _dialogflowService = dialogflowService,
       _ttsService = ttsService {
    _initialize();
  }
  
  void _initialize() {
    print('🎯 Inicializando VoiceChatController con Dialogflow directo');
    
    // Añadir mensaje de bienvenida
    _addMessage(
      'Hola, soy el asistente virtual de la biblioteca UAGRM. ¿En qué puedo ayudarte?',
      false,
    );
    
    // Escuchar los mensajes del reconocimiento de voz
    _speechService.textStream.listen((text) {
      if (text.isNotEmpty) {
        print('🗣️ Texto reconocido: $text');
        _addMessage(text, true);
        _dialogflowService.detectIntent(text);
      }
    });
    
    // CORREGIDO: Escuchar las respuestas de DialogFlow y procesar correctamente
    _dialogflowService.onResponse.listen((response) {
      final String fullMessage = response['message'] ?? '';
      final String action = response['action'] ?? '';
      
      print('🤖 Respuesta de DialogFlow:');
      print('   Mensaje completo: $fullMessage');
      print('   Acción detectada: $action');
      
      // CORREGIDO: Mostrar solo el mensaje limpio en el chat (sin la palabra clave)
      String displayMessage = fullMessage;
      
      // Si el mensaje contiene ":", separar acción del mensaje real
      if (fullMessage.contains(':')) {
        final parts = fullMessage.split(':');
        if (parts.length > 1) {
          displayMessage = parts[1].trim(); // Solo la parte después de ":"
        }
      }
      
      // Agregar mensaje al chat (solo el mensaje limpio)
      _addMessage(displayMessage, false);
      
      // CORREGIDO: Reproducir el mensaje y ESPERAR a que termine antes de seguir
      _speakMessageAndWait(displayMessage);
    });
  }
  
  // NUEVO: Método para reproducir mensaje y esperar
  Future<void> _speakMessageAndWait(String message) async {
    try {
      // Parar cualquier reconocimiento de voz mientras se reproduce
      if (_speechService.isListening) {
        _speechService.stopListening();
      }
      
      // Reproducir mensaje y esperar a que termine
      await _ttsService.speak(message);
      
      // Agregar un pequeño delay para asegurar que terminó
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('🔊 TTS completado para: $message');
      
    } catch (e) {
      print('❌ Error en TTS: $e');
    }
  }
  
  void _addMessage(String text, bool isUser) {
    final message = VoiceChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    
    _messages.add(message);
    _messagesController.add(_messages);
    
    print('💬 Mensaje añadido: ${isUser ? "Usuario" : "Asistente"}: $text');
  }
  
  void startListening() {
    print('🎤 Iniciando escucha de voz...');
    _speechService.startListening();
  }
  
  void stopListening() {
    print('🔇 Deteniendo escucha de voz...');
    _speechService.stopListening();
  }
  
  void sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    
    print('📝 Enviando mensaje de texto: $text');
    _addMessage(text, true);
    _dialogflowService.detectIntent(text);
  }
  
  void dispose() {
    print('🗑️ Limpiando VoiceChatController...');
    _messagesController.close();
    _speechService.dispose();
    _ttsService.dispose();
    _dialogflowService.dispose();
  }
}