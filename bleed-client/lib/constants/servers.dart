import 'package:bleed_client/ui.dart';

import '../connection.dart';

// state
Server _currentServer;

// interface
String getServerName(Server server) {
  return _names[server];
}

void connectServer(Server server) {
  _currentServer = server;
  sharedPreferences.setInt('server', server.index);
  if (server == Server.LocalHost) {
    connectLocalHost();
    return;
  }
  connect(_getConnectionString(server));
}

void connectLocalHost({int port = 8080}) {
  _currentServer = Server.LocalHost;
  connect('ws://localhost:$port');
}

bool isServerConnected(Server server) {
  return _currentServer == server;
}

Server get currentServer => _currentServer;

enum Server { Germany, USA_East, USA_West, LocalHost }

final List<Server> servers = Server.values;

// implementation

Map<Server, String> _names = {
  Server.Germany: "Germany",
  Server.USA_East: "USA East",
  Server.USA_West: "USA West",
  Server.LocalHost: "Localhost",
};

Map<Server, String> _uris = {
  Server.Germany: 'https://bleed-berlin-osbmaezptq-ey.a.run.app',
  Server.USA_East: 'https://bleed-usa-east-osbmaezptq-ue.a.run.app',
  Server.USA_West: 'https://usa-west-osbmaezptq-uw.a.run.app',
  Server.LocalHost: 'https://localhost'
};

String _getConnectionString(Server server) {
  return _parseHttpToWebSocket(_getUri(server));
}

String _parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String _getUri(Server server) {
  return _uris[server];
}
