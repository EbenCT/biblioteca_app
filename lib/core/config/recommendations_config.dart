// lib/core/config/recommendations_config.dart

import 'dart:io';

class RecommendationsConfig {
  // Configuration for Recommendations GraphQL endpoint
  // Update these values according to your Python backend setup
  
  static const String laptopIp = '192.168.91.243'; // Tu IP real
  static const String port = '8000'; // Puerto del backend Python
  
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
  
  // Debug information
  static void printConnectionInfo() {
    print('🤖 Recommendations Service Configuration:');
    print('📱 Platform: ${Platform.operatingSystem}');
    print('🔗 Endpoint: ${graphqlEndpoint}');
    print('💻 Laptop IP: $laptopIp');
    print('🚪 Port: $port');
  }
}

// Environment-specific configurations for recommendations
class RecommendationsEnvironment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  static const String currentEnvironment = development;
  
  static String get endpoint {
    switch (currentEnvironment) {
      case development:
        return RecommendationsConfig.graphqlEndpoint;
      case staging:
        return 'https://your-staging-recommendations.com/graphql';
      case production:
        return 'https://your-production-recommendations.com/graphql';
      default:
        return RecommendationsConfig.graphqlEndpoint;
    }
  }
  
  static bool get enableLogging {
    return currentEnvironment == development;
  }
}