

import 'package:lemon_math/library.dart';

import '../classes/AI.dart';
import '../classes/Character.dart';
import '../classes/EnvironmentObject.dart';
import '../common/ObjectType.dart';
import '../common/card_type.dart';
import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/library.dart';
import '../scene_generator.dart';

class GameRandom extends Game {
  var time = 12 * 60 * 60;

  static const maxPlayers = 12;
  static const maxCreeps = 300;

  bool get full => players.length >= maxPlayers;
  bool get empty => players.length <= 0;

  GameRandom() : super(
      generateRandomScene(
        columns: 150,
        rows: 300,
        seed: random.nextInt(2000),
      ),
      status: GameStatus.In_Progress
  ) {
    for (var i = 0; i < maxCreeps; i++) {
      spawnCreep();
    }

    for (final playerSpawn in scene.spawnPointPlayers){
       objectsStatic.add(
           StaticObject(
               x: playerSpawn.x,
               y: playerSpawn.y,
               type: ObjectType.Fireplace
           )
       );
       scene.getNodeByPosition(playerSpawn).obstructed = true;
    }

    for (var i = 0; i < 20; i++) {
       // scene.spawn
    }
  }

  @override
  void update() {
    time = (time + 10) % Duration.secondsPerDay;
  }

  void spawnCreep(){
    spawnRandomZombie(health: 5, speed: randomBetween(RunSpeed.Slow, RunSpeed.Very_Fast));
  }

  @override
  int getTime() {
    return time;
  }

  Player playerJoin(CharacterSelection selection){
    final spawnLocation = randomItem(scene.spawnPointPlayers);
    final player = Player(
      game: this,
      weapon: SlotType.Empty,
      x: spawnLocation.x,
      y: spawnLocation.y,
    );
    onPlayerSelectCharacterType(player, selection);
    return player;
  }

  @override
  Player spawnPlayer() {
    final spawnLocation = randomItem(scene.spawnPointPlayers);
      final player = Player(
        game: this,
        weapon: TechType.Unarmed,
        x: spawnLocation.x,
        y: spawnLocation.y,
      );
      revive(player);
      return player;
  }

  @override
  void onPlayerJoined(Player player){
    revive(player);
  }

  @override
  void onPlayerLevelGained(Player player){
    player.generatedCardChoices();
    player.writePlayerEvent(PlayerEvent.Level_Up);
    player.maxHealth += 1;
    player.health = player.maxHealth;
  }

  @override
  void revive(Player player) {
    player.state = CharacterState.Idle;
    player.maxHealth = 10;
    player.level = 1;
    player.experience = 0;
    player.health = 10;
    player.collidable = true;
    player.skillPoints = 0;
    player.target = null;
    final spawnPoint = getNextSpawnPoint();
    player.x = spawnPoint.x;
    player.y = spawnPoint.y;
    player.cardChoices.clear();
    player.writeCardChoices();
    player.deck.clear();
    player.writeDeck();
  }

  @override
  void onPlayerSelectCharacterType(Player player, CharacterSelection value) {
    player.selection = value;
    switch (value) {
      case CharacterSelection.Warrior:
        player.equippedType = TechType.Sword;
        player.equippedArmour = SlotType.Armour_Padded;
        player.equippedHead = SlotType.Steel_Helmet;
        break;
      case CharacterSelection.Wizard:
        player.equippedType = TechType.Staff;
        player.equippedArmour = SlotType.Magic_Robes;
        player.equippedHead = SlotType.Magic_Hat;
        break;
      case CharacterSelection.Archer:
        player.equippedType = TechType.Bow;
        player.equippedArmour = SlotType.Body_Blue;
        player.equippedHead = SlotType.Rogue_Hood;
        break;
    }
  }

  @override
  void onPlayerDeath(Player player) {

  }

  @override
  void onKilled(dynamic target, dynamic src){
    if (src is Player) {
      src.gainExperience(75);
    }

    if (src is AI) {
       spawnCreep();
    }
  }

  @override
  void onPlayerChoseCard(Player player, CardType cardType){
     player.writePlayerEvent(PlayerEvent.Item_Purchased);
     if (cardType == CardType.Weapon_Sword) {
       player.equippedType = TechType.Sword;
     }
     if (cardType == CardType.Weapon_Bow) {
       player.equippedType = TechType.Bow;
     }
     if (cardType == CardType.Weapon_Staff) {
       player.equippedType = TechType.Staff;
     }
     if (cardTypesWeapons.contains(cardType)){
       player.setStateChanging();
     } else {
       player.deck.add(cardType);
       player.writeDeck();

       if (cardType == CardType.Passive_General_Max_HP_10) {
         player.maxHealth += 10;
         player.health += 10;
       }
       if (cardType == CardType.Passive_Bow_Run_Speed) {
         player.speedModifier += 0.5;
       }
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


