
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../../functions/move_player_to_crystal.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class DarkAgeTeam {
  static const Good = 1;
  static const Bad = 2;
  static const Bandits = 3;
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
        weaponType: ItemType.Weapon_Ranged_Handgun,
        health: 20,
    );
    player.bodyType = ItemType.Body_Tunic_Padded;
    player.legsType = ItemType.Legs_Blue;
    player.headType = ItemType.Head_Steel_Helm;
    movePlayerToCrystal(player);

    player.inventory[0] = ItemType.Weapon_Ranged_Handgun;
    player.inventory[1] = ItemType.Weapon_Ranged_Shotgun;
    player.inventory[2] = ItemType.Resource_Ammo_9mm;
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
          weaponType: ItemType.Empty,
          team: DarkAgeTeam.Good,
          name: "Roth",
          health: 100,
          onInteractedWith: (Player player) {
             print("player interacted with Roth");
          }
        )
          ..bodyType = ItemType.Body_Tunic_Padded
          ..legsType = ItemType.Legs_Blue
          ..headType = ItemType.Head_Steel_Helm

    );
  }
}