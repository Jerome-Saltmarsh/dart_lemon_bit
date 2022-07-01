import 'package:bleed_server/system.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common/library.dart';
import 'engine.dart';
import 'network/connection.dart';

var connectionsCurrent = 0;
var connectionsTotal = 0;

Future main() async {
  print('gamestream.online server starting');
  print('v${version}');
  if (isLocalMachine){
    print("Environment Detected: Jerome's Computer");
  }else{
    print("Environment Detected: Google Cloud Machine");
  }
  await engine.init();
  startWebsocketServer();
}

void startWebsocketServer(){
  print("startWebsocketServer()");
  var handler = webSocketHandler(
      buildWebSocketHandler,
      protocols: ['gamestream.online'],
      // pingInterval: Duration(hours: 1),
  );

  shelf_io.serve(handler, '0.0.0.0', 8080).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  }).catchError((error){
    print("Websocket error occurred");
    print(error);
  });
}

List<Connection> connections = [];

void buildWebSocketHandler(WebSocketChannel webSocket) {
    final connection = Connection(webSocket);
    connections.add(connection);
    connection.onDone = () => connections.remove(connection);

    connectionsCurrent++;
    connectionsTotal++;
    print("New Connection. Current Connections: $connectionsCurrent, Total Connections: $connectionsTotal");
}

bool isValidIndex(int? index, List values){
    if (index == null) return false;
   if (values.isEmpty) return false;
   if (index < 0) return false;
   return index < values.length;
}