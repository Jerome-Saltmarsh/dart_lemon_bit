import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Player.dart';
import '../common/WeaponType.dart';
import '../enums/npc_mode.dart';
import '../instances/scenes.dart';

class Tavern extends Game {
  late InteractableNpc oscar;

  Tavern() : super(scenes.tavern){
    oscar = InteractableNpc(
        name: "Oscar",
        onInteractedWith: onOscarInteractedWith,
        x: 0,
        y: 100,
        health: 100,
        weapon: WeaponType.Unarmed
    );
    oscar.mode = NpcMode.Ignore;
    npcs.add(oscar);
  }

  void onOscarInteractedWith(Player player){
    player.message = "What do you need?";
  }

  @override
  void update() {

  }

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }
}
