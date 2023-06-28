import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/websocket/server_base.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'websocket_connection.dart';

class WebSocketServer implements ServerBase {
  var connectionsTotal = 0;
  final connections = <WebSocketConnection>[];
  final Gamestream engine;

  WebSocketServer(this.engine);

  @override
  void sendResponseToClients(){
    for (final connection in connections) {
      connection.sendBufferToClient();
    }
  }

  void start(){
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
    final connection = WebSocketConnection(webSocketChannel, engine);
    connections.add(connection);
    connection.onDone = () => onConnectionDone(connection);
    connectionsTotal++;
    print("Connection Added. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
  }

  void onConnectionDone(WebSocketConnection connection){
    connections.remove(connection);
    print("Connection Done. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
  }
}
