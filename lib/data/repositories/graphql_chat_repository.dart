// lib/data/repositories/graphql_chat_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/graphql_service.dart';
import '../../domain/repositories/repositories.dart';

class GraphQLChatRepository implements ChatRepository {
  final GraphQLService _graphQLService;

  GraphQLChatRepository(this._graphQLService);

  static const String _sendChatMessage = '''
    mutation SendChatMessage(\$input: ChatInput!) {
      sendChatMessage(input: \$input) {
        message
        intent
        action
        confidence
        parameters
        success
      }
    }
  ''';

  @override
  Future<Either<Failure, String>> sendMessage(String message) async {
    try {
      print('🤖 Enviando mensaje a Dialogflow via GraphQL: $message');
      
      final result = await _graphQLService.mutate(
        _sendChatMessage,
        variables: {
          'input': {
            'message': message,
            'userId': 'flutter_user_${DateTime.now().millisecondsSinceEpoch}',
          }
        },
      );

      if (result.hasException) {
        print('❌ GraphQL Exception: ${result.exception}');
        return Left(ServerFailure('Error de comunicación con el servidor'));
      }

      final data = result.data;
      if (data == null || data['sendChatMessage'] == null) {
        return Left(ServerFailure('No se recibió respuesta del servidor'));
      }

      final chatResponse = data['sendChatMessage'];
      final responseMessage = chatResponse['message'] as String;
      final action = chatResponse['action'] as String;
      final intent = chatResponse['intent'] as String;
      final confidence = chatResponse['confidence'] as double;
      final success = chatResponse['success'] as bool;
      final parameters = chatResponse['parameters'] as Map<String, dynamic>?;

      print('✅ Respuesta de Dialogflow:');
      print('   Intent: $intent');
      print('   Acción: $action');
      print('   Confianza: $confidence');
      print('   Mensaje: $responseMessage');
      print('   Parámetros: $parameters');

      if (!success) {
        return Left(ServerFailure(responseMessage));
      }

      // Procesar la acción para navegación si es necesario
      _processAction(action, parameters);

      return Right(responseMessage);
    } catch (e) {
      print('❌ Error en GraphQL chat: $e');
      return Left(ServerFailure('Error de conexión: ${e.toString()}'));
    }
  }

  void _processAction(String action, Map<String, dynamic>? parameters) {
    print('🎯 Procesando acción: $action');
    if (parameters != null && parameters.isNotEmpty) {
      print('📋 Con parámetros: $parameters');
    }
    
    // Aquí puedes agregar lógica para manejar las acciones
    // Por ejemplo, disparar eventos de navegación, etc.
    switch (action.toUpperCase()) {
      case 'BUSCAR_LIBROS':
      case 'BUSCAR':
        print('🔍 Ejecutar búsqueda de libros');
        // Podrías disparar un evento para navegar a búsqueda
        break;
      case 'NAVEGAR_PRESTAMOS':
      case 'PRESTAMOS':
        print('📚 Navegar a préstamos');
        break;
      case 'NAVEGAR_RESERVAS':
      case 'RESERVAS':
        print('📖 Navegar a reservas');
        break;
      case 'NAVEGAR_PERFIL':
      case 'PERFIL':
        print('👤 Navegar a perfil');
        break;
      case 'BIENVENIDA':
      case 'AYUDA':
        print('💬 Mensaje de ayuda/bienvenida');
        break;
      default:
        print('🤷 Acción no reconocida: $action');
    }
  }
}