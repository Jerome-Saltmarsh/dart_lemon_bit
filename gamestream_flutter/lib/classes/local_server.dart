

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/classes/amulet_controller.dart';
import 'package:amulet_engine/classes/amulet_player.dart';
import 'package:gamestream_flutter/classes/amulet_scenes_flutter.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_parser.dart';


class LocalServer {

  var amuletLoaded = false;

  final IsometricParser parser;

  late final AmuletPlayer player;
  late final AmuletController controller;
  late final Amulet amulet;

  LocalServer({
    required this.parser,
  });

  void onFixedUpdate() {
    if (!amuletLoaded){
      return;
    }
    parser.add(player.compile());
  }

  void send(dynamic data) {
     controller.onData(data);
  }

  void playerJoin() async {
    if (!amuletLoaded) {

      final scenes = AmuletScenesFlutter();

      amulet = Amulet(
          onFixedUpdate: onFixedUpdate,
          isLocalMachine: true,
          scenes: scenes,
      );
      await amulet.construct(initializeUpdateTimer: true);
      player = amulet.buildPlayer();
      controller = AmuletController(
          player: player,
          isAdmin: true,
          sink: parser,
          handleClientRequestJoin: handleClientRequestJoin,
      );
      amuletLoaded = true;
    }
    handleClientRequestJoin([]);
  }

  void handleClientRequestJoin(List<String> arguments){
    controller.playerJoinAmuletTown();
    controller.player.regainFullHealth();
    controller.player.maxHealth =  10;
    controller.player.health = 10;
    controller.player.active = true;
    parser.events.onConnected();
  }

  void disconnect() {
    parser.options.game.value = parser.website;
    amulet.updateTimer?.cancel();
    amulet.timerRefreshUserCharacterLocks?.cancel();
  }
}

