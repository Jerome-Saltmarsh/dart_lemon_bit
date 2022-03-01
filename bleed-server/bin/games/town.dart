
import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/ItemType.dart';
import '../common/Quests.dart';
import '../common/SlotType.dart';
import '../common/WeaponType.dart';
import '../engine.dart';
import '../handlers.dart';
import '../instances/scenes.dart';
import 'world.dart';

class Town extends Game {
  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 1;
  final int _framesPerZombieSpawn = 5;

  Town() : super(scenes.town) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: -100,
        y: 1650,
        health: 100,
        weapon: SlotType.Empty);
    npcs.add(npcDavis);

    events.onKilled.add(handlers.onKilledEarnOrb);

    npcSmith = InteractableNpc(
        name: "Smith",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: -300,
        y: 1950,
        health: 100,
        weapon: SlotType.Empty);
    npcs.add(npcSmith);

    guard1 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: SlotType.Bow_Wooden
    );
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: SlotType.Bow_Wooden
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

    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Welcome Traveller. "
            "You may rest easy, the walls of our town are well protected. "
            "If you need to earn some income I recommend talking to various folks. "
            "Smith was looking for help with an issue ";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "Smith was looking for help with something";
        break;
      default:
        player.message = "I'm glad you are still with us traveller";
        break;
    }
  }

  void _onNpcInteractedWithSmith(Player player) {
    if (player.questMain.index <= MainQuest.Talk_To_Smith.index) {
      player.message = "Hello there, I'm smith "
          "Just west outside of town there is a zombie boss, go kill it and return to me";
      player.questMain = MainQuest.Kill_Zombie_Boss;
      return;
    }

    switch (player.questMain) {
      case MainQuest.Kill_Zombie_Boss:
        player.message = "The zombie boss is in the wilderness west of town "
            "Come back to me once its dead";
        break;
      case MainQuest.Kill_Zombie_Boss_Talk_To_Smith:
        player.message = "You did it! Well done here is your reward";
        player.questMain = MainQuest.Finished;
        break;
      default:
        player.message = "Good to see you well";
        break;
    }
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
