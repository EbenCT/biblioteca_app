// lib/core/services/recommendations_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/recommendations_config.dart';

class RecommendationsService {
  late GraphQLClient _client;
  String? _currentEndpoint;
  
  static RecommendationsService? _instance;
  
  RecommendationsService._internal();
  
  static RecommendationsService get instance {
    _instance ??= RecommendationsService._internal();
    return _instance!;
  }

  void initialize({required String endpoint}) {
    _currentEndpoint = endpoint;
    
    print('🤖 Initializing Recommendations Service with endpoint: $endpoint');
    
    final HttpLink httpLink = HttpLink(endpoint);

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly, // Siempre obtener recomendaciones frescas
          error: ErrorPolicy.all,
        ),
      ),
    );
    
    print('✅ Recommendations Service initialized successfully');
  }

  GraphQLClient get client => _client;
  String? get currentEndpoint => _currentEndpoint;

  Future<QueryResult> getRecommendations(String userId, {int limit = 10}) async {
    const String query = '''
      query GetRecommendations(\$user_id: String!, \$limit: Int!) {
        get_recommendations(user_id: \$user_id, limit: \$limit) {
          user_id
          recommendations {
            book_id
            title
            score
          }
          total_recommendations
          message
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'user_id': userId,
        'limit': limit,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      print('🔍 Getting recommendations for user: $userId (limit: $limit)');
      final result = await _client.query(options);
      
      if (result.hasException) {
        print('❌ Recommendations Query Error: ${result.exception}');
      } else {
        print('✅ Recommendations received successfully');
      }
      
      return result;
    } catch (e) {
      print('❌ Recommendations Query Exception: $e');
      rethrow;
    }
  }

  Future<QueryResult> getHealthCheck() async {
    const String query = '''
      query HealthCheck {
        health_check
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      print('🏥 Checking recommendations service health...');
      final result = await _client.query(options);
      
      if (result.hasException) {
        print('❌ Health Check Error: ${result.exception}');
      } else {
        final healthStatus = result.data?['health_check'] as String?;
        print('✅ Health Check: $healthStatus');
      }
      
      return result;
    } catch (e) {
      print('❌ Health Check Exception: $e');
      rethrow;
    }
  }

  void debugConnection() {
    print('🔍 RECOMMENDATIONS SERVICE DEBUG:');
    print('Endpoint: $_currentEndpoint');
    print('Client initialized: ${_client != null}');
  }
}