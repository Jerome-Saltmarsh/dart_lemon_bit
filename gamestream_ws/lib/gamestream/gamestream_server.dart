import 'dart:async';
import 'dart:io';

import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/duration_auto_save.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:gamestream_ws/packages.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../isometric.dart';
import 'classes/src.dart';
import '../editor/isometric_editor.dart';

class GamestreamServer {

  static const Frames_Per_Second = 45;
  static const Fixed_Time = 50 / Frames_Per_Second;

  final games = <Game>[];
  final isometricScenes = Scenes();
  final connections = <Connection>[];
  final UserService userService;
  final userServiceUrl = 'https://gamestream-http-osbmaezptq-uc.a.run.app';

  final bool admin;

  var connectionsTotal = 0;
  var frame = 0;
  var _updateTimerInitialized = false;

  late final Timer updateTimer;
  late final Timer timerRefreshUserCharacterLocks;

  GamestreamServer({required this.userService, this.admin = false}){
    _construct();
  }

  Future _construct() async {
    printSystemInformation();
    await validate();
    await loadResources();
    _initializeUpdateTimer();
    _initializeTimerAutoSave();
    startServerWebsocket(port: 8080);
  }

  void _initializeUpdateTimer() {
    if (_updateTimerInitialized) {
      return;
    }
    _updateTimerInitialized = true;
    updateTimer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ Frames_Per_Second),
        _fixedUpdate,
    );
  }

  void _initializeTimerAutoSave() {
    timerRefreshUserCharacterLocks = Timer.periodic(
        durationAutoSave,
        applyAutoSave,
    );
  }

  void applyAutoSave(_){
    print('applyAutoSave()');
    final connections = this.connections;
    for (final connection in connections){
      connection.performAutoSave();
    }
  }

  void printSystemInformation() {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');
    if (isLocalMachine) {
      print("environment: Jerome's Computer");
    } else {
      print("environment: Google Cloud");
    }
  }

  Future loadResources() async {
    await isometricScenes.load();
  }

  Future validate() async {
    AmuletGame.validate();

    final sceneDirectoryExists = await isometricScenes.sceneDirectory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: ${isometricScenes
          .sceneDirectoryPath}');
    }

  }

  void _fixedUpdate(Timer timer) {
    frame++;

    if (frame % 100 == 0) {
      removeEmptyGames();
    }
    for (final game in games) {
      game.updateJobs();
      game.update();
      game.writePlayerResponses();
    }
    sendResponseToClients();
  }

  void removeEmptyGames() {
    for (var i = 0; i < games.length; i++) {
      if (games[i].players.isNotEmpty) continue;
      print("removing empty game ${games[i]}");
      games.removeAt(i);
      i--;
    }
  }

  Player joinGameByType(GameType gameType) => joinGame(findGameByGameType(gameType));

  Game findGameByGameType(GameType gameType){
    for (final game in games) {
      if (game.isFull) continue;
      if (game.gameType != gameType) continue;
      return game;
    }
    final newInstance = createNewGameByType(gameType);
    games.add(newInstance);
    return newInstance;
  }

  Game createNewGameByType(GameType gameType) => switch (gameType){
      GameType.Amulet => buildGameMMO(),
      GameType.Editor => IsometricEditor(),
      _ => (throw Exception('gamestream.createNewGameByType(${gameType})'))
  };

  Game buildGameMMO() => AmuletGame(
      scene: isometricScenes.mmoTown,
      time: IsometricTime(enabled: true, hour: 14),
      environment: Environment(),
    );

  Player joinGame(Game game) {
    final player = game.createPlayer();
    if (!game.players.contains(player)){
      game.players.add(player);
    }
    return player;
  }

  void startServerWebsocket({required int port}){
    print("startServerWebsocket(port: $port)");
    var handler = webSocketHandler(
      onConnection,
      protocols: ['gamestream.online'],
    );

    shelf_io.serve(handler, '0.0.0.0', port).then((server) {
      print('Serving at wss://${server.address.host}:${server.port}');
    }).catchError((error){
      print("Websocket error occurred");
      print(error);
    });
  }

  void onConnection(WebSocketChannel webSocketChannel) {
    final connection = Connection(webSocketChannel, this);
    connections.add(connection);
    connection.onDone = () => onConnectionDone(connection);
    connectionsTotal++;
    print("Connection Added. Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
  }

  void onConnectionDone(Connection connection){
    if (connections.remove(connection)){
      print('gamestream_server - connection removed');
      print("Current Connections: ${connections.length}, Total Connections: $connectionsTotal");
    }
  }

  void sendResponseToClients(){
    final connections = this.connections; // cache in cpu
    for (final connection in connections) {
      connection.sendBufferToClient();
    }
  }


}