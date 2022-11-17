

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/library.dart';
import '../functions/move_player_to_crystal.dart';


class GameSkirmish extends Game {
  static const configAIRespawnFrames = 500;
  static const configRespawnFramesWeapons = 500;
  var configMaxPlayers = 7;
  var configZombieHealth = 5;
  var configZombieSpeed = 5.0;

  List<int> playerSpawnPoints = [];

  @override
  int get gameType => GameType.Skirmish;

  GameSkirmish({required Scene scene}) : super(scene);

  int getRandomItemType() => 0;

  @override
  void customUpdate() {
    for (final character in characters) {
      if (character.alive) {
        continue;
      }
      if (character is AI) {
          if
          (character.respawn-- <= 0)
            respawnAI(character);
      }
    }
  }

  @override
  void customOnPlayerWeaponReady(Player player){

  }

  void respawnAI(AI ai){
    ai.respawn = configAIRespawnFrames;
    ai.health = ai.maxHealth;
    ai.state = CharacterState.Spawning;
    ai.collidable = true;
    ai.stateDurationRemaining = 30;
    moveV3ToNodeIndex(ai, ai.spawnNodeIndex);
  }

  @override
  void customUpdatePlayer(Player player) {

  }

  @override
  Player spawnPlayer() {
    final player = Player(
      game: this,
      team: 0,
      weaponType: ItemType.Weapon_Ranged_Handgun,
    );
    player.legsType = ItemType.Legs_Brown;
    player.bodyType = ItemType.Body_Tunic_Padded;
    player.headType = ItemType.Head_Wizards_Hat;
    return player;
  }

  @override
  void customInitPlayer(Player player) {
    player.writeEnvironmentShade(Shade.Very_Very_Dark);
    player.writeEnvironmentRain(RainType.Light);
    player.writeEnvironmentLightning(LightningType.Off);
    player.writeEnvironmentWind(WindType.Gentle);
    player.writeEnvironmentBreeze(false);
    // player.writePlayerMessage("press W,A,S,D to run and LEFT CLICK to punch");
    if
    (playerSpawnPoints.isNotEmpty) {
      moveV3ToNodeIndex(player, randomItem(playerSpawnPoints));
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {

  }

  @override
  void customOnPlayerRevived(Player player){
    movePlayerToCrystal(player);
  }

  @override
  void customOnPlayerWeaponChanged(Player player, int newWeapon, int previousWeapon){
    // reactiveWeaponGameObject(previousWeapon);
  }

  @override
  void customOnPlayerDisconnected(Player player) {

  }

  void reactivatePlayerWeapons(Player player){
  }

  reactivateGameObject(GameObject gameObject){
    gameObject.active = true;
    gameObject.collidable = true;
    gameObject.type = getRandomItemType();
  }

  void customOnCharacterKilled(Character target, dynamic src) {

  }
}