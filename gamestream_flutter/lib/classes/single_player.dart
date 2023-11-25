

import 'dart:async';
import 'dart:typed_data';

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/classes/amulet_game.dart';
import 'package:amulet_engine/classes/amulet_player.dart';
import 'package:amulet_engine/packages/isometric_engine/classes/isometric_environment.dart';
import 'package:amulet_engine/packages/isometric_engine/classes/isometric_time.dart';
import 'package:amulet_engine/packages/isometric_engine/classes/scene.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_parser.dart';
// import 'package:amulet_engine/classes/src.dart';


class SinglePlayer {

  final IsometricNetwork network;
  final streamController = StreamController();
  final IsometricParser parser;

  late final _initGame = AmuletGame(
      amulet: amulet,
      scene: Scene(
        name: 'loading',
        types: Uint8List(0),
        shapes: Uint8List(0),
        variations: Uint8List(0),
        height: 0,
        rows: 0,
        columns: 0,
        gameObjects: [],
        marks: [],
      ),
      time: IsometricTime(),
      environment: IsometricEnvironment(),
      name: '',
      amuletScene: AmuletScene.Generated,
  );

  late final player = AmuletPlayer(
      amuletGame: _initGame,
      itemLength: 6,
      x: 0,
      y: 0,
      z: 0,
  );

  late final amulet = Amulet(
      onFixedUpdate: onFixedUpdate,
      isLocalMachine: true,
  );

  SinglePlayer({
    required this.network,
    required this.parser,
  }) {
    // network.websocket.sink = streamController.sink;
  }

  void update(){

  }

  void onFixedUpdate() {
     parser.parseBytes(player.compile());
  }

  void send(Uint8List bytes){

  }
}

