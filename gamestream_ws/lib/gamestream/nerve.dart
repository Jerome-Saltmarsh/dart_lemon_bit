import 'dart:async';
import 'dart:io';

import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/gamestream/server.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:gamestream_ws/packages.dart';
import 'amulet.dart';
import 'functions/map_isometric_player_to_json.dart';

class Nerve {
  late final Amulet amulet;
  late final Server server;
  final UserService userService;
  final bool admin;

  Nerve({
    required this.userService,
    this.admin = false,
  }){
    server = Server(nerve: this);
    amulet = Amulet(nerve: this);
    _construct();
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
      if (player is AmuletPlayer)
        performAutoSave(player);
    }
  }

  void performAutoSave(AmuletPlayer player) {
    final characterJson = mapIsometricPlayerToJson(player);
    characterJson['auto_save'] = DateTime.now().toUtc().toIso8601String();
    userService.saveUserCharacter(
      userId: player.userId,
      character: characterJson,
    );
  }
}