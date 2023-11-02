

import 'dart:async';

import 'package:gamestream_ws/amulet/classes/amulet_game.dart';
import 'package:gamestream_ws/amulet/classes/amulet_game_town.dart';
import 'package:gamestream_ws/amulet/classes/amulet_game_tutorial.dart';
import 'package:gamestream_ws/amulet/classes/amulet_player.dart';
import 'package:gamestream_ws/amulet/classes/fiend_type.dart';
import 'package:gamestream_ws/gamestream.dart';
import 'package:gamestream_ws/isometric/classes/isometric_environment.dart';
import 'package:gamestream_ws/isometric/classes/isometric_time.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_scene.dart';
import 'package:gamestream_ws/packages/common/src/duration_auto_save.dart';

import '../../isometric/classes/scenes.dart';

class Amulet {

  final Nerve nerve;

  Amulet({required this.nerve});

  static const Frames_Per_Second = 45;
  static const Fixed_Time = 50 / Frames_Per_Second;

  var frame = 0;
  final amuletTime = IsometricTime();
  final amuletEnvironment = IsometricEnvironment();
  final games = <AmuletGame>[];
  final scenes = Scenes();
  var _updateTimerInitialized = false;

  late final Timer updateTimer;
  late final Timer timerRefreshUserCharacterLocks;

  final tutorialTime = IsometricTime(hour: 24, enabled: false);
  final tutorialEnvironment = IsometricEnvironment(enabled: false);

  late final AmuletGame amuletGameTown;
  late final AmuletGame amuletRoad01;
  late final AmuletGame amuletRoad02;

  final rows = 3;
  final columns = 3;
  final worldMap = <AmuletGame>[];

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

  void validate() async {

    final sceneDirectoryExists = await scenes.sceneDirectory.exists();

    if (!sceneDirectoryExists) {
      throw Exception('could not find scenes directory: ${scenes
          .sceneDirectoryPath}');
    }
  }

  Future construct() async {
    AmuletItem.values.forEach((item) => item.validate());
    await scenes.load();
    _initializeUpdateTimer();
    _initializeTimerAutoSave();
    _initializeGames();
  }

  void _initializeGames() {

    amuletGameTown = AmuletGameTown(
      amulet: this,
      scene: scenes.mmoTown,
      time: amuletTime,
      environment: amuletEnvironment,
      fiendTypes: [
        FiendType.Fallen_01,
      ],
      name: 'town',
    );

    amuletRoad01 = AmuletGame(
      amulet: this,
      scene: scenes.road01,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'road 1',
      fiendTypes: [
        FiendType.Fallen_01,
      ],
      amuletScene: AmuletScene.Road_01,
    );

    amuletRoad02 = AmuletGame(
      amulet: this,
      scene: scenes.road02,
      time: amuletTime,
      environment: amuletEnvironment,
      name: 'road 2',
      fiendTypes: [
        FiendType.Fallen_01,
        FiendType.Skeleton_01,
      ],
      amuletScene: AmuletScene.Road_02,
    );

    games.add(amuletGameTown);
    games.add(amuletRoad01);
    games.add(amuletRoad02);

    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
    worldMap.add(amuletGameTown);
  }

  void _initializeUpdateTimer() {
    if (_updateTimerInitialized) {
      return;
    }
    _updateTimerInitialized = true;
    updateTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ Frames_Per_Second),
      _fixedUpdate,
    );
  }

  void _initializeTimerAutoSave() {
    timerRefreshUserCharacterLocks = Timer.periodic(
      durationAutoSave,
      nerve.applyAutoSave,
    );
  }

  void _fixedUpdate(Timer timer) {
    frame++;
    updateWorldMap();
    updateGames();
    nerve.server.sendResponseToClients();
  }

  void updateWorldMap() {
    const padding = 50.0;
    const paddingPlus = padding + 25;
    final worldMap = this.worldMap;
    final worldMapLength = worldMap.length;
    for (var i = 0; i < worldMapLength; i++) {
      final game = worldMap[i];
      final scene = game.scene;
      final rowsAbove = i % rows > 0;
      final rowsBelow = i % rows < rows - 1;
      final xMax = scene.rowLength - padding;

      if (rowsAbove || rowsAbove) {
        final players = game.players;
        for (var j = 0; j < players.length; j++) {
          final player = players[j];
          final playerX = player.x;
          if (rowsAbove && playerX < padding) {
            final targetGameIndex = i - 1;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            player.x = targetGame.scene.rowLength - paddingPlus;
            continue;
          }
          if (rowsBelow && playerX > xMax) {
            final targetGameIndex = i + 1;
            final targetGame = worldMap[targetGameIndex];
            playerChangeGame(player: player, target: targetGame);
            player.x = paddingPlus;
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

  // void connectNorthSouth(AmuletGame a, AmuletGame b){
  //   a.gameNorth = b;
  //   b.gameSouth = a;
  // }

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

  Player joinGame(Game game) {
    final player = game.createPlayer();
    final players = game.players;
    if (!players.contains(player)){
      players.add(player);
    }
    return player;
  }

  AmuletGame addGame(AmuletGame game) {
    if (!games.contains(game)){
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

  void removeGame(Game game){
    games.remove(game);
  }
}