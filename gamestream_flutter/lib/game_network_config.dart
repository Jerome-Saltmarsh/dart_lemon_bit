

class GameNetworkConfig {
  // VARIABLES
  static var portLocalhost = '8080';
  // GETTERS
  static String get wsLocalHost => 'ws://localhost:${portLocalhost}';
}