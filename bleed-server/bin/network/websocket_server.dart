import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection.dart';

List<Connection> connections = [];
var connectionsCurrent = 0;
var connectionsTotal = 0;

void startWebsocketServer(){
  print("startWebsocketServer()");
  var handler = webSocketHandler(
    onConnection,
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


void onConnection(WebSocketChannel webSocketChannel) {
  final connection = Connection(webSocketChannel);
  connections.add(connection);
  connection.onDone = () => connections.remove(connection);
  connectionsCurrent++;
  connectionsTotal++;
  print("New Connection. Current Connections: $connectionsCurrent, Total Connections: $connectionsTotal");
}
