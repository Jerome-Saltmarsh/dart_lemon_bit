

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';
import '../engine.dart';
import 'dark_age_environment.dart';

class GameDarkAge extends Game {
  final DarkAgeEnvironment environment;

  @override
  bool get customPropMapVisible => true;

  @override
  int get gameType => GameType.Dark_Age;


  GameDarkAge(Scene scene, this.environment) : super(scene) {
    refreshSpawns();
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (target is AI){
        spawnRandomLootAtPosition(target);
     }
  }

  void spawnRandomLootAtPosition(Position3 position){
       spawnGameObjectItem(
           x: position.x,
           y: position.y,
           z: position.z,
           type: ItemType.Resource_Ammo_9mm,
       );
  }

  @override
  void customDownloadScene(Player player) {
    player.writeWeather();
  }

  @override
  void customOnCharacterSpawned(Character character){
    if (character is Player){
      dispatchV3(GameEventType.Player_Spawned, character);
    }
  }

  @override
  void customPlayerWrite(Player player) {
     player.writeGameTime(environment.time.time);
  }

  @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) {

  }

  @override
  void setHourMinutes(int hour, int minutes){
    environment.time.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
    environment.updateShade();
    playersWriteWeather();
  }

  @override
  void customOnPlayerRevived(Player player){
      changeGame(player, engine.findGameDarkAge());
      player.indexZ = 5;
      player.indexRow = 16;
      player.indexColumn = 22;
      player.x += giveOrTake(5);
      player.y += giveOrTake(5);
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weaponType: ItemType.Weapon_Ranged_Handgun,
        team: 1,
    );

    player.indexZ = 1;
    player.indexRow = 16;
    player.indexColumn = 21;
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    return player;
  }

  void addNpcGuardBow({required int row, required int column, int z = 1}){
    addNpc(
      name: "Guard",
      row: row,
      column: column,
      z: 1,
      headType: ItemType.Head_Wizards_Hat,
      armour: ItemType.Body_Tunic_Padded,
      pants: ItemType.Legs_Brown,
      weaponType: ItemType.Weapon_Ranged_Bow,
      team: 1
    );
  }

  @override
  void customUpdate() {
    // TODO: implement customUpdate
  }
}