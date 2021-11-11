import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../common/functions/giveOrTake.dart';
import '../common/functions/randomPositionAround.dart';
import '../instances/scenes.dart';
import 'world.dart';

class Cave extends Game {

  late InteractableNpc john;

  Cave(World world) : super(world, scenes.cave, 64){
    john = InteractableNpc(
        name: "John",
        onInteractedWith: (Player player){
          changeGame(player, world.town);
        },
        x: 0,
        y: 300,
        health: 100,
        weapon: Weapon.Unarmed
    );
    john.mode = NpcMode.Ignore;
    npcs.add(john);
  }

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return randomPositionAround(john.x, john.y, 50);
  }
}
