

import 'dart:convert';

import 'package:amulet_client/classes/amulet_client.dart';
import 'package:amulet_client/interfaces/connection.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_server/classes/amulet.dart';
import 'package:amulet_server/src.dart';
import 'package:amulet_client/components/isometric_parser.dart';
import 'package:amulet_client/components/isometric_player.dart' as PlayerClient;
import 'package:lemon_json/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amulet_scenes_flutter.dart';

class ConnectionEmbedded implements Connection {

  var initialized = false;
  var connected = false;

  final IsometricParser parser;
  final SharedPreferences sharedPreferences;

  late final AmuletPlayer serverPlayer;
  late final PlayerClient.IsometricPlayer clientPlayer;
  late final AmuletController serverRequestParser;
  late final Amulet serverAmulet;
  final AmuletClient clientAmulet;

  Function onDisconnect;

  static const FIELD_CHARACTERS = '46700e18-b438-441b-ae2f-9139652901c5';

  ConnectionEmbedded({
    required this.onDisconnect,
    required this.parser,
    required this.clientPlayer,
    required this.sharedPreferences,
    required this.clientAmulet,
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
    parser.add(serverPlayer.compile());
  }

  void send(dynamic data) {
     serverRequestParser.onData(data);
  }

  Future ensureInitialized() async {
    if (initialized) {
      return;
    }
    final scenes = AmuletScenesFlutter();

    serverAmulet = Amulet(
      onFixedUpdate: onFixedUpdate,
      isLocalMachine: true,
      scenes: scenes,
      fps: 45,
    );
    await serverAmulet.construct(initializeUpdateTimer: true);
    serverPlayer = AmuletPlayer(
        amuletGame: serverAmulet.amuletGameVillage,
        itemLength: 6,
        x: 0,
        y: 0,
        z: 0,
    );
    serverRequestParser = AmuletController(
      player: serverPlayer,
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
    serverAmulet.stop();
    serverPlayer.flags.clear();
    serverPlayer.sceneShrinesUsed.clear();
    serverPlayer.clearCache();
    serverPlayer.x = 0.0;
    serverPlayer.y = 0;
    serverPlayer.z = 0;
    serverPlayer.mouseX = 0;
    serverPlayer.mouseY = 0;
    serverPlayer.positionCacheX = 0;
    serverPlayer.positionCacheY = 0;
    serverPlayer.positionCacheZ = 0;
    serverPlayer.screenLeft = 0;
    serverPlayer.screenTop = 0;
    serverPlayer.screenRight = 0;
    serverPlayer.screenBottom = 0;
    serverPlayer.sceneDownloaded = false;
    serverPlayer.initialized = false;
    serverPlayer.characterState = CharacterState.Idle;
    serverPlayer.target = null;
    serverPlayer.interacting = false;
    serverPlayer.controlsEnabled = true;
    serverPlayer.setDestinationToCurrentPosition();
    parser.amulet.clearAllState();
    onDisconnect();
  }

  Future persistPlayerServer(){
    final playerJson = writeAmuletPlayerToJson(serverPlayer);
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
    serverPlayer.difficulty = difficulty;
    serverPlayer.uuid = generateUUID();
    serverPlayer.name = name;
    serverPlayer.complexion = complexion;
    serverPlayer.hairType = hairType;
    serverPlayer.hairColor = hairColor;
    serverPlayer.gender = gender;
    serverPlayer.headType = headType;
    serverPlayer.uuid = generateUUID();
    parser.amulet.windowVisibleQuests.value = true;
    serverAmulet.resetPlayer(serverPlayer);
    parser.amulet.onNewCharacterCreated();
    final json = writeAmuletPlayerToJson(serverPlayer);
    final characters = getCharacterSync();
    characters.add(json);
    await persistCharacters(characters);
    playCharacter(serverPlayer.uuid);
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
      clientAmulet.components.network.connection = this;
      writeJsonToAmuletPlayer(character, serverPlayer);
      serverPlayer.writePlayerMoved();
      serverAmulet.resumeUpdateTimer();
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

