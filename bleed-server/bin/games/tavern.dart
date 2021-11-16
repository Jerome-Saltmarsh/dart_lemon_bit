import 'package:lemon_math/diff_over.dart';

import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
import '../functions/withinRadius.dart';
import '../instances/scenes.dart';
import '../values/world.dart';

class Tavern extends Game {
  final Vector2 doorPosition = Vector2(85, 250);
  final Vector2 spawnPosition = Vector2(63, 228);

  late InteractableNpc oscar;

  Tavern() : super(scenes.tavern, 64){
    oscar = InteractableNpc(
        name: "Oscar",
        onInteractedWith: onOscarInteractedWith,
        x: 0,
        y: 100,
        health: 100,
        weapon: Weapon.Unarmed
    );
    oscar.mode = NpcMode.Ignore;
    npcs.add(oscar);
  }

  void onOscarInteractedWith(Player player){
    player.message = "What do you need?";
  }

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return spawnPosition;
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    for (int i = 0; i < players.length; i++) {
      Player player = players[i];
      if (!withinRadius(player, doorPosition, 15)) continue;
      changeGame(player, world.town);
      i--;
    }
  }

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }
}
