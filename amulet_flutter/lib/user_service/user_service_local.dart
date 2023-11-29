

import 'dart:convert';

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/user_service/character_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amulet_flutter/classes/amulet_scenes_flutter.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';
import 'package:typedef/json.dart';

import 'user_service.dart';


class UserServiceLocal implements UserService {

  var initialized = false;
  var connected = false;

  final IsometricParser parser;

  late final SharedPreferences sharedPreferences;
  late final AmuletPlayer player;
  late final AmuletController controller;
  late final Amulet amulet;

  static const FIELD_CHARACTERS = '46700e18-b438-441b-ae2f-9139652901c5';

  UserServiceLocal({
    required this.parser,
  });

  void initialize(SharedPreferences sharedPreferences){
    this.sharedPreferences = sharedPreferences;
    // sharedPreferences.clear();
  }

  List<Json> getCharacters() =>
      (sharedPreferences.getStringList(FIELD_CHARACTERS) ?? [])
        .map(jsonDecode)
        .cast<Json>()
        .toList(growable: true);

  List<String> getCharacterNames() =>
      getCharacters()
        .map((character) => character.getString('name'))
        .toList(growable: false);

  void onFixedUpdate() {
    if (!initialized){
      return;
    }
    parser.add(player.compile());
  }

  void send(dynamic data) {
     controller.onData(data);
  }

  Future ensureInitialized() async {
    if (initialized) {
      return;
    }
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
    initialized = true;
  }

  void handleClientRequestJoin(List<String> arguments){

  }

  void disconnect() {
    connected = false;
    player.clearCache();
    player.x = 0;
    player.y = 0;
    player.z = 0;
    parser.amulet.clearAllState();
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
    if (name == FIELD_CHARACTERS) {
      throw Exception('invalid field name');
    }

    ensureInitialized().then((value) {
      player.name = name;
      player.complexion = complexion;
      player.hairType = hairType;
      player.hairColor = hairColor;
      player.gender = gender;
      player.headType = headType;
      final json = mapIsometricPlayerToJson(player);
      final characters = getCharacters();
      characters.add(json);
      final characterStrings = characters.map(jsonEncode).toList(growable: false);
      sharedPreferences.setStringList(FIELD_CHARACTERS, characterStrings);
      playCharacter(json.uuid);
    });
  }

  Json? findCharacterByUuid(String uuid){
    final characters = getCharacters();
    for (final character in characters){
      if (character.getString('uuid') == uuid) {
        return character;
      }
    }
    return null;
  }

  void playCharacter(String characterUuid) {
    final character = findCharacterByUuid(characterUuid);
    if (character == null){
      throw Exception('character could not be found');
    }
    ensureInitialized().then((value) {
      player.maxHealth =  10;
      player.health = 10;
      player.active = true;
      writeJsonToAmuletPlayer(character, player);
      controller.playerJoinGameTutorial();
      player.regainFullHealth();
      amulet.resumeUpdateTimer();
      parser.server.onServerConnectionEstablished();
      connected = true;
    });
  }
}

