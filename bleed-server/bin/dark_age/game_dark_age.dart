

import 'package:lemon_math/library.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/library.dart';
import '../common/spawn_type.dart';
import '../constants/frames_per_second.dart';
import '../engine.dart';
import 'dark_age_environment.dart';

/// Your melee attack depletes energy.
/// The less energy the player has the less damage is dealt
/// The energy bar is not visible to the user
///
/// The player has 3 different weapon categories
///
/// Primary, secondary and tertiary
///
/// The primary attack is dealt by clicking the left mouse button
///
/// The secondary attack is dealt using the right mouse button
///
/// Space bar is used pressed to trigger the tertiary attack
///
/// Players also get a choice of one Armor
///
/// The primary weapon is a dominant weapon and the heaviest.
///
/// Such as a sniper rifle, a machine gun gun, a staff
///
/// The secondary is a lighter weapon such as a handgun
///
/// Should a grenade be a secondary or tertiary attack?
///
/// A blade is a tertiary attack.
///
/// The player also gets a choice of two spells
///
/// Spells can be triggered using Q and E.
///
/// What is a shield?
///
/// Shield is used to defend the player against damage
///
/// The shield can be upgraded to stun enemies that are effectively blocked
///
/// Flash - means to quickly move to a near location
///
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
  void customOnCharacterSpawned(Character character){
    if (character is Player){
      dispatchV3(GameEventType.Player_Spawned, character);
    }
  }

  @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) {
    if (a is Player && b is GameObjectLoot) {
      return onCollisionBetweenPlayerAndGameObjectLoot(a, b);
    }
    if (a is GameObjectLoot && b is Player) {
      return onCollisionBetweenPlayerAndGameObjectLoot(b, a);
    }
  }

  void onCollisionBetweenPlayerAndGameObjectLoot(Player player, GameObjectLoot loot){
    deactivateGameObject(loot);
    player.health++;
    player.experience++;
    player.weaponSlot1.rounds++;
    player.weaponSlot2.rounds++;
    player.weaponSlot3.rounds++;
    player.writePlayerEventWeaponRounds();
    player.dispatchEventLootCollected();
  }

  @override
  void setHourMinutes(int hour, int minutes){
    environment.time.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
    environment.updateShade();
    playersWriteWeather();
  }

  @override
  void customOnPlayerRevived(Player player){
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
  void customUpdate(){
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
    player.weapons.add(buildWeaponBlade());
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