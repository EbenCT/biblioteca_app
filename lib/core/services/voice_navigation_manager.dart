// lib/core/services/voice_navigation_manager.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/book/book_bloc.dart';
import '../services/dialogflow_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../utils/permission_handler.dart';
import '../../app.dart';

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
    
    // Suscribirse al stream de respuestas de DialogFlow
    _dialogflowService.onResponse.listen((response) {
      _handleDialogflowResponse(response);
    });
    
    print("✅ Configuración de voz completada");
  }
  
  void toggleListening() {
    if (_speechService.isListening) {
      _speechService.stopListening();
      _isActive = false;
      _ttsService.stop();
    } else {
      _startListeningWithDelay();
    }
  }
  
  // CORREGIDO: Coordinar TTS y Speech Recognition correctamente
  Future<void> _startListeningWithDelay() async {
    _isActive = true;
    
    // 1. Parar cualquier TTS que esté reproduciéndose
    await _ttsService.stop();
    
    // 2. Reproducir mensaje de confirmación y ESPERAR a que termine completamente
    await _ttsService.speak("Te escucho");
    
    // 3. Agregar delay adicional para asegurar que TTS terminó
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 4. Iniciar reconocimiento
    print("🎤 Iniciando reconocimiento después de TTS");
    await _speechService.startListening();
    
    // 5. Verificar que inició correctamente
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_speechService.isListening) {
      print("❌ Reintentando reconocimiento...");
      await Future.delayed(const Duration(milliseconds: 300));
      await _speechService.startListening();
    }
  }
  
  void _processVoiceCommand(String text) {
    // Verificar si el texto parece inglés
   /* if (_isTextEnglish(text)) {
      print("🚨 DETECTADO TEXTO EN INGLÉS: $text");
      DeviceConfigChecker.printConfigurationGuide();
      _ttsService.speak("He detectado que reconocí en inglés. Por favor revisa la configuración de idioma de tu dispositivo.");
      return;
    }*/
    
    print("🗣️ Comando de voz recibido: $text");
    
    // Enviar el texto a DialogFlow
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
  
  // CORREGIDO: Manejo de respuestas con palabras clave y navegación
void _handleDialogflowResponse(Map<String, dynamic> response) {
  final String action = response['action'] ?? '';
  final String message = response['message'] ?? '';
  
  // CORREGIDO: Convertir correctamente el tipo de parameters
  final Map<String, dynamic> parameters = response['parameters'] != null 
      ? Map<String, dynamic>.from(response['parameters']) 
      : <String, dynamic>{};
    
    print("📱 Respuesta de DialogFlow:");
    print("   Acción detectada: $action");
    print("   Mensaje: $message");
    print("   Parámetros: $parameters");
    
    // CORREGIDO: Primero reproducir el mensaje, LUEGO ejecutar navegación
    _speakAndThenExecuteAction(message, action, parameters);
  }
  
  // NUEVO: Método para coordinar TTS y navegación
  Future<void> _speakAndThenExecuteAction(String message, String action, Map<String, dynamic> parameters) async {
    // 1. Parar el reconocimiento de voz mientras procesamos
    _speechService.stopListening();
    _isActive = false;
    
    // 2. Reproducir mensaje y ESPERAR a que termine
    if (message.isNotEmpty) {
      await _ttsService.speak(message);
      
      // 3. Esperar un poco más para asegurar que terminó
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // 4. AHORA ejecutar la acción de navegación
    _executeAction(action, parameters);
  }
  
  // CORREGIDO: Ejecutar acciones basadas en palabras clave
void _executeAction(String action, Map<String, dynamic> parameters) {
  print("🎯 Ejecutando acción: $action");
  
  // CORREGIDO: Detectar acciones tanto del formato nuevo como del formato de palabra clave
  String normalizedAction = action.toUpperCase();
  
  // Si viene del formato nuevo de GraphQL, mapear a las acciones conocidas
  if (normalizedAction == 'INPUT.WELCOME') {
    normalizedAction = 'BIENVENIDA';
  } else if (normalizedAction == 'NAVEGAR_BUSQUEDA') {
    normalizedAction = 'BUSCAR';
  } else if (normalizedAction == 'MOSTRAR_PRESTAMOS') {
    normalizedAction = 'PRESTAMOS';
  } else if (normalizedAction == 'MOSTRAR_RESERVAS') {
    normalizedAction = 'RESERVAS';
  } else if (normalizedAction == 'MOSTRAR_PERFIL') {
    normalizedAction = 'PERFIL';
  } else if (normalizedAction == 'MOSTRAR_CATEGORIAS') {
    normalizedAction = 'CATEGORIAS';
  } else if (normalizedAction == 'MOSTRAR_AYUDA') {
    normalizedAction = 'AYUDA';
  }
  
  print("🎯 Acción normalizada: $normalizedAction");
  
  switch (normalizedAction) {
    case 'BIENVENIDA':
      // Solo feedback, no navegación
      print("👋 Mensaje de bienvenida recibido");
      break;
    
    case 'MOSTRAR_LIBROS':
    case 'BUSCAR':
      print("📚 Navegando a búsqueda");
      _navigateToPage('/search');
      
      final searchTerm = parameters['value']?.toString() ?? '';
      if (searchTerm.isNotEmpty) {
        print("🔍 Término de búsqueda: $searchTerm");
        _context.read<BookBloc>().add(GetBooksEvent(query: searchTerm));
      } else {
        _context.read<BookBloc>().add(const GetBooksEvent());
      }
      break;
    
    case 'CATEGORIAS':
      print("📂 Navegando a categorías");
      _navigateToPage('/search');
      break;
    
    case 'FILTRAR_CATEGORIA':
      print("🏷️ Filtrando por categoría");
      final category = parameters['value']?.toString() ?? '';
      _navigateToPage('/search');
      if (category.isNotEmpty) {
        _context.read<BookBloc>().add(GetBooksEvent(category: category));
      }
      break;
    
    case 'PRESTAMOS':
      print("📋 Navegando a préstamos");
      _navigateToPage('/loans');
      break;
    
    case 'RESERVAS':
      print("🔖 Navegando a reservas");
      _navigateToPage('/reservations');
      break;
    
    case 'PERFIL':
      print("👤 Navegando a perfil");
      _navigateToPage('/profile');
      break;
    
    case 'NAVEGAR':
      final page = parameters['value']?.toString() ?? '';
      print("🧭 Navegando a: $page");
      _handleNavigationCommand(page);
      break;
    
    case 'DETALLE_LIBRO':
      final bookTitle = parameters['value']?.toString() ?? '';
      print("📖 Buscando detalles del libro: $bookTitle");
      _searchBookAndNavigateToDetail(bookTitle);
      break;
    
    case 'RESERVAR':
      final bookTitle = parameters['value']?.toString() ?? '';
      print("📚 Reservando libro: $bookTitle");
      _searchBookAndReserve(bookTitle);
      break;
    
    case 'AYUDA':
      print("❓ Mostrando ayuda");
      // Solo mensaje, no navegación
      break;
    
    case 'DESPEDIDA':
      print("👋 Despedida recibida");
      // Parar el asistente
      _isActive = false;
      _speechService.stopListening();
      break;
    
    case 'RESPUESTA_INFORMATIVA':
      print("💬 Respuesta informativa, no requiere navegación");
      break;
    
    default:
      print("❓ Acción no reconocida: $normalizedAction (original: $action)");
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
        print("❌ Página no reconocida: $page");
        break;
    }
  }
  
  void _navigateToPage(String route) {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(route);
      print("✅ Navegación exitosa a: $route");
    } else {
      print("❌ Navigator no disponible");
    }
  }
  
  void _searchBookAndNavigateToDetail(String bookTitle) {
    _navigateToPage('/search');
    _context.read<BookBloc>().add(GetBooksEvent(query: bookTitle));
  }
  
  void _searchBookAndReserve(String bookTitle) {
    _navigateToPage('/search');
    _context.read<BookBloc>().add(GetBooksEvent(query: bookTitle));
  }
  
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
    _dialogflowService.dispose();
  }
}