
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../engine.dart';
import '../dark_age_scenes.dart';
import '../on_interaction/on_interact_with_garry.dart';
import '../on_interaction/on_interact_with_jenkins.dart';
import '../on_interaction/on_interact_with_julia.dart';
import '../on_interaction/on_interact_with_tutorial.dart';
import 'dark_age_area.dart';

class GameDarkAgeVillage extends DarkAgeArea {
  GameDarkAgeVillage() : super(darkAgeScenes.village) {
    addNpc(
        name: "Bell",
        row: 17,
        column: 13,
        z: 1,
        wanderRadius: 0,
        head: HeadType.Blonde,
        armour: ArmourType.shirtBlue,
        pants: PantsType.brown,
        onInteractedWith: (player) {
          player.health = player.maxHealth;
          player.setStoreItems([
            Weapon(type: WeaponType.Bow, damage: 5),
            Weapon(type: WeaponType.Sword, damage: 5),
          ]);
        });

    addNpc(
        name: "Garry",
        row: 25,
        column: 20,
        z: 1,
        wanderRadius: 50,
        head: HeadType.Steel_Helm,
        armour: ArmourType.shirtCyan,
        pants: PantsType.red,
        weaponType: WeaponType.Axe,
        onInteractedWith: onInteractWithGarry,
    );

    addNpc(
        name: "Jenkins",
        row: 20,
        column: 17,
        z: 1,
        head: HeadType.Wizards_Hat,
        armour: ArmourType.shirtBlue,
        pants: PantsType.white,
        weaponType: WeaponType.Staff,
        onInteractedWith: onInteractWithJenkins,
    );

    addNpc(
      name: "Julia",
      row: 16,
      column: 17,
      z: 5,
      head: HeadType.Blonde,
      armour: ArmourType.tunicPadded,
      pants: PantsType.brown,
      weaponType: WeaponType.Unarmed,
      onInteractedWith: onInteractWithJulia,
    );

    addNpcGuardBow(row: 10, column: 20);
    addNpcGuardBow(row: 20, column: 31);
    addNpcGuardBow(row: 30, column: 12);

    addEnemySpawn(z: 1, row: 40, column: 5, health: 3);
    addEnemySpawn(z: 1, row: 40, column: 35, health: 3);
  }

  @override
  void updateInternal() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      final row = player.indexRow;
      final column = player.indexColumn;

      if (row == 19 && column == 49) {
        player.changeGame(engine.findGameDarkAgeCastle());
        player.indexColumn = 2;
        continue;
      }
      if (row == 49 && (column == 7 || column == 8)) {
        player.changeGame(engine.findGameForest());
        player.indexRow = 2;
        continue;
      }
    }
  }

  @override
  void onPlayerJoined(Player player) {
     player.interactingWithNpc = true;
     player.interact(
         message: "Welcome to Dark-Age!",
         responses: {
            "Tutorial": () => onInteractWithTutorial(player),
            "Play": player.endInteraction,
        }
     );
  }
}
