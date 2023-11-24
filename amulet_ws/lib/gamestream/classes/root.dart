import 'dart:async';
import 'dart:io';

import 'package:gamestream_ws/gamestream/classes/connection.dart';
import 'package:gamestream_ws/gamestream/classes/server.dart';
import 'package:gamestream_ws/packages/amulet_engine/classes/amulet.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:gamestream_ws/packages.dart';
import '../functions/map_isometric_player_to_json.dart';
import 'package:typedef/json.dart';

class Root {
  late final Amulet amulet;
  late final Server server;
  final UserService userService;
  final bool admin;

  Root({
    required this.userService,
    this.admin = false,
    int port = 8080,
  }){
    server = Server(root: this, port: port);
    amulet = Amulet(
      onFixedUpdate: onFixedUpdate,
      isLocalMachine: isLocalMachine,
    );
    _construct();
  }

  void onFixedUpdate(){
    server.sendResponseToClients();
  }

  Future _construct() async {
    printSystemInformation();
    await amulet.construct();
    await server.construct();
  }

  void printSystemInformation() {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');
    print("environment: ${isLocalMachine
        ? "Jerome's Computer" : "Google Cloud"}");
  }

  void applyAutoSave(_){
    print('nerve.applyAutoSave()');
    final connections = server.connections;
    for (final connection in connections){
      final player = connection.player;
      performAutoSave(player);
    }
  }

  void performAutoSave(AmuletPlayer player) {
    final characterJson = mapIsometricPlayerToJson(player);
    characterJson['auto_save'] = DateTime.now().toUtc().toIso8601String();
    persistPlayer(player, characterJson);
  }

  void onDisconnected(Connection connection) {
    if (!connection.playerCreated){
      return;
    }
    final player = connection.player;
    if (player.persistOnDisconnect){
      final characterJson = mapIsometricPlayerToJson(player);
      characterJson.remove('auto_save');
      persistPlayer(player, characterJson);
    }
    connection.leaveCurrentGame();

  }

  void persistPlayer(IsometricPlayer player, Json character) =>
    userService.saveUserCharacter(
      userId: player.userId,
      character: character,
    );
}