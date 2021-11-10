import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Inventory.dart';
import '../classes/Player.dart';
import '../common/Quests.dart';
import '../common/Weapons.dart';
import '../compile.dart';
import '../instances/scenes.dart';
import '../state.dart';
import '../utils/player_utils.dart';


class World {
  late Game town;
  late Game cave;
  late List<Game> games;

  World(){
    town = Town(this);
    cave = Cave(this);
    games = [town, cave];
    // TODO Remove Logic
    for(Game game in games){
      compileGame(game);
      game.compiledTiles = compileTiles(game.scene.tiles);
      game.compiledEnvironmentObjects = compileEnvironmentObjects(game.scene.environment);
    }
  }
}

class Cave extends Game {

  Cave(World world) : super(world, scenes.cave, 64);

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    // TODO: implement update
  }
}

class Town extends Game {

  late InteractableNpc npcDavis;
  late InteractableNpc npcSmith;
  late InteractableNpc guard1;
  late InteractableNpc guard2;

  final int _maxZombies = 30;
  final int _framesPerZombieSpawn = 120;

  final double playerSpawnX = 0;
  final double playerSpawnY = 1750;

  Town(World world) : super(world, scenes.town, 64) {
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
    // change scene
    players.remove(player);
    world.cave.players.add(player);
    player.game = world.cave;
    player.sceneChanged = true;

    // switch (player.questMain) {
    //   case MainQuest.Introduction:
    //     player.message = "Smith: Welcome to our town";
    //     player.questMain = MainQuest.Talk_To_Smith;
    //     break;
    //   case MainQuest.Talk_To_Smith:
    //     player.message = "Smith: Welcome outsider. Our supplies are running low. "
    //         "If you happen across some scrap metal while you are out, would you collect it for me"
    //         "I'll compensate you of course"
    //         "Here take this handgun, its last owner certainly no longer needs it... "
    //         "Just come back and talk to me again if you find yourself running low on ammunition";
    //     player.questMain = MainQuest.Scavenge_Supplies;
    //     player.rounds.handgun = 60;
    //     player.rounds.shotgun = 20;
    //     break;
    //   case MainQuest.Scavenge_Supplies:
    //     player.message = "Smith: Bring any metals and junk back you can find";
    //     break;
    //   default:
    //     player.message = "Smith: Good to see you well";
    //     break;
    // }
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
