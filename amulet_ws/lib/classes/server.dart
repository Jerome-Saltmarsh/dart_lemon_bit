
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection.dart';
import 'root.dart';

class Server {

  final Root root;
  HttpServer? httpServer;
  var connectionsTotal = 0;
  final int port;
  final connections = <Connection>[];

  Server({required this.root, required this.port});

  Future construct() async {
    startWebsocketServer(port: port);
  }

  void handleServeCompleted(HttpServer httpServer){
    this.httpServer = httpServer;
    print('nerve.handleServeCompleted()');
    print('serving at wss://${httpServer.address.host}:${httpServer.port}');
  }

  void handleServerError(error){
    print("Websocket error occurred");
    print(error);
  }

  void onConnection(WebSocketChannel webSocketChannel) {
    final connection = Connection(
      webSocket: webSocketChannel,
      root: root,
    );
    connections.add(connection);
    connection.onDone = () => onConnectionDone(connection);
    connectionsTotal++;
    print("Connection Added. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
  }


  void startWebsocketServer({required int port}){
    print("nerve.startWebsocketServer(port: $port)");
    final handler = webSocketHandler(
      onConnection,
      protocols: const ['gamestream.online'],
    );

    shelf_io.serve(handler, '0.0.0.0', port)
        .then(handleServeCompleted)
        .catchError(handleServerError)
    ;
  }

  void onConnectionDone(Connection connection){
    root.onDisconnected(connection);
    if (connections.remove(connection)){
      print('gamestream_server - connection removed');
      print("Current Connections: ${connections.length}, Total Connections: ${connectionsTotal}");
    }
  }

  void sendResponseToClients(){
    final connections = this.connections;
    for (final connection in connections) {
      connection.sendBufferToClient();
    }
  }
}