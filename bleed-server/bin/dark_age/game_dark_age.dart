

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/library.dart';
import '../common/spawn_type.dart';
import '../constants/frames_per_second.dart';
import '../engine.dart';
import 'dark_age_environment.dart';

class GameDarkAge extends Game {
  final DarkAgeEnvironment environment;

  @override
  bool get full => false;

  bool get mapVisible => true;

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
      player.changeGame(engine.findGameDarkAgeFarm());
      player.indexZ = 5;
      player.indexRow = 16;
      player.indexColumn = 22;
      player.x += giveOrTake(5);
      player.y += giveOrTake(5);
  }

  @override
  int getTime() => environment.time.time;

  var timerReplenishAmmo = framesPerSecond * 5;

  @override
  void update(){
    updateInternal();
    replenishAmmo();
  }

  void replenishAmmo(){
    if (timerReplenishAmmo-- > 0) return;
    timerReplenishAmmo = framesPerSecond * 5;
    for (final player in players) {
      for (final weapon in player.weapons){
         if (weapon.rounds >= weapon.capacity) continue;
         weapon.rounds++;
      }
      player.writePlayerEventWeaponRounds();
    }
  }

  void updateInternal(){

  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weapon: buildWeaponUnarmed(),
        team: 1,
    );

    player.indexZ = 1;
    player.indexRow = 16;
    player.indexColumn = 21;
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    player.weapons.add(buildWeaponBow());
    player.weapons.add(buildWeaponSword());
    player.weapons.add(buildWeaponHandgun());
    player.weapons.add(buildWeaponShotgun());
    player.weapons.add(buildWeaponRevolver());
    player.weapons.add(buildWeaponUnarmed());
    player.weapons.add(buildWeaponRifle());
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
      weapon: buildWeaponBow(),
    );
  }
}