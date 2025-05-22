// lib/core/services/dialogflow_service.dart (corregido)

import 'dart:async';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';

class DialogflowService {
  DialogFlow? dialogflow;
  final StreamController<Map<String, dynamic>> _responseStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onResponse => _responseStreamController.stream;

  DialogflowService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Inicializar con el archivo de credenciales
      AuthGoogle authGoogle = await AuthGoogle(
        fileJson: "assets/dialogflow_credentials.json"
      ).build();
      
      // Inicializar DialogFlow con las credenciales
      dialogflow = DialogFlow(
        authGoogle: authGoogle,
        language: "es"
      );
      
      print("DialogFlow inicializado correctamente");
    } catch (e) {
      print("Error inicializando DialogFlow: $e");
    }
  }

  Future<void> detectIntent(String text) async {
    if (dialogflow == null) {
      print("DialogFlow no ha sido inicializado");
      _responseStreamController.add({
        'action': 'ERROR',
        'message': 'El servicio no está listo. Inténtalo de nuevo en unos momentos.',
        'parameters': {}
      });
      return;
    }
    
    try {
      print("Enviando texto a DialogFlow: $text");
      
      // Enviamos el texto a DialogFlow y esperamos la respuesta
      AIResponse aiResponse = await dialogflow!.detectIntent(text);
      
      // Obtenemos el mensaje de respuesta - Con manejo adecuado de nulos
      String fulfillmentText = "";
      try {
        // Verificamos si getListMessage no es nulo y tiene elementos
        var listMessage = aiResponse.getListMessage();
        if (listMessage != null && listMessage.isNotEmpty) {
          // Verificamos si el primer elemento tiene la estructura esperada
          var firstMessage = listMessage[0];
          if (firstMessage != null && 
              firstMessage["text"] != null && 
              firstMessage["text"]["text"] != null && 
              firstMessage["text"]["text"].isNotEmpty) {
            
            fulfillmentText = firstMessage["text"]["text"][0].toString();
          } else {
            // Intento alternativo para obtener el texto
            fulfillmentText = aiResponse.getMessage() ?? "";
          }
        } else {
          // Si getListMessage es nulo o vacío, intentamos con getMessage
          fulfillmentText = aiResponse.getMessage() ?? "";
        }
      } catch (e) {
        // Fallback si hay algún error al extraer el mensaje
        print("Error al extraer mensaje de DialogFlow: $e");
        fulfillmentText = aiResponse.getMessage() ?? "No se pudo obtener respuesta";
      }
      
      print("Respuesta de DialogFlow: $fulfillmentText");
      
      // Si no tenemos texto de respuesta, enviamos un mensaje genérico
      if (fulfillmentText.isEmpty) {
        fulfillmentText = "No pude entender eso. ¿Podrías intentarlo de otra manera?";
      }
      
      // Procesamos la respuesta para obtener la acción y parámetros
      Map<String, dynamic> responseData = _parseResponse(fulfillmentText);
      
      // Enviamos la respuesta procesada al stream
      _responseStreamController.add(responseData);
    } catch (e) {
      print('Error detectando intent: $e');
      _responseStreamController.add({
        'action': 'ERROR',
        'message': 'No pude entender eso. ¿Podrías repetirlo?',
        'parameters': {}
      });
    }
  }

Map<String, dynamic> _parseResponse(String response) {
  // Procesamos la respuesta para extraer la acción y parámetros
  Map<String, dynamic> result = {
    'action': '',
    'message': response,
    'parameters': {}
  };

  // Si no hay dos puntos, consideramos que es solo la acción
  if (!response.contains(':')) {
    result['action'] = response;
    // En este caso, el mensaje quedará igual que la acción
    // (ya que no hay un mensaje separado)
    return result;
  }

  try {
    // Dividimos por los dos puntos para separar acción y mensaje
    final parts = response.split(':');
    result['action'] = parts[0].trim();
    
    // Si hay contenido después de los dos puntos, lo usamos como mensaje
    // (esto eliminará la acción del mensaje a reproducir)
    if (parts.length > 1) {
      result['message'] = parts[1].trim();
      
      // Si hay parámetros adicionales, los procesamos
      final paramString = parts[1].trim();
      result['parameters'] = {'value': paramString};
    }
  } catch (e) {
    print('Error analizando respuesta: $e');
  }

  return result;
}
  void dispose() {
    _responseStreamController.close();
  }
}