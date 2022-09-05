import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection.dart';

final connections = <Connection>[];
var connectionsTotal = 0;

void startWebsocketServer(){
  print("startWebsocketServer()");
  var handler = webSocketHandler(
    onConnection,
    protocols: ['gamestream.online'],
    pingInterval: const Duration(seconds: 30),
  );

  shelf_io.serve(handler, '0.0.0.0', 8080).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  }).catchError((error){
    print("Websocket error occurred");
    print(error);
  });
}

void onConnection(WebSocketChannel webSocketChannel) {
  final connection = Connection(webSocketChannel);
  connections.add(connection);
  connection.onDone = () => onConnectionDone(connection);
  connectionsTotal++;
  print("Connection Added. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
}

void onConnectionDone(Connection connection){
  connections.remove(connection);
  print("Connection Done. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
}
