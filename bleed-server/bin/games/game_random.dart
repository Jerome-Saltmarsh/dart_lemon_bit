

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';
import '../scene_generator.dart';

class GameRandom extends Game {
  var time = 12 * 60 * 60;

  static const maxPlayers = 12;
  static const creepsPerPlayer = 25;

  int get maxCreeps => players.length * creepsPerPlayer;
  bool get zombiesMax => numberOfAliveZombies >= maxCreeps;
  bool get full => players.length >= maxPlayers;
  bool get empty => players.length <= 0;

  GameRandom() : super(
      generateRandomScene(
        columns: 150,
        rows: 150,
        seed: random.nextInt(2000),
      ),
      status: GameStatus.In_Progress
  ) {

    // generateRandomSeparatedGameObjects(scene, amount: 40, type: GameObjectType.Torch);

    for (var i = 0; i < maxCreeps; i++) {
      spawnCreep();
    }

  }

  @override
  void update() {
    const secondsPerDay = 86400;
    time = (time + 10) % secondsPerDay;
  }

  void spawnCreep(){
    spawnRandomZombie(health: 5, speed: randomBetween(RunSpeed.Slow, RunSpeed.Very_Fast));
  }

  @override
  int getTime() {
    return time;
  }

  Player playerJoin(CharacterSelection selection){
    final player = Player(
      game: this,
      weapon: SlotType.Empty,
      // position: getRandomPlayerSpawnPosition(),
    );
    onPlayerSelectCharacterType(player, selection);

    while (!zombiesMax) {
      spawnCreep();
    }
    return player;
  }

  @override
  Player spawnPlayer() {
      final player = Player(
        game: this,
        weapon: TechType.Unarmed,
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
    final spawnPoint = getRandomPlayerSpawnPosition();
    player.x = spawnPoint.row * tileSize;
    player.y = spawnPoint.column * tileSize;
    player.clearCardAbility();
    player.cardChoices.clear();
    player.writeCardChoices();
    player.deck.clear();
    player.writePlayerSpawned();

    if (player.selection == CharacterSelection.Archer) {
      player.addCardToDeck(CardType.Ability_Bow_Volley);
      player.addCardToDeck(CardType.Ability_Bow_Long_Shot);
    } else
    if (player.selection == CharacterSelection.Wizard) {
      player.addCardToDeck(CardType.Ability_Explosion);
      player.addCardToDeck(CardType.Ability_Fireball);
    }

    player.writeDeck();
  }

  @override
  void onPlayerSelectCharacterType(Player player, CharacterSelection value) {
    player.selection = value;
    switch (value) {
      case CharacterSelection.Warrior:
        player.equippedWeapon = WeaponType.Sword;
        player.equippedArmour = SlotType.Armour_Padded;
        player.equippedHead = SlotType.Steel_Helmet;
        break;
      case CharacterSelection.Wizard:
        player.equippedWeapon = WeaponType.Staff;
        player.equippedArmour = SlotType.Magic_Robes;
        player.equippedHead = SlotType.Magic_Hat;
        break;
      case CharacterSelection.Archer:
        player.equippedWeapon = WeaponType.Bow;
        player.equippedArmour = SlotType.Body_Blue;
        player.equippedHead = SlotType.Rogue_Hood;
        player.writeDeck();
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

    if (src is AI && !zombiesMax) {
       spawnCreep();
    }
  }

  @override
  void onPlayerAddCardToDeck(Player player, CardType cardType){
     player.writePlayerEvent(PlayerEvent.Item_Purchased);
     player.addCardToDeck(cardType);
     player.skillPoints--;
     player.cardChoices.clear();

     if (player.skillPoints > 0){
       player.generatedCardChoices();
     } else {
       player.writeCardChoices();
     }
  }
}




