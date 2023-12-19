

import 'dart:async';
import 'dart:typed_data';

import 'package:amulet_engine/classes/amulet_game_witches_lair.dart';
import 'package:archive/archive.dart';

import '../packages/src.dart';
import 'amulet_game.dart';
import 'amulet_game_world_00.dart';
import 'amulet_game_tutorial.dart';
import 'amulet_game_world_11.dart';
import 'amulet_player.dart';
import 'amulet_scenes.dart';

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
  late final AmuletGame amuletGameWorld11;
  late final AmuletGame amuletGameWorld12;
  late final AmuletGame amuletGameWorld20;
  late final AmuletGame amuletGameWorld21;
  late final AmuletGame amuletGameWorld22;

  late final AmuletGame amuletGameWitchesLair;

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
      name: 'world_01_01',
    );

    amuletGameWorld11 = AmuletGameWorld11(amulet: this);

    worldMap.add(amuletGameWorld00);
    worldMap.add(buildEmptyField(AmuletScene.World_01));
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

    amuletGameWitchesLair = AmuletGameWitchesLair(
      amulet: this,
      scene: scenes.witchesLair,
      time: timeUnderground,
      environment: environmentUnderground,
    );

    games.add(amuletGameWitchesLair);

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
        target: amuletGameWorld00,
        sceneKey: 'player_spawn',
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

  void resetPlayer(AmuletPlayer player) {
    playerChangeGameToTown(player);
    final weapons = player.weapons;
    for (final weapon in weapons) {
      weapon.clear();
    }
    for (final weapon in player.items) {
      weapon.clear();
    }
    for (final treasure in player.treasures) {
      treasure.clear();
    }
    weapons[0].amuletItem = AmuletItem.Weapon_Rusty_Old_Sword;
    weapons[1].amuletItem = AmuletItem.Weapon_Old_Bow;
    weapons[2].amuletItem = AmuletItem.Spell_Heal;
    amuletTime.hour = 12;
    player.elementPoints = 0;
    player.elementFire = 0;
    player.elementWater = 0;
    player.elementElectricity = 0;
    player.level = 1;
    player.experience = 0;
    player.equippedHelm.clear();
    player.equippedHandRight.clear();
    player.equippedHandLeft.clear();
    player.equippedBody.clear();
    player.equippedLegs.clear();
    player.equippedShoe.clear();
    player.equippedBody.amuletItem = AmuletItem.Armor_Shirt_Blue_Worn;
    player.equippedLegs.amuletItem = AmuletItem.Pants_Travellers;
    player.health = player.maxHealth;
    player.characterState = CharacterState.Idle;
    player.equipmentDirty = true;
    player.refillItemSlotsWeapons();
    player.clearActionFrame();
  }
}