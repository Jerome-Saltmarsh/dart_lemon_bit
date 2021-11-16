import '../classes/Character.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/InteractableNpc.dart';
import '../common/Quests.dart';
import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
import '../instances/scenes.dart';
import '../state.dart';
import '../values/world.dart';

class Town extends Game {
  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 30;
  final int _framesPerZombieSpawn = 120;

  Town() : super(scenes.town, 64) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: -100,
        y: 1650,
        health: 100,
        weapon: Weapon.Unarmed);
    npcDavis.mode = NpcMode.Ignore;
    npcs.add(npcDavis);

    npcSmith = InteractableNpc(
        name: "Smith",
        onInteractedWith: _onNpcInteractedWithSmith,
        x: -300,
        y: 1950,
        health: 100,
        weapon: Weapon.Unarmed);
    npcSmith.mode = NpcMode.Ignore;
    npcs.add(npcSmith);

    guard1 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: Weapon.SniperRifle);
    guard1.mode = NpcMode.Stand_Ground;
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: Weapon.AssaultRifle);
    guard2.mode = NpcMode.Stand_Ground;
    npcs.add(guard2);
  }

  void _onGuardInteractedWith(Player player) {}

  void _onNpcInteractedWithMain(Player player) {
    player.health = 100;

    if (player.rounds.shotgun < 25) {
      player.rounds.shotgun = 25;
    }
    if (player.rounds.handgun < 40) {
      player.rounds.handgun = 40;
    }

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
  void onPlayerKilled(Player player) {
    // player.x = playerSpawnX;
    // player.y = playerSpawnY;
    // player.health = 100;
    // player.state = CharacterState.Idle;
    // player.stateDuration = 0;
  }

  @override
  void update() {
    // double radius = 10;
    // for (int i = 0; i < players.length; i++) {
    //   Player player = players[i];
    //   if (diffOver(player.x, -1281, radius)) continue;
    //   if (diffOver(player.y, 2408, radius)) continue;
    //   changeGame(player, world.cave);
    //   i--;
    // }
    //
    // // -145 1900
    // for (int i = 0; i < players.length; i++) {
    //   Player player = players[i];
    //   if (diffOver(player.x, -145, 20)) continue;
    //   if (diffOver(player.y, 1900, 20)) continue;
    //   changeGame(player, world.tavern);
    //   i--;
    // }
    //
    // // -145 1900
    // for (int i = 0; i < players.length; i++) {
    //   Player player = players[i];
    //   if (diffOver(player.x, -1232, 20)) continue;
    //   if (diffOver(player.y, 1238, 20)) continue;
    //   changeGame(player, world.wildernessNorth01);
    //   i--;
    // }

    if (frame % _framesPerZombieSpawn != 0) return;
    if (zombieCount > _maxZombies) return;
    spawnRandomZombie();
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    if (from == world.tavern) {
      return Vector2(-120, 1917);
    }
    return Vector2(-1260, 2389);
  }

  @override
  void onKilledBy(Character target, Character by) {
    // TODO: implement onKilledBy
  }

  @override
  List<SpawnPoint> buildInternalSpawnPoints() {
    return [
      SpawnPoint(game: world.tavern, x: -145, y: 1900),
      SpawnPoint(game: world.cave, x: -1281, y: 2408),
    ];
  }
}
