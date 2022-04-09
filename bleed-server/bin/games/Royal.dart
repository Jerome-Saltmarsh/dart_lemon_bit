import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import '../classes/Game.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/SlotType.dart';
import '../engine.dart';
import '../functions/withinRadius.dart';
import '../utilities.dart';

class GameRoyal extends Game {

  final boundaryRadiusShrinkRate = 0.05;
  final time = calculateTime(hour: 9);
  var boundaryCenter = Vector2(0, 0);
  var boundaryRadius = 2000.0;

  get _randomSpawnRadius => 500;
  get randomX => boundaryCenter.x + giveOrTake(_randomSpawnRadius);
  get randomY => boundaryCenter.y + giveOrTake(_randomSpawnRadius);

  GameRoyal() : super(engine.scenes.royal, gameType: GameType.BATTLE_ROYAL) {
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
    boundaryCenter = getSceneCenter();
    for (final zombie in zombies) {
      zombie.team = -2;
      zombie.maxHealth = 3;
      zombie.health = 3;
    }
  }

  int get playersRequired => teamSize * numberOfTeams;

  @override
  bool onPlayerItemCollision(Player player, Item item){
    return false;
  }


  Player playerJoin() {
    if (status != GameStatus.Awaiting_Players) {
      throw Exception("Game already started");
    }
    final spawnPoint = getNextSpawnPoint();
    final player = Player(
      game: this,
      x: spawnPoint.x,
      y: spawnPoint.y,
      team: -1,
      weapon: SlotType.Empty,
    );
    if (players.length >= playersRequired) {
      status = GameStatus.Counting_Down;
    }
    return player;
  }

  @override
  void onPlayerDisconnected(Player player) {
    if (inProgress) {
      onPlayerDeath(player);
    } else if (countingDown){
      // status = GameStatus.Awaiting_Players;
      // _countDownFrame = _totalCountdownFrames;
    }
  }

  @override
  void onPlayerDeath(Player player) {
    if (numberOfAlivePlayers == 1) {
      // status = GameStatus.Finished;
    }
  }

  @override
  int getTime() {
    return time;
  }

  @override
  void update(){
    boundaryRadius -= boundaryRadiusShrinkRate;
    _killPlayersOutsideBoundary();

    // for (final player in players) {
    //   for (int i = 0; i < crates.length; i++) {
    //     final crate = crates[i];
    //     if (!withinRadius(player, crate, 30)) continue;
    //     final index = getIndexOfWeaponType(player, WeaponType.HandGun);
    //     if (index >= 0) continue;
    //     // player.weapons.add(Weapon(
    //     //   type: WeaponType.HandGun,
    //     //   damage: 5,
    //     //   capacity: 12,
    //     // ));
    //     // player.weaponsDirty = true;
    //     crates.removeAt(i);
    //     cratesDirty = true;
    //     i--;
    //   }
    // }

    return;
  }

  void _killPlayersOutsideBoundary() {
    for (Player player in players) {
      if (player.dead) continue;
      if (withinDeathBoundary(player)) continue;
      setCharacterStateDead(player);
    }
  }

  bool withinDeathBoundary(Vector2 position){
    return withinRadius(position, boundaryCenter, boundaryRadius);
  }
}



