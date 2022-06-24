

import '../classes/library.dart';
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
    // moveCharacterToSpawn(bell);
    npcs.add(bell);
  }

  @override
  int getTime() => time;

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weapon: WeaponType.Shotgun,
    );
    moveCharacterToGridNode(player, GridNodeType.Player_Spawn);
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    revive(player);
  }
}