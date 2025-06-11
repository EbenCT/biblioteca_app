import 'dart:io';

class GraphQLConfig {
  // Configuration for GraphQL endpoint
  // Update these values according to your backend setup
  
  static const String laptopIp = '192.168.100.4'; // Tu IP real
  static const String port = '8080';
  
  // Different endpoints for different scenarios
  static const String localhostEndpoint = 'http://localhost:$port/graphql';
  static const String androidEmulatorEndpoint = 'http://10.0.2.2:$port/graphql';
  static const String iosSimulatorEndpoint = 'http://localhost:$port/graphql';
  static const String physicalDeviceEndpoint = 'http://$laptopIp:$port/graphql';
  
  // Headers for GraphQL requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Get the appropriate endpoint based on the platform/environment
  static String get graphqlEndpoint {
    // Detectar si es dispositivo físico o emulador
    if (Platform.isAndroid) {
      // Para dispositivo físico Android, usar la IP de la laptop
      return physicalDeviceEndpoint;
    } else if (Platform.isIOS) {
      // Para dispositivo físico iOS, usar la IP de la laptop
      return physicalDeviceEndpoint;
    } else {
      // Fallback
      return physicalDeviceEndpoint;
    }
  }
  
  // Método para detectar si es emulador (opcional, para mayor precisión)
  static String getEndpointForEnvironment({bool isEmulator = false}) {
    if (isEmulator) {
      if (Platform.isAndroid) {
        return androidEmulatorEndpoint;
      } else if (Platform.isIOS) {
        return iosSimulatorEndpoint;
      }
    }
    
    // Para dispositivos físicos, siempre usar la IP real
    return physicalDeviceEndpoint;
  }
  
  // Authentication configuration
  static const bool requiresAuth = false;
  static const String authHeaderName = 'Authorization';
  static const String authTokenPrefix = 'Bearer ';
  
  // Query configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache configuration
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const bool enableOfflineCache = true;
  
  // Error handling configuration
  static const bool enableRetryOnError = true;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Debug information
  static void printConnectionInfo() {
    print('🌐 GraphQL Configuration:');
    print('📱 Platform: ${Platform.operatingSystem}');
    print('🔗 Endpoint: ${graphqlEndpoint}');
    print('💻 Laptop IP: $laptopIp');
    print('🚪 Port: $port');
  }
}

// Environment-specific configurations
class GraphQLEnvironment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  static const String currentEnvironment = development;
  
  static String get endpoint {
    switch (currentEnvironment) {
      case development:
        return GraphQLConfig.graphqlEndpoint;
      case staging:
        return 'https://your-staging-api.com/graphql';
      case production:
        return 'https://your-production-api.com/graphql';
      default:
        return GraphQLConfig.graphqlEndpoint;
    }
  }
  
  static bool get enableLogging {
    return currentEnvironment == development;
  }
}