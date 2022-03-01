import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/SlotType.dart';
import '../common/WeaponType.dart';
import '../enums/npc_mode.dart';
import '../instances/scenes.dart';
import 'world.dart';

class Tavern extends Game {
  late InteractableNpc oscar;

  Tavern() : super(scenes.tavern){
    oscar = InteractableNpc(
        name: "Oscar",
        onInteractedWith: onOscarInteractedWith,
        x: 0,
        y: 100,
        health: 100,
        weapon: SlotType.Empty,
    );
    npcs.add(oscar);
  }

  void onOscarInteractedWith(Player player){
    player.message = "What do you need?";
  }

  @override
  void update() {

  }

  @override
  int getTime() {
    return worldTime;
  }
}
