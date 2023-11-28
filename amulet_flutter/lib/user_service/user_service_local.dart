

import 'dart:convert';

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/type_def/json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amulet_engine/classes/amulet_controller.dart';
import 'package:amulet_engine/classes/amulet_player.dart';
import 'package:amulet_flutter/classes/amulet_scenes_flutter.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';

import 'user_service.dart';


class UserServiceLocal implements UserService {

  var amuletLoaded = false;
  var connected = false;

  final IsometricParser parser;

  late final SharedPreferences sharedPreferences;
  late final AmuletPlayer player;
  late final AmuletController controller;
  late final Amulet amulet;

  static const FIELD_CHARACTERS = 'characters';

  UserServiceLocal({
    required this.parser,
  });

  void initialize(SharedPreferences sharedPreferences){
    this.sharedPreferences = sharedPreferences;
  }

  List<String> getCharacterNames() {
    return sharedPreferences.getStringList(FIELD_CHARACTERS) ?? [];
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

  Future playerJoin() async {
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
    player.clearCache();
    handleClientRequestJoin([]);
  }

  void handleClientRequestJoin(List<String> arguments){
    controller.playerJoinGameTutorial();
    player.regainFullHealth();
    player.maxHealth =  10;
    player.health = 10;
    player.active = true;
    amulet.resumeUpdateTimer();
    parser.server.onServerConnectionEstablished();
    connected = true;
  }

  void disconnect() {
    connected = false;
    parser.options.game.value = parser.website;
    amulet.updateTimer?.cancel();
    amulet.timerRefreshUserCharacterLocks?.cancel();
  }

  @override
  void createNewCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) {
    final characterNames = getCharacterNames();
    if (characterNames.contains(name)){
      throw Exception('character with that name already exists');
    }
    characterNames.add(name);
    saveCharacterNames(characterNames);
    final json = Json();
    json['complexion'] = complexion;
    json['hairType'] = hairType;
    json['hairColor'] = hairColor;
    json['gender'] = gender;
    json['headType'] = headType;
    final jsonString = jsonEncode(json);
    sharedPreferences.setString(name, jsonString);

    playerJoin().then((value) {
      player.name = name;
      player.complexion = complexion;
      player.hairType = hairType;
      player.hairColor = hairColor;
      player.gender = gender;
      player.headType = headType;
      controller.playerJoinGameTutorial();
      player.regainFullHealth();
      player.maxHealth =  10;
      player.health = 10;
      player.active = true;
      amulet.resumeUpdateTimer();
      parser.server.onServerConnectionEstablished();
      connected = true;
    });

  }
}

