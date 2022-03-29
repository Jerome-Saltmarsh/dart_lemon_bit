
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../common/ItemType.dart';
import '../common/Quests.dart';
import '../common/SlotType.dart';
import '../engine.dart';
import '../handlers.dart';
import 'world.dart';

class Town extends Game {
  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 1;
  final int _framesPerZombieSpawn = 5;

  Town() : super(engine.scenes.town) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: -100,
        y: 1650,
        health: 100,
        weapon: SlotType.Empty,
        team: teams.west,
    );
    npcs.add(npcDavis);

    events.onKilled.add(handlers.onKilledEarnOrb);

    npcSmith = InteractableNpc(
        name: "Smith",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: -300,
        y: 1950,
        health: 100,
        weapon: SlotType.Empty,
        team: teams.west,
    );
    npcs.add(npcSmith);

    guard1 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: SlotType.Bow_Wooden,
        team: teams.west,
    );
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: SlotType.Bow_Wooden,
        team: teams.west,
    );
    npcs.add(guard2);
  }

  @override
  bool onPlayerItemCollision(Player player, Item item){
    if (item.type == ItemType.Orb_Emerald){
      player.orbs.emerald++;
    }
    if (item.type == ItemType.Orb_Topaz){
      player.orbs.topaz++;
    }
    if (item.type == ItemType.Orb_Ruby){
      player.orbs.ruby++;
    }
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
    if (engine.frame % _framesPerZombieSpawn != 0) return;
    if (zombieCount >= _maxZombies) return;
    spawnRandomZombie(
        health: 5,
        experience: 1,
        damage: 1,
    );
  }

  @override
  int getTime() {
    return worldTime;
  }
}
