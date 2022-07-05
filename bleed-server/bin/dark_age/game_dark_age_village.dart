
import '../classes/library.dart';
import '../common/library.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeVillage extends GameDarkAge {


  GameDarkAgeVillage() : super(darkAgeScenes.village) {

    addNpc(
        name: "Bell",
        x: 1150,
        y: 700,
        z: 24.0,
        head: HeadType.Blonde,
        armour: ArmourType.shirtBlue,
        pants: PantsType.brown,
        onInteractedWith: (player) {
          player.health = player.maxHealth;
          player.setStoreItems([
            Weapon(type: WeaponType.Bow, damage: 5),
            Weapon(type: WeaponType.Sword, damage: 5),
          ]);
        }
    );

    addNpc(
        name: "Garry",
        x: 800,
        y: 900,
        z: 24.0,
        head: HeadType.Steel_Helm,
        armour: ArmourType.shirtCyan,
        pants: PantsType.red,
        onInteractedWith: (player) {
          player.setStoreItems([
            Weapon(type: WeaponType.Handgun, damage: 5),
            Weapon(type: WeaponType.Shotgun, damage: 5),
          ]);
        }
    );

    addNpc(
        name: "Guard",
        x: 1460,
        y: 630,
        z: 24.0,
        head: HeadType.Rogues_Hood,
        armour: ArmourType.shirtBlue,
        pants: PantsType.green,
        weaponType: WeaponType.Bow,
        weaponDamage: 3,
        onInteractedWith: (player) {

        }
    );

    addEnemySpawn(z: 1, row: 40, column: 5);
    addEnemySpawn(z: 1, row: 40, column: 35);
  }
}