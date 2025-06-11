// lib/core/controllers/voice_chat_controller.dart (actualizado)

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
    // Añadir mensaje de bienvenida
    _addMessage(
      'Hola, soy el asistente virtual de la biblioteca UAGRM. ¿En qué puedo ayudarte?',
      false,
    );
    
    // Escuchar los mensajes del reconocimiento de voz
    _speechService.textStream.listen((text) {
      if (text.isNotEmpty) {
        _addMessage(text, true);
        _dialogflowService.detectIntent(text);
      }
    });
    
    // Escuchar las respuestas del servicio simple de DialogFlow
    _dialogflowService.onResponse.listen((response) {
      final message = response['message'];
      _addMessage(message, false);
      _ttsService.speak(message);
    });
  }
  
  void _addMessage(String text, bool isUser) {
    final message = VoiceChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    
    _messages.add(message);
    _messagesController.add(_messages);
  }
  
  void startListening() {
    _speechService.startListening();
  }
  
  void stopListening() {
    _speechService.stopListening();
  }
  
  void sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _addMessage(text, true);
    _dialogflowService.detectIntent(text);
  }
  
  void dispose() {
    _messagesController.close();
    _speechService.dispose();
    _ttsService.dispose();
    _dialogflowService.dispose();
  }
}