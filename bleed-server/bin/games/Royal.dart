import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import '../classes/Crate.dart';
import '../classes/Game.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/CharacterType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/ItemType.dart';
import '../common/WeaponType.dart';
import '../functions/withinRadius.dart';
import '../instances/scenes.dart';
import '../utilities.dart';

class GameRoyal extends Game {

  final List<Player> score = [];
  final boundaryRadiusShrinkRate = 0.05;
  double boundaryRadius = 1000;
  Vector2 boundaryCenter = Vector2(0, 0);

  final time = calculateTime(hour: 9);

  get _randomSpawnRadius => 500;
  double get randomX => boundaryCenter.x + giveOrTake(_randomSpawnRadius);
  double get randomY => boundaryCenter.y + giveOrTake(_randomSpawnRadius);

  GameRoyal() : super(scenes.royal, gameType: GameType.BATTLE_ROYAL) {
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
    boundaryCenter = getSceneCenter();

    for (int i = 0; i < 10; i++) {
      final crate = Crate(
          x: randomX,
          y: randomY,
      );
      crates.add(crate);
      cratesDirty = true;
    }

    for (int i = 0; i < 10; i++){
      final item = Item(type: ItemType.Handgun, x:  randomX, y: randomX);
      items.add(item);
    }
    sortVertically(items);
    sortVertically(crates);
  }

  int get playersRequired => teamSize * numberOfTeams;

  Player playerJoin() {
    if (status != GameStatus.Awaiting_Players) {
      throw Exception("Game already started");
    }
    Vector2 spawnPoint = getNextSpawnPoint();
    final Player player = Player(
      game: this,
      x: spawnPoint.x,
      y: spawnPoint.y,
      team: -1,
      type: CharacterType.Human,
    );
    if (players.length >= playersRequired) {
      status = GameStatus.Counting_Down;
    }
    return player;
  }

  @override
  void onPlayerDisconnected(Player player) {
    if (inProgress){
      onPlayerDeath(player);
    }else if (countingDown){
      // status = GameStatus.Awaiting_Players;
      // _countDownFrame = _totalCountdownFrames;
    }
  }

  @override
  void onPlayerDeath(Player player) {
    score.add(player);
    if (numberOfAlivePlayers == 1) {
      status = GameStatus.Finished;
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

    for (Player player in players) {
      for (int i = 0; i < crates.length; i++) {
        final crate = crates[i];
        if (!withinRadius(player, crate, 30)) continue;
        final index = getIndexOfWeaponType(player, WeaponType.HandGun);
        if (index >= 0) continue;
        player.weapons.add(Weapon(
          type: WeaponType.HandGun,
          damage: 5,
          capacity: 12,
        ));
        player.weaponsDirty = true;
        crates.removeAt(i);
        cratesDirty = true;
        i--;
      }
    }

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



