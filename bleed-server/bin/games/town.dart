
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../common/SlotType.dart';
import '../engine.dart';

class Town extends Game {
  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  Town() : super(engine.scenes.town) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: -100,
        y: 1650,
        health: 100,
        weapon: SlotType.Empty,
        team: Teams.west,
    );
    npcs.add(npcDavis);

    npcSmith = InteractableNpc(
        name: "Smith",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: -300,
        y: 1950,
        health: 100,
        weapon: SlotType.Empty,
        team: Teams.west,
    );
    npcs.add(npcSmith);

    guard1 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: SlotType.Bow_Wooden,
        team: Teams.west,
    );
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: SlotType.Bow_Wooden,
        team: Teams.west,
    );
    npcs.add(guard2);
  }

  @override
  bool onPlayerItemCollision(Player player, Item item){
    return true;
  }


  void _onGuardInteractedWith(Player player) {}

  void _onNpcInteractedWithMain(Player player) {
    player.health = 100;
  }

  void _onNpcInteractedWithSmith(Player player) {

  }

  @override
  void update() {
    const framesPerZombieSpawn = 5;
    const maxZombies = 1;
    if (engine.frame % framesPerZombieSpawn != 0) return;
    if (zombieCount >= maxZombies) return;
    spawnRandomZombie(
        health: 5,
        experience: 1,
        damage: 1,
    );
  }

  @override
  int getTime() {
    return 0;
  }
}
