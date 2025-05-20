// lib/core/services/voice_navigation_manager.dart (simplificado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/book/book_bloc.dart';
import '../services/dialogflow_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../utils/permission_handler.dart';

class VoiceNavigationManager {
  final SpeechService _speechService;
  final DialogflowService _dialogflowService;
  final TTSService _ttsService;
  final BuildContext _context;
  
  bool _isActive = false;
  
  VoiceNavigationManager(this._context)
      : _speechService = SpeechService(),
        _dialogflowService = DialogflowService(),
        _ttsService = TTSService() {
    _initialize();
  }
  
  bool get isActive => _isActive;
  Stream<bool> get listeningStatus => _speechService.listeningStatus;

  Future<void> _initialize() async {
    // Inicializar el servicio de reconocimiento de voz
    await _speechService.initialize();
    
    // Verificar permiso de micrófono
    final hasPermission = await AppPermissionHandler.requestMicrophonePermission(_context);
    if (!hasPermission) {
      print("Permiso de micrófono no concedido");
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
  }
  
  void toggleListening() {
    if (_speechService.isListening) {
      _speechService.stopListening();
      _isActive = false;
    } else {
      _speechService.startListening();
      _isActive = true;
      _ttsService.speak("Te escucho");
    }
  }
  
  void _processVoiceCommand(String text) {
    // Simplemente enviamos el texto reconocido a DialogFlow
    _dialogflowService.detectIntent(text);
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
      
      default:
        // Acción no reconocida
        _ttsService.speak("No pude entender esa acción");
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
    Navigator.of(_context).pushNamed(route);
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
  }
}