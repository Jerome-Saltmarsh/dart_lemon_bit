

import '../classes/library.dart';
import '../classes/weapon.dart';
import '../common/armour_type.dart';
import '../common/grid_node_type.dart';
import '../common/head_type.dart';
import '../common/pants_type.dart';
import '../common/weapon_type.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  GameFrontline(Scene scene) : super(
    scene
  ) {

    final bell = InteractableNpc(
      name: "Bell",
      onInteractedWith: (player) {

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