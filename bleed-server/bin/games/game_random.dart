

import 'package:lemon_math/library.dart';

import '../classes/Character.dart';
import '../common/card_type.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/library.dart';
import '../scene_generator.dart';

/// Spawn somewhere on the map, select one of several characters
/// Warrior
/// Wizard
/// Gunslinger
/// Archer
///
/// There's no goal except to explore the map, kill other players and
/// Find treasure
class GameRandom extends Game {
  var time = 12 * 60 * 60;
  final int maxPlayers;

  GameRandom({required this.maxPlayers}) : super(
      generateRandomScene(
        columns: 100,
        rows: 100,
        seed: random.nextInt(2000),
      ),
     gameType: GameType.RANDOM,
      status: GameStatus.In_Progress
  );

  bool get full => players.length >= maxPlayers;
  bool get empty => players.length <= 0;

  @override
  void update() {
    // time = (time + 1) % Duration.secondsPerDay;
    if (frame % 180 == 0 && numberOfAliveZombies < 30){
      spawnRandomZombie();
    }
  }

  @override
  int getTime() {
    return time;
  }

  @override
  Player spawnPlayer() {
      final player = Player(
        game: this,
        weapon: SlotType.Empty,
        x: 500,
        y: 500,
      );
      player.techTree.bow = 2;
      player.techTree.pickaxe = 2;
      player.techTree.hammer = 2;
      player.techTree.axe = 4;
      final spawnLocation = randomItem(scene.spawnPointPlayers);
      player.x = spawnLocation.x;
      player.y = spawnLocation.y;
      return player;
  }

  @override
  void onPlayerJoined(Player player){
    revive(player);
  }

  @override
  void onPlayerLevelGained(Player player){
    player.generatedCardChoices();
  }

  @override
  void revive(Player player) {
    player.state = CharacterState.Idle;
    player.maxHealth = 10;
    player.health = 10;
    player.collidable = true;
    final spawnPoint = getNextSpawnPoint();
    player.x = spawnPoint.x;
    player.y = spawnPoint.y;
    player.skillPoints = 1;
    player.target = null;
    player.cardChoices.clear();
    player.cardChoices.addAll(cardTypesWeapons);
    player.writeCardChoices();
  }

  @override
  void onPlayerSelectCharacterType(Player player, CharacterSelection value) {
    player.setCharacterSelectionRequired(false);
    player.selection = value;
    player.level = 1;
    player.experience = 0;
    player.skillPoints = 1;
    player.maxHealth = 10;
    player.health = 10;

    switch (value) {
      case CharacterSelection.Warrior:
        player.techTree.sword = 2;
        player.equippedType = TechType.Sword;
        break;
      case CharacterSelection.Wizard:
        player.techTree.axe = 3;
        player.equippedType = TechType.Axe;
        break;
      case CharacterSelection.Archer:
        player.techTree.axe = 2;
        player.equippedType = TechType.Bow;
        break;
    }

    revive(player);
  }

  @override
  void onPlayerDeath(Player player) {
     player.setCharacterSelectionRequired(true);
  }

  @override
  void onKilled(dynamic target, dynamic src){
    if (src is Player) {
      src.gainExperience(45);
    }
  }

  @override
  void onPlayerChoseCard(Player player, CardType cardType){
     if (cardType == CardType.Weapon_Sword) {
       player.equippedType = TechType.Sword;
       player.setStateChanging();
     }
     if (cardType == CardType.Weapon_Bow) {
       player.equippedType = TechType.Bow;
       player.setStateChanging();
     }
     if (cardType == CardType.Weapon_Axe) {
       player.equippedType = TechType.Axe;
       player.setStateChanging();
     }
     player.skillPoints--;
     player.cardChoices.clear();

     if (player.skillPoints > 0){
       player.generatedCardChoices();
     } else {
       player.writeCardChoices();
     }
  }
}


