import 'package:lemon_math/diff_over.dart';

import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/interactable_npc.dart';
import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
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

    // 318 324
    double radius = 10;
    for(int i = 0; i < players.length; i++){
      Player player = players[i];
      if (diffOver(player.x, 318, radius)) continue;
      if (diffOver(player.y, 324, radius)) continue;
      changeGame(player, world.town);
      i--;
    }
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return Vector2(308, 338);
  }
}
