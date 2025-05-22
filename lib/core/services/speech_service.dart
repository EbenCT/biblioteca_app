// lib/core/services/speech_service.dart (versión simplificada y agresiva)

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/speech_locale_manager.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String? _spanishLocaleId;
  
  final StreamController<String> _textStreamController = 
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStatusController = 
      StreamController<bool>.broadcast();
  
  Stream<String> get textStream => _textStreamController.stream;
  Stream<bool> get listeningStatus => _listeningStatusController.stream;
  
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Solicitar permiso de micrófono
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('❌ Permiso de micrófono denegado');
      return false;
    }
    
    // Inicializar el speech-to-text
    _isInitialized = await _speech.initialize(
      onError: (error) => print('❌ Error de reconocimiento: $error'),
      onStatus: (status) {
        print('📡 Estado del reconocimiento: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          _listeningStatusController.add(false);
        }
      },
    );
    
    if (_isInitialized) {
      // Configuración forzada en español
      await SpeechLocaleManager.forceConfigure();
      _spanishLocaleId = await SpeechLocaleManager.getBestSpanishLocale();
      
      if (_spanishLocaleId != null) {
        print("✅ Configuración completada. Usando: $_spanishLocaleId");
      } else {
        print("⚠️ No se pudo configurar español. Revisar configuración del dispositivo.");
      }
    }
    
    return _isInitialized;
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    if (_isListening) {
      print("Ya está escuchando, ignorando solicitud");
      return;
    }
    
    print("🎤 Iniciando reconocimiento con configuración forzada de español...");
    
    // Forzar el uso del español con configuración más agresiva
    final success = await _forceSpanishRecognition();
    
    if (success) {
      _listeningStatusController.add(true);
      print("✅ Reconocimiento iniciado exitosamente en español");
    } else {
      print("❌ No se pudo iniciar el reconocimiento");
      _listeningStatusController.add(false);
    }
  }

  Future<bool> _forceSpanishRecognition() async {
    // Intentar primero con el español más común (España)
    final spanishLocales = ['es-ES', 'es_ES', 'es-MX', 'es_MX', 'es-US', 'es_US'];
    
    for (String locale in spanishLocales) {
      try {
        print("🇪🇸 Forzando reconocimiento con: $locale");
        
        final success = await _speech.listen(
          localeId: locale,
          onResult: (result) {
            if (result.finalResult) {
              final recognizedWords = result.recognizedWords;
              if (recognizedWords.isNotEmpty) {
                print("✅ ESPAÑOL reconocido ($locale): $recognizedWords");
                print("📊 Confianza: ${result.confidence}");
                
                // Verificar si aún parece inglés (esto no debería pasar)
                if (_isLikelyEnglish(recognizedWords)) {
                  print("⚠️ PROBLEMA: Texto en inglés con locale español $locale");
                  print("   Esto indica configuración incorrecta del dispositivo");
                }
                
                _textStreamController.add(recognizedWords);
              }
            }
          },
          listenFor: const Duration(seconds: 25),
          pauseFor: const Duration(seconds: 2),
          cancelOnError: false,
          partialResults: false,
        );
        
        if (success == true) {
          _isListening = true;
          _spanishLocaleId = locale; // Guardar el que funcionó
          print("✅ Éxito con locale: $locale");
          return true;
        } else {
          print("❌ Falló con locale: $locale");
        }
        
      } catch (e) {
        print("❌ Error con locale $locale: $e");
        continue;
      }
      
      // Pequeña pausa entre intentos
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    print("❌ Todos los locales españoles fallaron");
    return false;
  }

  // Método para detectar si el texto reconocido parece estar en inglés
  bool _isLikelyEnglish(String text) {
    final englishWords = [
      'battlefield', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'this', 'that', 'these', 'those', 'is', 'are', 'was',
      'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
      'would', 'could', 'should', 'can', 'may', 'might', 'must', 'shall'
    ];
    
    final words = text.toLowerCase().split(' ');
    int englishWordCount = 0;
    
    for (String word in words) {
      if (englishWords.contains(word)) {
        englishWordCount++;
      }
    }
    
    // Si más del 50% de las palabras son inglesas comunes, probablemente es inglés
    return words.isNotEmpty && (englishWordCount / words.length) > 0.5;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _listeningStatusController.add(false);
    }
  }

  void dispose() {
    stopListening();
    _textStreamController.close();
    _listeningStatusController.close();
  }
}