

import 'dart:convert';

import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/user_service/character_json.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_player.dart' as PlayerClient;
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
  late final AmuletPlayer playerServer;
  late final PlayerClient.IsometricPlayer playerClient;
  late final AmuletController controller;
  late final Amulet amulet;

  static const FIELD_CHARACTERS = '46700e18-b438-441b-ae2f-9139652901c5';

  UserServiceLocal({
    required this.parser,
    required this.playerClient,
  });

  void initialize(SharedPreferences sharedPreferences){
    this.sharedPreferences = sharedPreferences;
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

    playerClient.position.x = playerServer.x;
    playerClient.position.y = playerServer.y;
    playerClient.position.z = playerServer.z;
    playerServer.mouseX = playerClient.mouse.positionX;
    parser.add(playerServer.compile());
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
    playerServer = amulet.buildPlayer();
    controller = AmuletController(
      player: playerServer,
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
    playerServer.clearCache();
    playerServer.x = 0;
    playerServer.y = 0;
    playerServer.z = 0;
    playerServer.characterState = CharacterState.Idle;
    playerServer.target = null;
    playerServer.interacting = false;
    playerServer.setDestinationToCurrentPosition();
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
      playerServer.name = name;
      playerServer.complexion = complexion;
      playerServer.hairType = hairType;
      playerServer.hairColor = hairColor;
      playerServer.gender = gender;
      playerServer.headType = headType;
      final json = mapIsometricPlayerToJson(playerServer);
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
      playerServer.maxHealth =  10;
      playerServer.health = 10;
      playerServer.active = true;
      writeJsonToAmuletPlayer(character, playerServer);
      controller.playerJoinGameTutorial();
      playerServer.regainFullHealth();
      amulet.resumeUpdateTimer();
      parser.server.onServerConnectionEstablished();
      connected = true;
    });
  }

  Future deleteCharacter(String uuid) async {

  }
}

