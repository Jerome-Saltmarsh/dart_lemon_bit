import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/io/save_directory.dart';
import 'package:bleed_server/src/scenes.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'system.dart';

final engine = Engine();

class Engine {

  static const Frames_Per_Second = 45;

  final connections = <Connection>[];
  final games = <Game>[];
  final scenes = Scenes();

  var frame = 0;
  var connectionsTotal = 0;

  Future run() async {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');

    final sceneDirectoryExists = await Scene_Directory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: $Scene_Directory_Path');
    }

    if (isLocalMachine) {
      print("environment: Jerome's Computer");
    } else{
      print("environment: Google Cloud");
    }

    await scenes.load();

    Timer.periodic(Duration(milliseconds: 1000 ~/ Frames_Per_Second), _fixedUpdate);
    _startWebsocketServer();
  }

  void _fixedUpdate(Timer timer) {
    frame++;

    for (var i = 0; i < games.length; i++){
      games[i].updateStatus();
    }
  }

  Future<GameEditor> findGameEditorNew() async {
    return GameEditor();
  }

  // This method is called by the game constructor automatically
  // and should not be called again
  void onGameCreated(Game game) {
    games.add(game);
  }

  void _startWebsocketServer(){
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

}
