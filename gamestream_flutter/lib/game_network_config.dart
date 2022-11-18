
class GameNetworkConfig {
  // CONSTANTS
  static const Url_Sydney = "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Url_Singapore = "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
  // VARIABLES
  static var portLocalhost = '8080';
  // GETTERS
  static String get wsLocalHost => 'ws://localhost:${portLocalhost}';
}