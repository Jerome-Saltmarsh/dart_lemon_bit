

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../classes/weapon.dart';
import '../common/armour_type.dart';
import '../common/grid_node_type.dart';
import '../common/head_type.dart';
import '../common/library.dart';
import '../common/pants_type.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  var nextRain = 300;
  var rainDuration = 300;

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
    if (timePassing) {
        setTime(time + 1);

        if (raining){
           if (rainDuration-- <= 0){
              raining = false;
              nextRain = randomInt(500, 1000);
           }
        } else if (nextRain-- <= 0){
           raining = true;
           rainDuration = 500;
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