

import 'dart:convert';

import 'package:amulet_common/src.dart';
import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/isometric/classes/connection.dart';
import 'package:amulet_flutter/isometric/components/isometric_parser.dart';
import 'package:amulet_flutter/isometric/components/isometric_player.dart' as PlayerClient;
import 'package:lemon_json/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amulet_scenes_flutter.dart';

class ConnectionEmbedded implements Connection {

  var initialized = false;
  var connected = false;

  final IsometricParser parser;
  final SharedPreferences sharedPreferences;

  late final AmuletPlayer playerServer;
  late final PlayerClient.IsometricPlayer playerClient;
  late final AmuletController controller;
  late final Amulet amulet;

  Function onDisconnect;

  static const FIELD_CHARACTERS = '46700e18-b438-441b-ae2f-9139652901c5';

  ConnectionEmbedded({
    required this.onDisconnect,
    required this.parser,
    required this.playerClient,
    required this.sharedPreferences,
  });

  Future<List<Json>> getCharacters() async =>
      getCharacterSync();

  List<Json> getCharacterSync() =>
      (sharedPreferences.getStringList(FIELD_CHARACTERS) ?? [])
        .map(jsonDecode)
        .cast<Json>()
        .toList(growable: true);

  void onFixedUpdate() {
    if (!initialized){
      return;
    }
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
      fps: 45,
    );
    await amulet.construct(initializeUpdateTimer: true);
    playerServer = AmuletPlayer(
        amuletGame: amulet.amuletGameLoading,
        itemLength: 6,
        x: 0,
        y: 0,
        z: 0,
    );
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
  
  Future disconnect() async {
    await persistPlayerServer();
    connected = false;
    amulet.games.clear();
    amulet.worldMap.clear();
    playerServer.flags.clear();
    playerServer.sceneShrinesUsed.clear();
    playerServer.clearCache();
    playerServer.x = 0.0;
    playerServer.y = 0;
    playerServer.z = 0;
    playerServer.mouseX = 0;
    playerServer.mouseY = 0;
    playerServer.positionCacheX = 0;
    playerServer.positionCacheY = 0;
    playerServer.positionCacheZ = 0;
    playerServer.screenLeft = 0;
    playerServer.screenTop = 0;
    playerServer.screenRight = 0;
    playerServer.screenBottom = 0;
    playerServer.sceneDownloaded = false;
    playerServer.initialized = false;
    playerServer.characterState = CharacterState.Idle;
    playerServer.target = null;
    playerServer.interacting = false;
    playerServer.controlsEnabled = true;
    playerServer.amuletGame = amulet.amuletGameLoading;
    playerServer.setDestinationToCurrentPosition();
    parser.amulet.clearAllState();
    amulet.updateTimer?.cancel();
    amulet.timerRefreshUserCharacterLocks?.cancel();
    onDisconnect();
  }

  Future persistPlayerServer(){
    final playerJson = writeAmuletPlayerToJson(playerServer);
    final characters = getCharacterSync();
    final index = characters.indexWhere((element) => element.uuid == playerJson.uuid);
    if (index != -1){
      characters.removeAt(index);
      characters.insert(index, playerJson);
    } else {
      characters.add(playerJson);
    }
    return persistCharacters(characters);
  }

  @override
  Future createNewCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
    required Difficulty difficulty,
  }) async {
    await ensureInitialized();
    if (name == FIELD_CHARACTERS) {
      throw Exception('invalid field name');
    }
    playerServer.difficulty = difficulty;
    playerServer.uuid = generateUUID();
    playerServer.name = name;
    playerServer.complexion = complexion;
    playerServer.hairType = hairType;
    playerServer.hairColor = hairColor;
    playerServer.gender = gender;
    playerServer.headType = headType;
    playerServer.uuid = generateUUID();
    parser.amulet.windowVisibleQuests.value = true;
    amulet.resetPlayer(playerServer);
    parser.amulet.onNewCharacterCreated();
    final json = writeAmuletPlayerToJson(playerServer);
    final characters = getCharacterSync();
    characters.add(json);
    await persistCharacters(characters);
    playCharacter(playerServer.uuid);
  }

  Future persistCharacters(List<Json> characters) =>
      sharedPreferences.setStringList(
        FIELD_CHARACTERS,
        characters.map(jsonEncode).toList(growable: false),
      );

  Json? findCharacterByUuid(String uuid){
    final characters = getCharacterSync();
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
      playerClient.server.connection = this;
      writeJsonToAmuletPlayer(character, playerServer);
      playerServer.writePlayerMoved();
      amulet.resumeUpdateTimer();
      parser.server.onServerConnectionEstablished();
      connected = true;
    });
  }

  Future deleteCharacter(String uuid) async {
    final characters = getCharacterSync();
    for (var i = 0; i < characters.length; i++){
      final character = characters[i];
      if (character.uuid == uuid) {
        characters.remove(character);
        persistCharacters(characters);
        return;
      }
    }
    throw Exception('could not find character with uuid $uuid');
  }
}

