

import 'package:amulet_engine/classes/amulet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amulet_engine/classes/amulet_controller.dart';
import 'package:amulet_engine/classes/amulet_player.dart';
import 'package:amulet_flutter/classes/amulet_scenes_flutter.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';


class LocalServer {

  var amuletLoaded = false;
  var connected = false;

  final IsometricParser parser;

  late final SharedPreferences sharedPreferences;
  late final AmuletPlayer player;
  late final AmuletController controller;
  late final Amulet amulet;

  static const FIELD_CHARACTERS = 'characters';

  LocalServer({
    required this.parser,
  });

  void initialize(SharedPreferences sharedPreferences){
    this.sharedPreferences = sharedPreferences;
  }

  List<String> getCharacterNames() {
    return sharedPreferences.getStringList(FIELD_CHARACTERS) ?? [];
  }

  void createCharacter(String name) {
    final characterNames = getCharacterNames();
    characterNames.add(name);
    saveCharacterNames(characterNames);
  }

  void saveCharacterNames(List<String> names) =>
      sharedPreferences.setStringList(FIELD_CHARACTERS, names);

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
    connected = true;
    controller.playerJoinAmuletTown();
    controller.player.regainFullHealth();
    controller.player.maxHealth =  10;
    controller.player.health = 10;
    controller.player.active = true;
    amulet.resumeUpdateTimer();
    parser.server.onServerConnectionEstablished();
  }

  void disconnect() {
    connected = false;
    parser.options.game.value = parser.website;
    amulet.updateTimer?.cancel();
    amulet.timerRefreshUserCharacterLocks?.cancel();
  }

}

