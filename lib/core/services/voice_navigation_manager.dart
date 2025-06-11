// lib/core/services/voice_navigation_manager.dart (actualizado)

import 'package:biblio_app/core/services/dialogflow_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/book/book_bloc.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../utils/device_config_checker.dart';
import '../utils/permission_handler.dart';
import '../../app.dart'; // Importar para acceder al navigatorKey

class VoiceNavigationManager {
  final SpeechService _speechService;
  final SimpleDialogflowService _dialogflowService;
  final TTSService _ttsService;
  final BuildContext _context;
  
  bool _isActive = false;
  
  VoiceNavigationManager(this._context)
      : _speechService = SpeechService(),
        _dialogflowService = SimpleDialogflowService(),
        _ttsService = TTSService() {
    _initialize();
  }
  
  bool get isActive => _isActive;
  Stream<bool> get listeningStatus => _speechService.listeningStatus;

  Future<void> _initialize() async {
    // Mostrar guía de configuración en los logs
    print("🔧 Iniciando configuración de reconocimiento de voz...");
    
    // Inicializar el servicio de reconocimiento de voz
    final speechInitialized = await _speechService.initialize();
    if (!speechInitialized) {
      print("❌ No se pudo inicializar el servicio de voz");
      return;
    }
    
    // Verificar permiso de micrófono
    final hasPermission = await AppPermissionHandler.requestMicrophonePermission(_context);
    if (!hasPermission) {
      print("❌ Permiso de micrófono no concedido");
      return;
    }
    
    // Suscribirse al stream del reconocimiento de voz
    _speechService.textStream.listen((text) {
      if (text.isNotEmpty) {
        _processVoiceCommand(text);
      }
    });
    
    // Suscribirse al stream de respuestas del servicio simple de DialogFlow
    _dialogflowService.onResponse.listen((response) {
      _handleDialogflowResponse(response);
    });
    
    print("✅ Configuración de voz completada con servicio local");
  }
  
  void toggleListening() {
    if (_speechService.isListening) {
      _speechService.stopListening();
      _isActive = false;
      _ttsService.stop(); // Parar TTS si está hablando
    } else {
      _startListeningWithDelay();
    }
  }
  
  // Método para coordinar TTS y Speech Recognition
  Future<void> _startListeningWithDelay() async {
    _isActive = true;
    
    // 1. Primero parar cualquier TTS que esté reproduciéndose
    await _ttsService.stop();
    
    // 2. Reproducir mensaje de confirmación y esperar a que termine
    await _ttsService.speak("Te escucho");
    
    // 3. Inmediatamente después de que termine el TTS, iniciar reconocimiento
    print("🎤 Iniciando reconocimiento inmediatamente después del TTS");
    await _speechService.startListening();
    
    // 4. Verificar si realmente inició después de un momento breve
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_speechService.isListening) {
      print("❌ El reconocimiento no inició, reintentando una vez...");
      await Future.delayed(const Duration(milliseconds: 300));
      await _speechService.startListening();
    }
  }
  
  void _processVoiceCommand(String text) {
    // Verificar si el texto parece inglés (problema común)
    if (_isTextEnglish(text)) {
      print("🚨 DETECTADO TEXTO EN INGLÉS: $text");
      DeviceConfigChecker.printConfigurationGuide();
      _ttsService.speak("He detectado que reconocí en inglés. Por favor revisa la configuración de idioma de tu dispositivo.");
      return;
    }
    
    // Enviar el texto en español al servicio simple de DialogFlow
    _dialogflowService.detectIntent(text);
  }
  
  bool _isTextEnglish(String text) {
    final englishIndicators = [
      'battlefield', 'over me better feel', 'i said', 'the', 'and', 'or', 'but',
      'said', 'me', 'better', 'feel', 'over'
    ];
    
    final lowerText = text.toLowerCase();
    
    for (String indicator in englishIndicators) {
      if (lowerText.contains(indicator)) {
        return true;
      }
    }
    
    return false;
  }
  
  void _handleDialogflowResponse(Map<String, dynamic> response) {
    final String action = response['action'];
    final message = response['message'];
    final parameters = response['parameters'];
    
    print("Acción a ejecutar: $action");
    print("Mensaje: $message");
    print("Parámetros: $parameters");
    
    // Dar feedback al usuario
    _ttsService.speak(message);
    
    // Ejecutar la acción correspondiente
    switch (action) {
      case 'BIENVENIDA':
        // No necesita acción específica, solo feedback
        break;
      
      case 'MOSTRAR_LIBROS':
        _navigateToPage('/search');
        _context.read<BookBloc>().add(const GetBooksEvent());
        break;
      
      case 'BUSCAR':
        final searchTerm = parameters['value'] ?? '';
        _navigateToPage('/search');
        _context.read<BookBloc>().add(GetBooksEvent(query: searchTerm));
        break;
      
      case 'CATEGORIAS':
        _navigateToPage('/search');
        break;
      
      case 'FILTRAR_CATEGORIA':
        final category = parameters['value'] ?? '';
        _navigateToPage('/search');
        _context.read<BookBloc>().add(GetBooksEvent(category: category));
        break;
      
      case 'PRESTAMOS':
        _navigateToPage('/loans');
        break;
      
      case 'RESERVAS':
        _navigateToPage('/reservations');
        break;
      
      case 'PERFIL':
        _navigateToPage('/profile');
        break;
      
      case 'NAVEGAR':
        final page = parameters['value'] ?? '';
        _handleNavigationCommand(page);
        break;
      
      case 'DETALLE_LIBRO':
        // Para este necesitaríamos buscar el libro primero
        final bookTitle = parameters['value'] ?? '';
        _searchBookAndNavigateToDetail(bookTitle);
        break;
      
      case 'RESERVAR':
        final bookTitle = parameters['value'] ?? '';
        _searchBookAndReserve(bookTitle);
        break;
      
      case 'AYUDA':
        // No necesita navegación, solo el mensaje TTS
        break;
      
      case 'DESPEDIDA':
        // Parar el asistente después de la despedida
        _isActive = false;
        _speechService.stopListening();
        break;
      
      default:
        // Acción no reconocida - el mensaje ya se reproduce por TTS
        break;
    }
  }
  
  void _handleNavigationCommand(String page) {
    switch (page.toLowerCase()) {
      case 'inicio':
        _navigateToPage('/home');
        break;
      case 'busqueda':
      case 'búsqueda':
        _navigateToPage('/search');
        break;
      case 'prestamos':
      case 'préstamos':
        _navigateToPage('/loans');
        break;
      case 'reservas':
        _navigateToPage('/reservations');
        break;
      case 'chat':
        _navigateToPage('/chat');
        break;
      case 'perfil':
        _navigateToPage('/profile');
        break;
      default:
        _ttsService.speak("No reconozco esa página");
    }
  }
  
  void _navigateToPage(String route) {
    // Usar el GlobalKey del navigator en lugar del contexto local
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(route);
    } else {
      print("Navigator no disponible");
    }
  }
  
  // Método auxiliar para buscar un libro por título y navegar a su detalle
  void _searchBookAndNavigateToDetail(String bookTitle) {
    // Idealmente, habría que implementar una búsqueda específica por título
    // Por ahora, simplemente hacemos una búsqueda general
    _navigateToPage('/search');
    _context.read<BookBloc>().add(GetBooksEvent(query: bookTitle));
  }
  
  // Método auxiliar para buscar un libro y reservarlo
  void _searchBookAndReserve(String bookTitle) {
    // Similar al método anterior
    _navigateToPage('/search');
    _context.read<BookBloc>().add(GetBooksEvent(query: bookTitle));
  }
  
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
    _dialogflowService.dispose();
  }
}