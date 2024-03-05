

import 'dart:async';
import 'dart:typed_data';

import 'package:amulet_engine/isometric/classes/src.dart';
import 'package:amulet_engine/isometric/functions/generate_empty_scene.dart';
import 'package:archive/archive.dart';
import 'package:lemon_byte/src.dart';
import 'package:lemon_lang/src.dart';

import '../common/src.dart';
import 'amulet_game.dart';
import 'amulet_player.dart';
import 'amulet_scenes.dart';
import 'games/amulet_game_world_11.dart';
import 'games/witches_lair_1.dart';
import 'games/witches_lair_2.dart';

class Amulet {

  var fps = 45;
  var frame = 0;

  late final amuletGameLoading = AmuletGame(
      amulet: this,
      level: 0,
      scene: Scene(
        name: 'loading',
        nodeTypes: Uint8List(0),
        nodeOrientations: Uint8List(0),
        variations: Uint8List(0),
        height: 0,
        rows: 0,
        columns: 0,
        gameObjects: [],
        marks: [],
        keys: {},
        locations: {},
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
  Duration? updateTimerDuration;

  final environmentUnderground = IsometricEnvironment(enabled: false);
  final timeUnderground = IsometricTime(hour: 24, enabled: false);

  late AmuletGame amuletGameWorld00;
  late AmuletGame amuletGameWorld01;
  late AmuletGame amuletGameWorld02;
  late AmuletGame amuletGameWorld10;
  late AmuletGameWorld11 amuletGameVillage;
  late AmuletGame amuletGameWorld12;
  late AmuletGame amuletGameWorld20;
  late AmuletGame amuletGameWorld21;
  late AmuletGame amuletGameWorld22;

  late AmuletGame amuletGameWitchesLair1;
  late AmuletGame amuletGameWitchesLair2;

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
    this.fps = 45,
  });

  Future construct({required bool initializeUpdateTimer}) async {
    await scenes.load();

    if (initializeUpdateTimer){
      _initializeUpdateTimer();
      _initializeTimerAutoSave();
    }
    resetGames();
    _compileWorldMapBytes();
    compileWorldMapLocations();
  }

  AmuletGame getAmuletSceneGame(AmuletScene scene) {
    // if (scene == AmuletScene.Tutorial){
    //  return buildAmuletGameTutorial();
    // }
    final games = this.games;
    for (final game in games){
      if (game.amuletScene == scene){
         return game;
      }
    }
    throw Exception('amulet.getAmuletSceneGame("$scene")');
  }

  void resetGames() {

    games.clear();
    worldMap.clear();
    amuletTime.hour = 12;

    amuletGameWorld00 = AmuletGame(
      amulet: this,
      scene: scenes.world_00,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'Lost Swamps',
      amuletScene: AmuletScene.World_00,
      level: 3,
    );

    amuletGameWorld01 = AmuletGame(
      amulet: this,
      scene: scenes.world_01,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'Black Woods',
      amuletScene: AmuletScene.World_01,
      level: 2,
    );

    amuletGameVillage = AmuletGameWorld11(amulet: this);

    worldMap.add(amuletGameWorld00);
    worldMap.add(amuletGameWorld01);
    worldMap.add(buildEmptyField(AmuletScene.World_02));
    worldMap.add(buildEmptyField(AmuletScene.World_10));
    worldMap.add(amuletGameVillage);
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

    for (final game in games) {
      game.loadGameObjectsFromScene();
    }
  }

  AmuletGame buildEmptyField(AmuletScene amuletScene) =>
    AmuletGame(
      amulet: this,
      scene: generateEmptyScene(
          rows: 100,
          columns: 100,
          name: amuletScene.name,
          floorType: NodeType.Empty,
          nodeOrientation: NodeOrientation.None,
      ),
      time: amuletTime,
      environment: amuletEnvironment,
      name: amuletScene.name,
      amuletScene: amuletScene,
      level: 1,
    );

  void _initializeUpdateTimer() {
    if (_updateTimerInitialized) {
      return;
    }
    _updateTimerInitialized = true;
    resumeUpdateTimer();
  }
  
  void resumeUpdateTimer() => setFps(fps);

  void setFps(int value){
     fps = value;
     setUpdateTimerDuration(Duration(milliseconds: 1000 ~/ fps));
  }

  void setUpdateTimerDuration(Duration duration){
    updateTimer?.cancel();
    updateTimerDuration = duration;
    updateTimer = Timer.periodic(duration, _fixedUpdate);
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
      if (game.players.isEmpty) continue;
      // game.updateJobs();
      game.update();
      game.writePlayerResponses();
    }
  }

  // AmuletGameTutorial buildAmuletGameTutorial(){
  //   final game = AmuletGameTutorial(
  //     amulet: this,
  //     scene: scenes.tutorial,
  //     time: timeUnderground,
  //     environment: environmentUnderground,
  //   );
  //   addGame(game);
  //   return game;
  // }

  void removeEmptyGames() {
    for (var i = 0; i < games.length; i++) {
      if (games[i].players.isNotEmpty) continue;
      print("removing empty game ${games[i]}");
      games.removeAt(i);
      i--;
    }
  }

  // void playerStartTutorial(AmuletPlayer player) =>
  //   playerChangeGame(
  //     player: player,
  //     target: buildAmuletGameTutorial(),
  //   );

  AmuletGame addGame(AmuletGame game) {
    if (!games.contains(game)){
      print('amulet.addGame($game)');
      games.add(game);
    }
    return game;
  }

  void playerChangeGameToTown(AmuletPlayer player) =>
      playerChangeGame(
        player: player,
        target: amuletGameVillage,
        sceneKey: 'spawn_player',
      );

  void playerChangeGame({
    required AmuletPlayer player,
    required AmuletGame target,
    String? sceneKey,
    int? index,
  }){
    final currentGame = player.amuletGame;
    if (currentGame != target){
      currentGame.remove(player);
      player.setGame(target);
      target.add(player);
    }
    player.clearCache();
    player.setCharacterStateIdle();
    player.clearVelocity();
    if (sceneKey != null){
      target.scene.movePositionToKey(player, sceneKey);
      player.writePlayerMoved();
    }

    if (index != null) {
      target.scene.movePositionToIndex(player, index);
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
    resetGames();
    amuletTime.hour = 12;

    player.skillActiveLeft = true;
    player.skillTypeLeft = SkillType.None;
    player.skillTypeRight = SkillType.None;
    player.sceneShrinesUsed.clear();
    player.sceneDownloaded = false;
    player.equippedWeapon = null;
    player.equippedHelm = null;
    player.equippedArmor = null;
    player.equippedShoes = null;
    player.equipmentDirty = true;
    player.controlsEnabled = true;
    player.flags.clear();
    player.consumableSlots.fill(null);
    player.consumableSlots[0] = AmuletItem.Consumable_Potion_Health;
    player.consumableSlots[1] = AmuletItem.Consumable_Potion_Magic;
    player.consumableSlotsDirty = true;
    player.questMain = QuestMain.values.first;
    player.questTutorial = QuestTutorial.values.first;
    player.characterState = CharacterState.Idle;
    player.health = player.maxHealth;
    player.magic = player.maxMagic;
    player.clearCache();
    player.clearActionFrame();

    for (final game in games){
      game.spawnFiendsAtSpawnNodes();
      game.scene.resetShrines();
    }
    playerChangeGameToTown(player);
    player.amuletGame = amuletGameVillage;
    amuletGameVillage.movePositionToIndex(
      player,
      amuletGameVillage.indexSpawnPlayer,
    );
  }

  void revivePlayer(AmuletPlayer player) {
      if (player.game != amuletGameVillage){
        playerChangeGameToTown(player);
      } else {
        amuletGameVillage.movePositionToIndex(
            player,
            amuletGameVillage.indexSpawnPlayer,
        );
      }

  }

  AmuletGame findGame(AmuletScene amuletScene) {
     for (final game in games){
       if (game.amuletScene != amuletScene) continue;
       return game;
     }
     throw Exception('amulet.findGame($amuletScene) - 404');
  }
}