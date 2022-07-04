
import '../classes/library.dart';
import '../common/library.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeVillage extends GameDarkAge {

  late Npc npcBell;
  late Npc npcGarry;

  GameDarkAgeVillage() : super(darkAgeScenes.village) {

    npcBell = Npc(
      name: "Bell",
      onInteractedWith: (player) {
        player.storeItems = [
          Weapon(type: WeaponType.Bow, damage: 5),
          Weapon(type: WeaponType.Sword, damage: 5),
        ];
        player.writeStoreItems();
      },
      x: 1150,
      y: 700,
      z: 24.0,
      weapon: 0,
      team: 1,
      health: 10,
    );

    npcBell.equippedHead = HeadType.Blonde;
    npcBell.equippedArmour = ArmourType.shirtBlue;
    npcBell.equippedPants = PantsType.green;
    npcs.add(npcBell);

    npcGarry = Npc(
      name: "Garry",
      onInteractedWith: (player) {

      },
      x: 800,
      y: 900,
      z: 24.0,
      weapon: 0,
      team: 1,
      health: 10,
    );

    npcGarry.equippedHead = HeadType.Steel_Helm;
    npcGarry.equippedArmour = ArmourType.shirtCyan;
    npcGarry.equippedPants = PantsType.red;
    npcs.add(npcGarry);
  }
}