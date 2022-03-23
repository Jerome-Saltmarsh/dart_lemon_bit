

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/randomItem.dart';

import '../classes/Character.dart';
import '../classes/EnvironmentObject.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../common/enums/ObjectType.dart';
import '../engine.dart';

class GameSkirmish extends Game {
  late final List<EnvironmentObject> _flags;
  final _time = 16 * 60 * 60;

  GameSkirmish() : super(engine.scenes.skirmish){
     _flags = scene.environment.where((env) => env.type == ObjectType.Flag).toList();
  }

  @override
  void update(){
    if (duration % 100 == 0) {
      if (numberOfAliveZombies < 10){
        spawnRandomZombie(health: 10, damage: 1);
      }
    }
  }

  @override
  int getTime() {
    return _time;
  }

  Player playerJoin() {
    final location = getNextSpawnPoint();
    final player = Player(
      x: location.x,
      y: location.y,
      game: this,
      team: teams.none,
      weapon: SlotType.Handgun,
    );
    return player;
  }

  @override
  Vector2 getNextSpawnPoint(){
    return randomItem(_flags);
  }

  @override
  void onCharacterKilled(Character killed, Character by) {
    // drop random loot
  }
}