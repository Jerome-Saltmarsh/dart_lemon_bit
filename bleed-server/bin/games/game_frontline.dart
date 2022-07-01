

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../classes/weapon.dart';
import '../common/armour_type.dart';
import '../common/grid_node_type.dart';
import '../common/head_type.dart';
import '../common/library.dart';
import '../common/pants_type.dart';
import '../common/wind.dart';

class GameFrontline extends Game {

  var minutesPassingPerSecond = 5;
  var time = 12 * 60 * 60;

  var nextRain = randomInt(400, 10000);
  var durationRain = 300;

  var nextLightning = randomInt(400, 10000);
  var durationLightning = 300;

  var nextBreeze = randomInt(500, 1000);
  var durationBreeze = 500;

  var nextWindChange = randomInt(500, 1000);


  void setTime(int value){
      time = value % secondsPerDay;
  }

  GameFrontline(Scene scene) : super(
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
    if (raining) {
      durationRain -= minutesPassingPerSecond;
      if (durationRain <= 0){
        raining = false;
        nextRain = randomInt(2000, 20000);
      }
      return;
    }
    nextRain -= minutesPassingPerSecond;
    if (nextRain  <= 0){
      raining = true;
      durationRain = randomInt(2000, 8000);
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
    moveCharacterToGridNode(player, GridNodeType.Player_Spawn);

    player.storeItems = [
        Weapon(type: WeaponType.Shotgun, damage: 1),
        Weapon(type: WeaponType.Sword, damage: 1),
        Weapon(type: WeaponType.Axe, damage: 1),
    ];
    player.writeStoreItems();

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