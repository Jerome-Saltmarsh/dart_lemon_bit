

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/library.dart';
import '../common/spawn_type.dart';
import '../engine.dart';
import 'dark_age_environment.dart';

class GameDarkAge extends Game {
  final DarkAgeEnvironment environment;

  @override
  bool get full => false;

  GameDarkAge(Scene scene, this.environment) : super(scene) {
    refreshSpawns();
  }

  void setSpawnType(GameObjectSpawn spawn, int type){
    spawn.spawnType = SpawnType.getValue(spawn.spawnType + 1);
    onSpawnTypeChanged(spawn);
  }

  void onSpawnTypeChanged(GameObjectSpawn spawn){
       removeSpawnInstances(spawn);
       spawnGameObject(spawn);
  }

  @override
  void onCharacterSpawned(Character character){
    if (character is Player){
      dispatchV3(GameEventType.Player_Spawned, character);
    }
  }

  @override
  void setHourMinutes(int hour, int minutes){
    environment.time.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
    environment.updateShade();
    playersWriteWeather();
  }

  @override
  void onPlayerRevived(Player player){
      player.changeGame(engine.findGameDarkAge());
      player.indexZ = 5;
      player.indexRow = 16;
      player.indexColumn = 22;
      player.x += giveOrTake(5);
      player.y += giveOrTake(5);
  }

  @override
  int getTime() => environment.time.time;

  @override
  void update(){
    updateInternal();

    // for (var i = 0; i < players.length; i++) {
    //   final player = players[i];
    //   checkPlayerPosition(player, player.indexZ, player.indexRow, player.indexColumn);
    // }
  }

  // void checkPlayerPosition(Player player, int z, int row, int column){
  //
  // }

  void updateInternal(){

  }

  @override
  void onKilled(dynamic target, dynamic src){
       if (src is Player){
         if (target is AI){
            src.gainExperience(1);
         }
       }
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weapon: Weapon(type: WeaponType.Unarmed, damage: 1),
        team: 1,
    );

    player.indexZ = 1;
    player.indexRow = 16;
    player.indexColumn = 21;
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    player.weapons.add(Weapon(type: WeaponType.Sword, damage: 2));
    player.weapons.add(Weapon(type: WeaponType.Bow, damage: 2));
    player.weapons.add(Weapon(type: WeaponType.Handgun, damage: 5));
    player.weapons.add(Weapon(type: WeaponType.Shotgun, damage: 5));
    player.weapons.add(Weapon(type: WeaponType.Staff, damage: 5));
    player.writePlayerWeapons();
    return player;
  }


  void addNpcGuardBow({required int row, required int column, int z = 1}){
    addNpc(
      name: "Guard",
      row: row,
      column: column,
      z: 1,
      head: HeadType.Rogues_Hood,
      armour: ArmourType.shirtBlue,
      pants: PantsType.green,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
    );
  }
}