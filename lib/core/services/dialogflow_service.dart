// Servicio de DialogFlow simplificado sin dependencia externa
// Para mantener la funcionalidad de navegación por voz temporalmente

import 'dart:async';

class SimpleDialogflowService {
  final StreamController<Map<String, dynamic>> _responseStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onResponse => _responseStreamController.stream;

  SimpleDialogflowService() {
    print("SimpleDialogflowService inicializado - Simulando respuestas");
  }

  Future<void> detectIntent(String text) async {
    print("Procesando texto localmente: $text");
    
    try {
      // Simular un pequeño delay como si fuera una llamada a la API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Procesar el texto localmente usando patrones simples
      final response = _processTextLocally(text.toLowerCase());
      
      print("Respuesta local generada: ${response['message']}");
      _responseStreamController.add(response);
      
    } catch (e) {
      print('Error procesando intent localmente: $e');
      _responseStreamController.add({
        'action': 'ERROR',
        'message': 'No pude entender eso. ¿Podrías repetirlo?',
        'parameters': {}
      });
    }
  }

  Map<String, dynamic> _processTextLocally(String text) {
    // Patrones de reconocimiento básicos
    Map<String, dynamic> result = {
      'action': '',
      'message': '',
      'parameters': {}
    };

    // Detectar saludos y bienvenida
    if (_containsAny(text, ['hola', 'buenas', 'buenos días', 'buenas tardes', 'hey'])) {
      result['action'] = 'BIENVENIDA';
      result['message'] = 'Hola, soy el asistente virtual de la biblioteca UAGRM. ¿En qué puedo ayudarte?';
    }
    
    // Detectar búsquedas de libros
    else if (_containsAny(text, ['buscar', 'libro', 'libros', 'busco', 'encontrar'])) {
      result['action'] = 'BUSCAR';
      result['message'] = 'Te ayudo a buscar libros. Abriendo la sección de búsqueda.';
      
      // Extraer término de búsqueda
      String searchTerm = _extractSearchTerm(text);
      if (searchTerm.isNotEmpty) {
        result['parameters'] = {'value': searchTerm};
        result['message'] = 'Buscando "$searchTerm" en nuestro catálogo.';
      }
    }
    
    // Detectar solicitudes de categorías
    else if (_containsAny(text, ['categoría', 'categorias', 'tipos', 'clasificación'])) {
      result['action'] = 'CATEGORIAS';
      result['message'] = 'Te muestro las categorías disponibles.';
    }
    
    // Detectar navegación a préstamos
    else if (_containsAny(text, ['préstamos', 'prestamos', 'mis libros', 'libros prestados'])) {
      result['action'] = 'PRESTAMOS';
      result['message'] = 'Abriendo tu historial de préstamos.';
    }
    
    // Detectar navegación a reservas
    else if (_containsAny(text, ['reservas', 'reservar', 'mis reservas'])) {
      result['action'] = 'RESERVAS';
      result['message'] = 'Abriendo tus reservas.';
    }
    
    // Detectar navegación al perfil
    else if (_containsAny(text, ['perfil', 'mi perfil', 'cuenta', 'información personal'])) {
      result['action'] = 'PERFIL';
      result['message'] = 'Abriendo tu perfil.';
    }
    
    // Detectar navegación general
    else if (_containsAny(text, ['ir a', 'abrir', 'navegar', 'mostrar'])) {
      String destination = _extractNavigationDestination(text);
      if (destination.isNotEmpty) {
        result['action'] = 'NAVEGAR';
        result['message'] = 'Navegando a $destination.';
        result['parameters'] = {'value': destination};
      }
    }
    
    // Detectar solicitudes de información sobre libros específicos
    else if (_containsAny(text, ['información', 'detalles', 'sobre el libro', 'que es'])) {
      result['action'] = 'DETALLE_LIBRO';
      result['message'] = 'Te ayudo a encontrar información sobre ese libro.';
      String bookTitle = _extractBookTitle(text);
      if (bookTitle.isNotEmpty) {
        result['parameters'] = {'value': bookTitle};
      }
    }
    
    // Detectar solicitudes de reserva
    else if (_containsAny(text, ['quiero reservar', 'reservar libro', 'hacer reserva'])) {
      result['action'] = 'RESERVAR';
      result['message'] = 'Te ayudo a reservar ese libro.';
      String bookTitle = _extractBookTitle(text);
      if (bookTitle.isNotEmpty) {
        result['parameters'] = {'value': bookTitle};
      }
    }
    
    // Detectar solicitudes de ayuda
    else if (_containsAny(text, ['ayuda', 'help', 'qué puedes hacer', 'comandos'])) {
      result['action'] = 'AYUDA';
      result['message'] = 'Puedo ayudarte a buscar libros, navegar por la aplicación, ver tus préstamos y reservas. ¿Qué necesitas?';
    }
    
    // Detectar despedidas
    else if (_containsAny(text, ['adiós', 'chao', 'hasta luego', 'bye', 'gracias'])) {
      result['action'] = 'DESPEDIDA';
      result['message'] = '¡Hasta luego! Si necesitas algo más, estaré aquí para ayudarte.';
    }
    
    // Respuesta por defecto
    else {
      result['action'] = 'DEFAULT';
      result['message'] = 'No estoy seguro de entender eso. ¿Podrías intentar preguntarme sobre buscar libros, ver préstamos o navegar por la aplicación?';
    }

    return result;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _extractSearchTerm(String text) {
    // Patrones para extraer términos de búsqueda
    List<String> searchPrefixes = [
      'buscar ',
      'busco ',
      'libro ',
      'libros ',
      'encontrar ',
      'quiero ',
      'necesito '
    ];
    
    for (String prefix in searchPrefixes) {
      int index = text.indexOf(prefix);
      if (index != -1) {
        String remaining = text.substring(index + prefix.length).trim();
        // Limpiar palabras comunes al final
        remaining = remaining.replaceAll(RegExp(r'\b(por favor|porfavor|gracias)\b'), '').trim();
        if (remaining.isNotEmpty) {
          return remaining;
        }
      }
    }
    
    return '';
  }

  String _extractNavigationDestination(String text) {
    Map<String, String> destinations = {
      'inicio': 'inicio',
      'home': 'inicio',
      'búsqueda': 'búsqueda',
      'busqueda': 'búsqueda',
      'search': 'búsqueda',
      'préstamos': 'préstamos',
      'prestamos': 'préstamos',
      'loans': 'préstamos',
      'reservas': 'reservas',
      'reservations': 'reservas',
      'perfil': 'perfil',
      'profile': 'perfil',
      'chat': 'chat',
    };
    
    for (String key in destinations.keys) {
      if (text.contains(key)) {
        return destinations[key]!;
      }
    }
    
    return '';
  }

  String _extractBookTitle(String text) {
    // Intentar extraer título de libro de frases comunes
    List<String> patterns = [
      'libro ',
      'sobre ',
      'de ',
      'llamado ',
      'titulado '
    ];
    
    for (String pattern in patterns) {
      int index = text.indexOf(pattern);
      if (index != -1) {
        String remaining = text.substring(index + pattern.length).trim();
        remaining = remaining.replaceAll(RegExp(r'\b(por favor|porfavor|gracias)\b'), '').trim();
        if (remaining.isNotEmpty) {
          return remaining;
        }
      }
    }
    
    return '';
  }
  
  void dispose() {
    _responseStreamController.close();
  }
}