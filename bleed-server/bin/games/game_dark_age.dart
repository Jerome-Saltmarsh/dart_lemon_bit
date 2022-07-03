

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../classes/weapon.dart';
import '../common/Rain.dart';
import '../common/armour_type.dart';
import '../common/grid_node_type.dart';
import '../common/head_type.dart';
import '../common/library.dart';
import '../common/pants_type.dart';
import '../common/wind.dart';
import '../functions/generateUUID.dart';

class GameDarkAge extends Game {

  var fileName = generateUUID();

  var minutesPassingPerSecond = 5;
  var time = 12 * 60 * 60;

  var durationRain = randomInt(1000, 3000);

  var nextLightning = randomInt(400, 10000);
  var durationLightning = 300;

  var nextBreeze = randomInt(500, 1000);
  var durationBreeze = 500;

  var nextWindChange = randomInt(500, 1000);


  void setTime(int value){
      time = value % secondsPerDay;
  }

  @override
  void setHourMinutes(int hour, int minutes){
      time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
  }

  GameDarkAge(Scene scene) : super(
    scene
  ) {

    final bell = Npc(
      name: "Bell",
      onInteractedWith: (player) {
          player.storeItems = [
             Weapon(type: WeaponType.Bow, damage: 5),
             Weapon(type: WeaponType.Sword, damage: 5),
          ];
          player.writeStoreItems();
      },
      x: 300,
      y: 300,
      weapon: 0,
      team: 1,
      health: 10,
    );

    bell.equippedHead = HeadType.Blonde;
    bell.equippedArmour = ArmourType.shirtBlue;
    bell.equippedPants = PantsType.green;
    scene.findByType(GridNodeType.Player_Spawn, (int z, int row, int column){
       bell.indexZ = z;
       bell.indexRow = row;
       bell.indexColumn = column + 1;
    });
    npcs.add(bell);
  }

  @override
  int getTime() => time;

  @override
  void update(){
    updateTimePassing();
  }

  void updateTimePassing(){
    if (!timePassing) return;
    setTime(time + minutesPassingPerSecond);
    updateRain();
    updateLightning();
    updateBreeze();
    updateWind();
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
    if (lightning) {
      durationLightning -= minutesPassingPerSecond;
      if (durationLightning <= 0){
        lightning = false;
        nextLightning = randomInt(10000, 20000);
      }
      return;
    }
    nextLightning -= minutesPassingPerSecond;
    if (nextLightning  <= 0){
      lightning = true;
      durationLightning = randomInt(3000, 6000);
    }
  }

  void updateBreeze(){
    if (breezy) {
      durationBreeze -= minutesPassingPerSecond;
      if (durationBreeze <= 0){
        breezy = false;
        nextBreeze = randomInt(2000, 10000);
      }
      return;
    }
    nextBreeze -= minutesPassingPerSecond;
    if (nextBreeze  <= 0){
      breezy = true;
      durationBreeze = randomInt(3000, 10000);
    }
  }

  void updateWind(){
    nextWindChange -= minutesPassingPerSecond;
    if (nextWindChange <= 0) {
      nextWindChange = randomInt(3000, 6000);

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
    player.indexColumn = 2;
    player.indexRow = 2;

    moveCharacterToGridNode(player, GridNodeType.Player_Spawn);

    player.weapons.add(Weapon(type: WeaponType.Sword, damage: 2));
    player.weapons.add(Weapon(type: WeaponType.Bow, damage: 2));
    player.writePlayerWeapons();
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    revive(player);
  }
}