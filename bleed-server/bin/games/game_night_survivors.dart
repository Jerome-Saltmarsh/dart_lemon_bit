
import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';
import '../scene_generator.dart';

/// THEY COME AT NIGHT
/// THE CURSED ISLAND
/// SURVIVAL ADVENTURE HORROR GAME
/// You and a band of others have been ship wrecked on a small paradise island
/// You must explore the island and find and gather up as much resources as possible
/// and bring them back to the camp to prepare for the night
/// At night the monsters come and attack the camp
/// Can you survive until morning?
/// How many days can you and your group survive?
/// Creating a fire costs 100 wood and lasts for a duration before burning out
class GameNightSurvivors extends Game {
  static const teamPlayers = 1;
  static const teamZombies = 2;
  static const spawnStart = 20 * 60 * 60;
  static const spawnEnd = 6 * 60 * 60;
  var time = spawnEnd;
  var spawnMode = false;
  late final StaticObject campFire;

  var lives = 10;

  bool get isFull => players.length >= 2;

  GameNightSurvivors() : super(
      generateRandomScene(
          rows: 230,
          columns: 230,
          seed: randomInt(0, 10000),
          numberOfSpawnPointPlayers: 1,
      )
  ) {

    final centerRow = scene.numberOfRows ~/ 2;
    final centerColumn = scene.numberOfColumns ~/ 2;
    final centerX = getTileWorldX(centerRow, centerColumn);
    final centerY = getTileWorldY(centerRow, centerColumn);


    campFire = StaticObject (
      x: 0,
      y: 0,
      type: ObjectType.Fireplace,
    );

    while(true){
       final angle = randomAngle();
       final distance = randomBetween(0, 500);
       final posX = centerX + getAdjacent(angle, distance);
       final posY = centerY + getOpposite(angle, distance);
       final node = scene.tileNodeAtXY(posX, posY);
       if (node.closed) continue;
       if (node.up.closed) continue;
       if (node.upRight.closed) continue;
       if (node.right.closed) continue;
       if (node.downRight.closed) continue;
       if (node.down.closed) continue;
       if (node.downLeft.closed) continue;
       if (node.left.closed) continue;
       if (node.upLeft.closed) continue;
       campFire.x = posX;
       campFire.y = posY;
       break;
    }
    objectsStatic.add(campFire);
    onStaticObjectsChanged();
    status = GameStatus.Awaiting_Players;
    const minSpawnRadius = 150;
    dynamicObjects.removeWhere((dynamicObject) {
      return campFire.getDistance(dynamicObject) < minSpawnRadius;
    });
    objectsStatic.removeWhere((value) {
      return value != campFire && campFire.getDistance(value) < minSpawnRadius;
    });
  }

  Player spawnPlayer() {
     while(true) {
       final angle = randomAngle();
       final posX = campFire.getPositionX(angle, tileSize);
       final posY = campFire.getPositionY(angle, tileSize);
       if (!scene.tileWalkableAt(posX, posY)) continue;
       return Player(
           game: this,
           weapon: TechType.Unarmed,
           x: posX,
           y: posY,
           team: teamPlayers
       );
     }

  }

  @override
  void update() {
    if (time > spawnStart || time < spawnEnd) {
      if (!spawnMode) {
        spawnMode = true;
        onSpawnModeStarted();
      }
      if (time % 45 == 0) {
        spawnMonster();
      }
    } else {
      if (spawnMode) {
        spawnMode = false;
        onSpawnModeEnded();
      }
    }
    time = (time + 5) % 86400;

    for (final zombie in zombies) {
      if (zombie.dead) continue;
      if (zombie.getDistance(campFire) > 50) continue;
      applyDamage(src: campFire, target: zombie, amount: 9999);
      reduceLife();
    }
  }

  void reduceLife(){
    if (lives <= 0) return;
    lives--;
    for (final player in players) {
      player.writeLivesRemaining(lives);
    }
    if (lives > 0) return;
    setGameStatus(GameStatus.Finished);
  }

  void spawnMonster(){
    final zombie = spawnRandomZombie();
    zombie.maxHealth = 2;
    zombie.health = 2;
    zombie.objective = campFire;
    zombie.team = teamZombies;
  }

  void onSpawnModeStarted(){

  }

  void onSpawnModeEnded(){

  }

  @override
  int getTime() {
    return time;
  }

  @override
  void onDamaged(dynamic target, dynamic src, int damage) {

  }

  @override
  void onKilled(dynamic target, dynamic src) {

  }

  @override
  void onPlayerJoined(Player player) {
    player.writeLivesRemaining(lives);

    if (isFull) {
      setGameStatus(GameStatus.Counting_Down);
    }
  }
}