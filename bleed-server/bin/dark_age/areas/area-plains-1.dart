
import 'package:lemon_math/functions/random_item.dart';

import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../../functions/move_player_to_crystal.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class DarkAgeTeam {
  static const Good = 1;
  static const Bad = 2;
}

class AreaPlains1 extends DarkAgeArea {

  AreaPlains1() : super(darkAgeScenes.plains_1, mapTile: MapTiles.Plains_1) {
    init();
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        team: DarkAgeTeam.Good,
        weapon: buildWeaponHandgun(),
        health: 20,
    );
    player.equippedArmour = randomItem(BodyType.values);
    player.equippedLegs = randomItem(LegType.values);
    player.equippedHead = randomItem(HeadType.values);
    movePlayerToCrystal(player);

    player.inventory[0] = ItemType.Weapon_Ranged_Handgun;
    // player.inventory.add(
    //     InventoryItem()
    //     ..itemType = ItemType.Body
    //     ..subType = BodyType.tunicPadded
    //     ..index = 10
    // );
    // player.inventory.add(
    //     InventoryItem()
    //       ..itemType = ItemType.Weapon
    //       ..subType = AttackType.Shotgun
    //       ..index = 5
    // );
    // player.inventory.add(
    //     InventoryItem()
    //       ..itemType = ItemType.Head
    //       ..subType = HeadType.Wizards_Hat
    //       ..index = 8
    // );
    player.writePlayerInventory();
    return player;
  }

  void init(){
    characters.add(
        Npc(
          game: this,
          x: 1000,
          y: 825,
          z: tileHeight,
          weapon: buildWeaponUnarmed(),
          team: DarkAgeTeam.Good,
          name: "Roth",
          health: 100,
          onInteractedWith: (Player player) {
             print("player interacted with Roth");
          }
        )
    );
  }
}