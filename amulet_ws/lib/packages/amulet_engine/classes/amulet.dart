

import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../packages/isometric_engine/packages/common/src/duration_auto_save.dart';
import '../packages/src.dart';
import 'amulet_game.dart';
import 'amulet_game_town.dart';
import 'amulet_game_tutorial.dart';
import 'amulet_player.dart';

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

  final tutorialTime = IsometricTime(hour: 24, enabled: false);
  final tutorialEnvironment = IsometricEnvironment(enabled: false);

  late final AmuletGame amuletGameTown;
  late final AmuletGame amuletRoad01;
  late final AmuletGame amuletRoad02;

  static const mapSize = 100;
  final worldRows = 3;
  final worldColumns = 3;
  final worldMap = <AmuletGame>[];

  /// a minimap of all the worlds collapsed scene
  var worldMapBytes = Uint8List(0);

  Amulet({
    required this.onFixedUpdate,
    required this.isLocalMachine,
    required this.scenes,
  });

  Future construct({required bool initializeUpdateTimer}) async {
    AmuletItem.values.forEach((item) => item.validate());
    await scenes.load();

    if (initializeUpdateTimer){
      _initializeUpdateTimer();
      _initializeTimerAutoSave();
    }
    _initializeGames();
    _compileWorldMapBytes();
  }

  AmuletPlayer buildPlayer() => AmuletPlayer(
      amuletGame: amuletGameLoading,
      itemLength: 6,
      x: 0,
      y: 0,
      z: 0,
  );

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

    amuletGameTown = AmuletGameTown(
      amulet: this,
      scene: scenes.mmoTown,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'town',
    );

    amuletRoad01 = AmuletGame(
      amulet: this,
      scene: scenes.road01,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'road 1',
      amuletScene: AmuletScene.Road_01,
    );

    amuletRoad02 = AmuletGame(
      amulet: this,
      scene: scenes.road02,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'road 2',
      amuletScene: AmuletScene.Road_02,
    );

    games.add(amuletGameTown);
    games.add(amuletRoad01);
    games.add(amuletRoad02);

    worldMap.add(amuletGameTown);
    worldMap.add(amuletRoad01);
    worldMap.add(amuletRoad02);
    worldMap.add(buildEmptyField());
    worldMap.add(buildEmptyField());
    worldMap.add(buildEmptyField());
    worldMap.add(buildEmptyField());
    worldMap.add(buildEmptyField());
    worldMap.add(buildEmptyField());

    for (var i = 0; i < worldMap.length; i++){
      final game = worldMap[i];
      game.worldIndex = i;
      game.worldColumn = i % worldColumns;
      game.worldRow = i ~/ worldColumns;
    }
  }

  AmuletGame buildEmptyField(){
    final instance = AmuletGame(
      amulet: this,
      scene: generateEmptyScene(rows: 100, columns: 100, name: 'generated'),
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'generated',
      amuletScene: AmuletScene.Generated,
    );
    games.add(instance);
    return instance;
  }

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
      time: tutorialTime,
      environment: tutorialEnvironment,
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

  void playerChangeGame({
    required AmuletPlayer player,
    required AmuletGame target,
    String? sceneKey,
  }){
    final currentGame = player.amuletGame;
    if (currentGame == target){
      return;
    }
    currentGame.remove(player);
    player.setGame(target);
    target.add(player);

    if (sceneKey != null){
      target.scene.movePositionToKey(player, sceneKey);
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

  void resetPlayer(AmuletPlayer player) {
    // final game = player.amuletGame;
    // game.clearSpawnedAI();
    // game.spawnFiendsAtSpawnNodes();
    playerChangeGame(player: player, target: amuletGameTown);
    player.setPosition(
      x: 620 + giveOrTake(10),
      y: 523 + giveOrTake(10),
      z: 96,
    );
    player.level = 1;
    player.experience = 0;
    final weapons = player.weapons;

    for (final weapon in weapons) {
      weapon.amuletItem = null;
      weapon.cooldown = 0;
      weapon.cooldownDuration = 0;
    }
    for (final weapon in player.items) {
      weapon.amuletItem = null;
      weapon.cooldown = 0;
      weapon.cooldownDuration = 0;
    }
    for (final weapon in player.treasures) {
      weapon.amuletItem = null;
      weapon.cooldown = 0;
      weapon.cooldownDuration = 0;
    }
    weapons[0].amuletItem = AmuletItem.Weapon_Rusty_Old_Sword;
    weapons[1].amuletItem = AmuletItem.Weapon_Old_Bow;
    weapons[2].amuletItem = AmuletItem.Spell_Heal;
    player.equippedHelm.clear();
    player.equippedHandRight.clear();
    player.equippedHandLeft.clear();
    player.equippedBody.clear();
    player.equippedLegs.clear();
    player.equippedShoe.clear();
    player.equippedBody.amuletItem = AmuletItem.Armor_Leather_Basic;
    player.equippedLegs.amuletItem = AmuletItem.Pants_Travellers;
    player.refillItemSlot(player.equippedBody);
    player.refillItemSlot(player.equippedLegs);
    player.refillItemSlotsWeapons();
    player.health = player.maxHealth;
    player.characterState = CharacterState.Idle;
    player.clearActionFrame();
    player.equipmentDirty = true;
    // player.writeWeapons();
  }
}