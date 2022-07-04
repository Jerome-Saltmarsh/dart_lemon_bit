
import '../classes/library.dart';
import '../common/library.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeVillage extends GameDarkAge {
  GameDarkAgeVillage() : super(darkAgeScenes.village) {

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
}