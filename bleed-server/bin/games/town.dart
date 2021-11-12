import 'package:lemon_math/diff_over.dart';

import '../classes/Game.dart';
import '../classes/Inventory.dart';
import '../classes/Player.dart';
import '../classes/InteractableNpc.dart';
import '../common/Quests.dart';
import '../common/Weapons.dart';
import '../common/classes/Vector2.dart';
import '../enums/npc_mode.dart';
import '../instances/scenes.dart';
import '../state.dart';
import '../utils/player_utils.dart';
import '../values/world.dart';
import 'world.dart';

class Town extends Game {

  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 30;
  final int _framesPerZombieSpawn = 120;

  final double playerSpawnX = 0;
  final double playerSpawnY = 1750;

  Town() : super(scenes.town, 64) {
    npcDavis = InteractableNpc(
        name: "Davis",
        onInteractedWith: _onNpcInteractedWithMain,
        x: -100,
        y: 1650,
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
        onInteractedWith: _onGuardInteractedWith,
        x: 180,
        y: 2000,
        health: 100,
        weapon: Weapon.SniperRifle
    );
    guard1.mode = NpcMode.Stand_Ground;
    npcs.add(guard1);

    guard2 = InteractableNpc(
        name: "Guard",
        onInteractedWith: _onGuardInteractedWith,
        x: 215,
        y: 1970,
        health: 100,
        weapon: Weapon.AssaultRifle
    );
    guard2.mode = NpcMode.Stand_Ground;
    npcs.add(guard2);
  }

  void _onGuardInteractedWith(Player player){

  }

  void _onNpcInteractedWithMain(Player player) {
    player.health = 100;

    if (player.rounds.shotgun < 25){
      player.rounds.shotgun = 25;
    }
    if (player.rounds.handgun < 40){
      player.rounds.handgun = 40;
    }

    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Davis: Welcome Traveller. "
            "You may rest easy, the walls of our town are well protected. "
            "If you need to earn some income I recommend talking to various folks. "
            "Equipment can be found at the armory, for a price of course. ";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "Davis: The smith is looking for a help with a matter";
        break;
      default:
        player.message = "Davis: I'm glad you are still with us traveller";
        break;
    }
  }

  void _onNpcInteractedWithSmith(Player player) {

    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Smith: Welcome to our town";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "Smith: Welcome outsider. Our supplies are running low. "
            "If you happen across some scrap metal while you are out, would you collect it for me"
            "I'll compensate you of course";
        player.questMain = MainQuest.Scavenge_Supplies;
        break;
      case MainQuest.Scavenge_Supplies:
        player.message = "Smith: Bring any metals and junk back you can find";
        break;
      default:
        player.message = "Smith: Good to see you well";
        break;
    }
  }

  @override
  Player doSpawnPlayer() {
    return Player(
      game: this,
      x: playerSpawnX,
      y: playerSpawnY,
      inventory: Inventory(0, 0, []),
      clips: Clips(),
      rounds: Rounds(handgun: 40, shotgun: 25),
      squad: 1,
      weapon: Weapon.HandGun,
    );
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
    double radius = 10;
    for(int i = 0; i < players.length; i++){
      Player player = players[i];
      if (diffOver(player.x, -1281, radius)) continue;
      if (diffOver(player.y, 2408, radius)) continue;
      changeGame(player, world.cave);
      i--;
    }

    if (frame % _framesPerZombieSpawn != 0) return;
    if (zombieCount > _maxZombies) return;
    spawnRandomZombie();
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return Vector2(-1260, 2389);
  }
}
