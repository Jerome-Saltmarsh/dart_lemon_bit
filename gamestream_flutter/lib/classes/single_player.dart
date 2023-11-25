

import 'dart:async';
import 'dart:typed_data';

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/classes/amulet_controller.dart';
import 'package:amulet_engine/classes/amulet_player.dart';
import 'package:gamestream_flutter/classes/amulet_scenes_flutter.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_parser.dart';


class SinglePlayer {

  var amuletLoaded = false;

  final IsometricNetwork network;
  final streamController = StreamController();
  final IsometricParser parser;

  late final AmuletPlayer player;
  late final AmuletController controller;

  late final Amulet amulet;

  SinglePlayer({
    required this.network,
    required this.parser,
  }) {
    // network.websocket.sink = streamController.sink;
  }

  void update(){
    if (!amuletLoaded){
      return;
    }
    amulet.update();
  }

  void onFixedUpdate() {
    if (!amuletLoaded){
      return;
    }

    final bytes = player.compile();
    parser.parseBytes(bytes);
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
      await amulet.construct(initializeUpdateTimer: false);
      player = amulet.buildPlayer();
      controller = AmuletController(
          player: player,
          isAdmin: true,
          sink: streamController.sink,
          handleClientRequestJoin: handleClientRequestJoin,
      );
      controller.playerJoinAmuletTown();
      controller.player.regainFullHealth();
      controller.player.maxHealth =  10;
      controller.player.health = 10;
      controller.player.active = true;
      amuletLoaded = true;
      network.events.onConnected();
    }
  }

  void handleClientRequestJoin(List<String> arguments){

  }
}

