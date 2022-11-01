

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';
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
  bool get customPropMapVisible => true;

  @override
  int get gameType => GameType.Dark_Age;

  void onHourChanged(int hour){

  }

  GameDarkAge(Scene scene, this.environment) : super(scene) {
    refreshSpawns();
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

  var timerReplenishAmmo = framesPerSecond * 5;

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
      armour: BodyType.shirtBlue,
      pants: LegType.green,
      weapon: buildWeaponBow(),
    );
  }

  @override
  void customUpdate() {
    // TODO: implement customUpdate
  }
}