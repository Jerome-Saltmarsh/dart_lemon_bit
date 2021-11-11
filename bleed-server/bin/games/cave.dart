import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/Weapons.dart';
import '../instances/scenes.dart';
import 'world.dart';

class Cave extends Game {

  Cave(World world) : super(world, scenes.cave, 64){
    InteractableNpc john = InteractableNpc(
        name: "John",
        onInteractedWith: (Player player){
          playerChangeGame(player, world.town);
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
}
