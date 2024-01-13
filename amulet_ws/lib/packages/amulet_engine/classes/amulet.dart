

import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../packages/isomeric_engine.dart';
import 'amulet_game.dart';
import 'amulet_player.dart';
import 'amulet_scenes.dart';
import 'games/amulet_game_tutorial.dart';
import 'games/witches_lair_1.dart';
import 'games/witches_lair_2.dart';
import 'games/amulet_game_world_00.dart';
import 'games/amulet_game_world_11.dart';

class Amulet {

  static const Frames_Per_Second = 45;
  static const Fixed_Time = 50 / Frames_Per_Second;

  var frame = 0;

  late final amuletGameLoading = AmuletGame(
      amulet: this,
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
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'loading',
      amuletScene: AmuletScene.Loading,
  );

  final amuletTime = IsometricTime();
  final amuletEnvironment = IsometricEnvironment();
  final games = <AmuletGame>[];
  final AmuletScenes scenes;
  final Function onFixedUpdate;
  final bool isLocalMachine;

  var _updateTimerInitialized = false;

  Timer? updateTimer;
  Timer? timerRefreshUserCharacterLocks;

  final environmentUnderground = IsometricEnvironment(enabled: false);
  final timeUnderground = IsometricTime(hour: 24, enabled: false);

  late final AmuletGame amuletGameWorld00;
  late final AmuletGame amuletGameWorld01;
  late final AmuletGame amuletGameWorld02;
  late final AmuletGame amuletGameWorld10;
  late final AmuletGameWorld11 amuletGameWorld11;
  late final AmuletGame amuletGameWorld12;
  late final AmuletGame amuletGameWorld20;
  late final AmuletGame amuletGameWorld21;
  late final AmuletGame amuletGameWorld22;

  late final AmuletGame amuletGameWitchesLair1;
  late final AmuletGame amuletGameWitchesLair2;

  static const mapSize = 100;
  final worldRows = 3;
  final worldColumns = 3;
  final worldMap = <AmuletGame>[];

  /// a minimap of all the worlds collapsed scene
  var worldMapBytes = Uint8List(0);
  var worldMapLocations = Uint8List(0);

  Amulet({
    required this.onFixedUpdate,
    required this.isLocalMachine,
    required this.scenes,
  });

  Future construct({required bool initializeUpdateTimer}) async {
    await scenes.load();

    if (initializeUpdateTimer){
      _initializeUpdateTimer();
      _initializeTimerAutoSave();
    }
    _initializeGames();
    _compileWorldMapBytes();
    compileWorldMapLocations();
  }

  AmuletGame getAmuletSceneGame(AmuletScene scene) {
    if (scene == AmuletScene.Tutorial){
     return buildAmuletGameTutorial();
    }
    final games = this.games;
    for (final game in games){
      if (game.amuletScene == scene){
         return game;
      }
    }
    throw Exception('amulet.getAmuletSceneGame("$scene")');
  }

  void _initializeGames() {

    amuletGameWorld00 = AmuletGameWorld00(
      amulet: this,
      scene: scenes.world_00,
      time: amuletTime,
      environment: amuletEnvironment,
    );

    amuletGameWorld01 = AmuletGame(
      amulet: this,
      scene: scenes.world_01,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'Black Woods',
      amuletScene: AmuletScene.World_01
    );

    amuletGameWorld11 = AmuletGameWorld11(amulet: this);

    worldMap.add(amuletGameWorld00);
    worldMap.add(amuletGameWorld01);
    worldMap.add(buildEmptyField(AmuletScene.World_02));
    worldMap.add(buildEmptyField(AmuletScene.World_10));
    worldMap.add(amuletGameWorld11);
    worldMap.add(buildEmptyField(AmuletScene.World_12));
    worldMap.add(buildEmptyField(AmuletScene.World_20));
    worldMap.add(buildEmptyField(AmuletScene.World_21));
    worldMap.add(buildEmptyField(AmuletScene.World_22));

    for (var i = 0; i < worldMap.length; i++){
      final game = worldMap[i];
      game.worldIndex = i;
      game.worldColumn = i % worldColumns;
      game.worldRow = i ~/ worldColumns;
      games.add(game);
    }

    amuletGameWitchesLair1 = WitchesLair1(
      amulet: this,
      scene: scenes.witchesLair1,
      time: timeUnderground,
      environment: environmentUnderground,
    );

    amuletGameWitchesLair2 = WitchesLair2(
      amulet: this,
      scene: scenes.witchesLair2,
      time: timeUnderground,
      environment: environmentUnderground,
    );

    games.add(amuletGameWitchesLair1);
    games.add(amuletGameWitchesLair2);

    for (final game in games){
      game.spawnMarkPortals();
    }

  }

  AmuletGame buildEmptyField(AmuletScene amuletScene) =>
    AmuletGame(
      amulet: this,
      scene: generateEmptyScene(
          rows: 100,
          columns: 100,
          name: amuletScene.name,
      ),
      time: amuletTime,
      environment: amuletEnvironment,
      name: amuletScene.name,
      amuletScene: amuletScene,
    );

  void _initializeUpdateTimer() {
    if (_updateTimerInitialized) {
      return;
    }
    _updateTimerInitialized = true;
    resumeUpdateTimer();
  }
  
  void resumeUpdateTimer(){
    updateTimer?.cancel();
    updateTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ Frames_Per_Second),
      _fixedUpdate,
    );
  }

  void _initializeTimerAutoSave() {
    timerRefreshUserCharacterLocks = Timer.periodic(
      durationAutoSave,
      applyAutoSave,
    );
  }

  void applyAutoSave(Timer timer){
    // root.applyAutoSave,
    // TODO onApplyAutoSave
  }

  void _fixedUpdate(Timer timer) {
   update();
  }

  void update(){
    frame++;
    updateWorldMap();
    updateGames();
    onFixedUpdate();
  }

  void updateWorldMap() {
    const padding = 50.0;
    const paddingPlus = padding + 25;
    final worldMap = this.worldMap;
    final worldMapLength = worldMap.length;
    for (var i = 0; i < worldMapLength; i++) {
      final game = worldMap[i];
      final scene = game.scene;
      final players = game.players;
      final worldRow = i ~/ worldColumns;
      final worldColumn = i % worldColumns;
      final rowsAbove = worldRow > 0;
      final rowsBelow = worldRow < worldRows - 1;
      final columnsAbove = worldColumn > 0;
      final columnsBelow = worldColumn < worldColumns - 1;
      final xMax = scene.rowLength - padding;
      final yMax = scene.columnLength - padding;
      var playerLength = players.length;

      if (rowsBelow || rowsAbove) {
        for (var j = 0; j < playerLength; j++) {
          final player = players[j];
          final playerX = player.x;
          if (rowsAbove && playerX < padding) {
            final targetGameIndex = i - worldColumns;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            playerLength--;
            player.setPosition(
              x: xMax - padding
            );
            continue;
          }
          if (rowsBelow && playerX > xMax) {
            final targetGameIndex = i + worldColumns;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            playerLength--;
            player.setPosition(x: paddingPlus);
            continue;
          }
        }
      }

      if (columnsBelow || columnsAbove) {
        for (var j = 0; j < playerLength; j++) {
          final player = players[j];
          final playerY = player.y;
          if (columnsAbove && playerY < padding) {
            final targetGameIndex = i - 1;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            playerLength--;
            player.setPosition(y: yMax - padding);
            continue;
          }
          if (columnsBelow && playerY > yMax) {
            final targetGameIndex = i + 1;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            playerLength--;
            player.setPosition(y: paddingPlus);
            continue;
          }
        }
      }
    }
  }

  void updateGames() {
    final games = this.games;
    for (var i = 0; i < games.length; i++) {
      final game = games[i];
      game.updateJobs();
      game.update();
      game.writePlayerResponses();
    }
  }

  AmuletGameTutorial buildAmuletGameTutorial(){
    final game = AmuletGameTutorial(
      amulet: this,
      scene: scenes.tutorial,
      time: timeUnderground,
      environment: environmentUnderground,
    );
    addGame(game);
    return game;
  }

  void removeEmptyGames() {
    for (var i = 0; i < games.length; i++) {
      if (games[i].players.isNotEmpty) continue;
      print("removing empty game ${games[i]}");
      games.removeAt(i);
      i--;
    }
  }

  AmuletGame addGame(AmuletGame game) {
    if (!games.contains(game)){
      print('amulet.addGame($game)');
      games.add(game);
    }
    return game;
  }

  void playerStartTutorial(AmuletPlayer player) =>
    playerChangeGame(
      player: player,
      target: buildAmuletGameTutorial(),
    );

  void playerChangeGameToTown(AmuletPlayer player) =>
      playerChangeGame(
        player: player,
        target: amuletGameWorld11,
        sceneKey: 'spawn_player',
      );

  void playerChangeGame({
    required AmuletPlayer player,
    required AmuletGame target,
    String? sceneKey,
  }){
    final currentGame = player.amuletGame;
    if (currentGame != target){
      currentGame.remove(player);
      player.setGame(target);
      target.add(player);
    }
    player.clearCache();
    if (sceneKey != null){
      target.scene.movePositionToKey(player, sceneKey);
      player.writePlayerMoved();
    }
  }

  void removeGame(AmuletGame game){
    games.remove(game);
  }

  void _compileWorldMapBytes() {
    print('amulet.compileWorldMapBytes()');
    final byteWriter = ByteWriter();
    final compressor = ZLibEncoder();
    for (var game in worldMap) {
      final flatNodes = game.flatNodes;
      byteWriter.writeUInt24(flatNodes.length);
      byteWriter.writeBytes(flatNodes);
    }
    final bytes = byteWriter.compile();
    final bytesCompressed = compressor.encode(bytes);
    worldMapBytes = Uint8List.fromList(bytesCompressed);
  }

  void compileWorldMapLocations() {
    final compressor = ZLibEncoder();
    final byteWriter = ByteWriter();
     for (final game in worldMap) {
       final scene = game.scene;
       final keys = scene.keys;
       for (final entry in keys.entries){
            final key = entry.key;
            if (key.startsWith('location_primary_')) {
              final index = entry.value;
              final text = key.replaceAll('location_primary_', '');
              byteWriter.writeBool(true);
              byteWriter.writeByte(game.worldRow);
              byteWriter.writeByte(game.worldColumn);
              byteWriter.writeString(text);
              byteWriter.writeUInt16(scene.getRow(index));
              byteWriter.writeUInt16(scene.getColumn(index));
            }
       }
     }
    byteWriter.writeBool(false);
    final bytes = byteWriter.compile();
    final bytesCompressed = compressor.encode(bytes);
    worldMapLocations = Uint8List.fromList(bytesCompressed);
  }

  void resetPlayer(AmuletPlayer player) {
    playerChangeGameToTown(player);
    for (final item in player.items) {
      item.clear();
    }
    for (final treasure in player.treasures) {
      treasure.clear();
    }
    // weapons[0].amuletItem = AmuletItem.Weapon_Short_Sword;
    // weapons[1].amuletItem = AmuletItem.Weapon_Old_Bow;
    // weapons[2].amuletItem = AmuletItem.Spell_Heal;
    amuletTime.hour = 12;
    player.elementPoints = 0;
    player.elementFire = 0;
    player.elementWater = 0;
    player.elementAir = 0;
    player.elementStone = 0;
    player.level = 1;
    player.experience = 0;
    player.equippedHelm.clear();
    player.equippedHandRight.clear();
    player.equippedHandLeft.clear();
    player.equippedBody.clear();
    player.equippedLegs.clear();
    player.equippedShoe.clear();
    player.equippedWeapon.amuletItem = null;
    player.equippedBody.amuletItem = AmuletItem.Armor_Shirt_Blue_Worn;
    player.equippedLegs.amuletItem = AmuletItem.Pants_Travellers;
    player.health = player.maxHealth;
    player.characterState = CharacterState.Idle;
    player.equipmentDirty = true;
    player.refillItemSlotsWeapons();
    player.clearActionFrame();
  }

  void revivePlayer(AmuletPlayer player) {
      if (player.game != amuletGameWorld11){
        playerChangeGameToTown(player);
      } else {
        amuletGameWorld11.movePositionToIndex(
            player,
            amuletGameWorld11.indexSpawnPlayer,
        );
      }

  }
}