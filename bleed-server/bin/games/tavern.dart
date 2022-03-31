import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../engine.dart';
import 'world.dart';

class Tavern extends Game {
  late InteractableNpc oscar;

  Tavern() : super(engine.scenes.tavern){
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
