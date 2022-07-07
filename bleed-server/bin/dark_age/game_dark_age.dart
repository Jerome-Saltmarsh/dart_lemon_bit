

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/library.dart';

class GameDarkAge extends Game {

  var minutesPassingPerSecond = 5;
  var time = 12 * 60 * 60;
  var durationRain = randomInt(1000, 3000);
  var durationLightning = 300;
  var durationBreeze = 500;
  var durationWind = randomInt(500, 1000);

  GameDarkAge(Scene scene) : super(scene);

  void setTime(int value){
      time = value % secondsPerDay;
  }

  @override
  void setHourMinutes(int hour, int minutes){
      time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
  }

  @override
  int getTime() => time;

  @override
  void update(){
    updateTimePassing();
    updateInternal();
  }

  void updateInternal(){

  }

  void updateTimePassing(){
    if (!timePassing) return;
    setTime(time + minutesPassingPerSecond);
    updateRain();
    updateLightning();
    updateBreeze();
    updateWind();
  }

  @override
  void onKilled(dynamic target, dynamic src){
       if (src is Player){
         if (target is AI){
            src.gainExperience(1);
         }
       }
  }


  void updateRain(){
    if (durationRain-- > 0) return;
    durationRain = randomInt(1000, 3000);
     switch (raining) {
       case Rain.None:
         raining = Rain.Light;
         break;
       case Rain.Light:
         raining = randomBool() ? Rain.None : Rain.Heavy;
         break;
       case Rain.Heavy:
         raining = Rain.Light;
         break;
     }
  }

  void updateLightning(){
    if (durationLightning-- > 0) return;
    durationLightning = randomInt(1000, 3000);
    switch (lightning) {
      case Lightning.Off:
        lightning = Lightning.Nearby;
        break;
      case Lightning.Nearby:
        lightning = randomBool() ? Lightning.Off : Lightning.On;
        break;
      case Lightning.On:
        lightning = Lightning.Nearby;
        break;
    }
  }

  void updateBreeze(){
    durationBreeze -= minutesPassingPerSecond;
    if (durationBreeze > 0) return;
    durationBreeze = randomInt(2000, 5000);
    breezy = !breezy;
  }

  void updateWind(){
    durationWind -= minutesPassingPerSecond;
    if (durationWind <= 0) {
      durationWind = randomInt(3000, 6000);

      if (wind == Wind.Calm) {
        wind++;
        return;
      }
      if (wind == Wind.Strong){
        wind--;
        return;
      }
      if (randomBool()){
        wind--;
      } else {
        wind++;
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
    player.indexColumn = 19;
    player.indexRow = 23;
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    // moveCharacterToGridNode(player, GridNodeType.Player_Spawn);
    player.weapons.add(Weapon(type: WeaponType.Sword, damage: 2));
    player.weapons.add(Weapon(type: WeaponType.Bow, damage: 2));
    player.writePlayerWeapons();
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    // revive(player);
  }

  void addNpcGuardBow({required double x, required double y, double z = 24}){
    addNpc(
      name: "Guard",
      x: x,
      y: y,
      z: z,
      head: HeadType.Rogues_Hood,
      armour: ArmourType.shirtBlue,
      pants: PantsType.green,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
    );
  }
}