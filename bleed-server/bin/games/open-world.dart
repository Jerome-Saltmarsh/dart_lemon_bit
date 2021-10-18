import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Inventory.dart';
import '../classes/Player.dart';
import '../common/GameType.dart';
import '../common/Quests.dart';
import '../common/Weapons.dart';
import '../enums.dart';
import '../instances/scenes.dart';
import '../state.dart';
import '../utils/player_utils.dart';

class OpenWorld extends Game {
  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 30;
  final int _framesPerZombieSpawn = 120;

  final double playerSpawnX = 0;
  final double playerSpawnY = 1750;

  OpenWorld() : super(GameType.Open_World, scenes.town, 64) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: 0,
        y: 1550,
        health: 100,
        weapon: Weapon.Unarmed
    );
    npcDavis.mode = NpcMode.Ignore;
    npcs.add(npcDavis);

    npcSmith = InteractableNpc(
        name: "Smith",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: -300,
        y: 1950,
        health: 100,
        weapon: Weapon.Unarmed
    );
    npcSmith.mode = NpcMode.Ignore;
    npcs.add(npcSmith);

    guard1 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: Weapon.SniperRifle
    );
    guard1.mode = NpcMode.Stand_Ground;
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: Weapon.AssaultRifle
    );
    guard2.mode = NpcMode.Stand_Ground;
    npcs.add(guard2);
  }

  void _onNpcInteractedWithMain(Player player) {
    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Welcome Traveller. "
            "You may rest easy, the walls of our town are well protected. "
            "If you need to earn some income I recommend talking to various folks. "
            "Equipment can be found at the armory, for a price of course. ";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "The smith is looking for a help with a matter";
        break;
      default:
        player.message = "I'm glad you are still with us traveller";
        break;
    }
  }

  void _onNpcInteractedWithSmith(Player player) {
    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Welcome to our town";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "Welcome outsider. Our supplies are running low. "
            "If you happen across some scrap metal while you are out, would you collect it for me"
            "I'll compensate you of course"
            "Here take this handgun, its last owner certainly no longer needs it... "
            "Just come back and talk to me again if you find yourself running low on ammunition";
        player.questMain = MainQuest.Scavenge_Supplies;
        player.rounds.handgun = 60;
        break;
      case MainQuest.Scavenge_Supplies:
        player.message = "Bring any metals and junk back you can find";
        break;
      default:
        player.message = "Good to see you well";
        break;
    }
  }

  @override
  Player doSpawnPlayer() {
    return Player(
      x: playerSpawnX,
      y: playerSpawnY,
      inventory: Inventory(0, 0, []),
      clips: Clips(assaultRifle: 100),
      rounds: Rounds(),
    );
  }

  @override
  bool gameOver() {
    return false;
  }

  @override
  void onPlayerKilled(Player player) {
    // player.x = playerSpawnX;
    // player.y = playerSpawnY;
    // player.health = 100;
    // player.state = CharacterState.Idle;
    // player.stateDuration = 0;
  }

  @override
  void update() {
    if (frame % _framesPerZombieSpawn != 0) return;
    if (zombieCount > _maxZombies) return;
    spawnRandomZombie();
  }
}
