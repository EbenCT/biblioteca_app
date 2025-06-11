import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  late GraphQLClient _client;
  String? _currentToken;
  String? _currentEndpoint;
  
  static GraphQLService? _instance;
  
  GraphQLService._internal();
  
  static GraphQLService get instance {
    _instance ??= GraphQLService._internal();
    return _instance!;
  }

  void initialize({required String endpoint, String? authToken}) {
    _currentToken = authToken;
    _currentEndpoint = endpoint;
    
    print('🔧 Initializing GraphQL with endpoint: $endpoint');
    
    final HttpLink httpLink = HttpLink(endpoint);

    Link link = httpLink;
    
    if (authToken != null && authToken.isNotEmpty) {
      final AuthLink authLink = AuthLink(
        getToken: () async => 'Bearer $authToken',
        headerKey: 'Authorization',
      );
      link = authLink.concat(httpLink);
      print('🔐 GraphQL client configured with authentication');
    } else {
      print('🔓 GraphQL client configured without authentication');
    }

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheAndNetwork,
          error: ErrorPolicy.all,
          cacheReread: CacheRereadPolicy.mergeOptimistic,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
          error: ErrorPolicy.all,
        ),
      ),
    );
    
    print('✅ GraphQL Client initialized successfully with endpoint: $endpoint');
    if (authToken != null) {
      print('🔑 Authentication token configured');
    }
  }

  GraphQLClient get client => _client;
  String? get currentToken => _currentToken;
  String? get currentEndpoint => _currentEndpoint;
  bool get isAuthenticated => _currentToken != null && _currentToken!.isNotEmpty;

  Future<QueryResult> query(String query, {Map<String, dynamic>? variables}) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );

    try {
      final result = await _client.query(options);
      
      if (result.hasException) {
        print('GraphQL Query Error: ${result.exception}');
        
        // Si es un error de autenticación, loggear específicamente
        if (_isAuthError(result.exception)) {
          print('🔐 Authentication error detected in GraphQL query');
        }
      }
      
      return result;
    } catch (e) {
      print('GraphQL Query Exception: $e');
      rethrow;
    }
  }

  Future<QueryResult> mutate(String mutation, {Map<String, dynamic>? variables}) async {
    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final result = await _client.mutate(options);
      
      if (result.hasException) {
        print('GraphQL Mutation Error: ${result.exception}');
        
        if (_isAuthError(result.exception)) {
          print('🔐 Authentication error detected in GraphQL mutation');
        }
      }
      
      return result;
    } catch (e) {
      print('GraphQL Mutation Exception: $e');
      rethrow;
    }
  }

  Stream<QueryResult> subscribe(String subscription, {Map<String, dynamic>? variables}) {
    final SubscriptionOptions options = SubscriptionOptions(
      document: gql(subscription),
      variables: variables ?? {},
    );

    return _client.subscribe(options);
  }

  bool _isAuthError(OperationException? exception) {
    if (exception == null) return false;
    
    final errorMessage = exception.toString().toLowerCase();
    return errorMessage.contains('unauthorized') ||
           errorMessage.contains('authentication') ||
           errorMessage.contains('token') ||
           errorMessage.contains('forbidden') ||
           errorMessage.contains('401') ||
           errorMessage.contains('403');
  }

  void updateAuthToken(String? token) {
    if (token != _currentToken && _currentEndpoint != null) {
      print('🔄 Updating GraphQL auth token');
      // Re-initialize with new token but same endpoint
      initialize(endpoint: _currentEndpoint!, authToken: token);
    }
  }

  void clearAuth() {
    print('🗑️ Clearing GraphQL authentication');
    if (_currentEndpoint != null) {
      initialize(endpoint: _currentEndpoint!, authToken: null);
    }
  }

  void debugConnection() {
    print('🔍 GRAPHQL CONNECTION DEBUG:');
    print('Endpoint: $_currentEndpoint');
    print('Has auth token: ${_currentToken != null}');
    print('Token length: ${_currentToken?.length ?? 0}');
    print('Is authenticated: $isAuthenticated');
  }
}