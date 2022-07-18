

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';
import 'dark_age_universe.dart';

class GameDarkAge extends Game {
  final DarkAgeUniverse universe;
  var minutesPassingPerSecond = 5;
  var durationRain = randomInt(1000, 3000);
  var durationLightning = 300;
  var durationBreeze = 500;
  var durationWind = randomInt(500, 1000);

  GameDarkAge(Scene scene, this.universe) : super(scene);

  @override
  void setHourMinutes(int hour, int minutes){
    universe.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
  }

  @override
  int getTime() => universe.time;

  @override
  void update(){
    updateInternal();
  }

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
    player.writePlayerWeapons();
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    // revive(player);
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