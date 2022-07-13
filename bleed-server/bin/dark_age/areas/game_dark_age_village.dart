
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';
import '../dark_age_scenes.dart';
import '../on_interaction/on_interact_with_garry.dart';
import '../on_interaction/on_interact_with_jenkins.dart';
import '../on_interaction/on_interact_with_julia.dart';
import '../on_interaction/on_interact_with_tutorial.dart';

class GameDarkAgeVillage extends GameDarkAge {
  GameDarkAgeVillage() : super(darkAgeScenes.village, engine.officialUniverse) {
    addNpc(
        name: "Bell",
        x: 840,
        y: 645,
        z: 24.0,
        wanderRadius: 10,
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
        x: 1250,
        y: 1020,
        z: 24.0,
        wanderRadius: 50,
        head: HeadType.Steel_Helm,
        armour: ArmourType.shirtCyan,
        pants: PantsType.red,
        weaponType: WeaponType.Axe,
        onInteractedWith: onInteractWithGarry,
    );

    addNpc(
        name: "Jenkins",
        x: 980,
        y: 835,
        z: 24.0,
        head: HeadType.Wizards_Hat,
        armour: ArmourType.shirtBlue,
        pants: PantsType.white,
        weaponType: WeaponType.Staff,
        onInteractedWith: onInteractWithJenkins,
    );

    addNpc(
      name: "Julia",
      x: 760,
      y: 870,
      z: 120.0,
      head: HeadType.Blonde,
      armour: ArmourType.tunicPadded,
      pants: PantsType.brown,
      weaponType: WeaponType.Unarmed,
      onInteractedWith: onInteractWithJulia,
    );

    addNpcGuardBow(x: 1460, y: 630);
    addNpcGuardBow(x: 520, y: 1000);
    addNpcGuardBow(x: 985, y: 1500);

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
