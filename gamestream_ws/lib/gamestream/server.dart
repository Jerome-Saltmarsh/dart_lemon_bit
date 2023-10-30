
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/connection.dart';
import 'nerve.dart';

class Server {

  final Nerve nerve;
  HttpServer? httpServer;
  var connectionsTotal = 0;
  final connections = <Connection>[];

  Server({required this.nerve});

  Future construct() async {
    startWebsocketServer(port: 8080);
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
      nerve: nerve,
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
    nerve.onDisconnected(connection);
    if (connections.remove(connection)){
      print('gamestream_server - connection removed');
      print("Current Connections: ${connections.length}, Total Connections: ${connectionsTotal}");
    }
  }

  void sendResponseToClients(){
    for (final connection in connections) {
      connection.sendBufferToClient();
    }
  }
}