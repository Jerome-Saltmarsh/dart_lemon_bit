

import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../dark_age_scenes.dart';
import '../on_interaction/on_interact_with_garry.dart';
import '../on_interaction/on_interact_with_jenkins.dart';
import '../on_interaction/on_interact_with_julia.dart';
import '../on_interaction/on_interact_with_tutorial.dart';
import 'dark_age_area.dart';

class GameDarkAgeVillage extends DarkAgeArea {
  GameDarkAgeVillage() : super(darkAgeScenes.village, mapTile: MapTiles.Village) {
    addNpc(
        weapon: buildWeaponUnarmed(),
        name: "Bell",
        row: 21,
        column: 13,
        z: 1,
        wanderRadius: 0,
        head: HeadType.Blonde,
        armour: ArmourType.shirtBlue,
        pants: PantsType.brown,
        onInteractedWith: (player) {
          player.health = player.maxHealth;
          player.setStoreItems([
            Weapon(type: AttackType.Bow, damage: 5, duration: 10, range: 200),
            Weapon(type: AttackType.Blade, damage: 5, duration: 15, range: 50),
          ]);
        });

    addNpc(
        name: "Garry",
        row: 20,
        column: 21,
        z: 2,
        wanderRadius: 50,
        head: HeadType.Steel_Helm,
        armour: ArmourType.shirtCyan,
        pants: PantsType.red,
        weapon: buildWeaponUnarmed(),
        onInteractedWith: onInteractWithGarry,
    );

    addNpc(
        name: "Jenkins",
        z: 1,
        row: 19,
        column: 17,
        head: HeadType.Wizards_Hat,
        armour: ArmourType.shirtBlue,
        pants: PantsType.white,
        weapon: buildWeaponUnarmed(),
        onInteractedWith: onInteractWithJenkins,
    );

    addNpc(
      name: "Julia",
      z: 4,
      row: 20,
      column: 16,
      head: HeadType.Blonde,
      armour: ArmourType.tunicPadded,
      pants: PantsType.brown,
      weapon: buildWeaponUnarmed(),
      onInteractedWith: onInteractWithJulia,
    );

    addNpcGuardBow(row: 10, column: 20);
    addNpcGuardBow(row: 20, column: 31);
    addNpcGuardBow(row: 30, column: 12);
    addNpcGuardBow(row: 18, column: 31);
  }

  @override
  void updateInternal() {
    // for (var i = 0; i < players.length; i++) {
    //   final player = players[i];
    //   final row = player.indexRow;
    //   final column = player.indexColumn;
    //
    //   if (row == 19 && column == 49) {
    //     player.changeGame(engine.findGameDarkAgeCastle());
    //     player.indexColumn = 1;
    //     continue;
    //   }
    //   if (row == 49 && (column == 7 || column == 8)) {
    //     player.changeGame(engine.findGameForest());
    //     player.indexRow = 1;
    //     continue;
    //   }
    //   if (row == 0 && (column == 9 || column == 8)) {
    //     player.changeGame(engine.findGameFarm());
    //     player.indexRow = 48;
    //     continue;
    //   }
    //   if (column == 0 && (row == 6 || row == 7)) {
    //     player.changeGame(engine.findGameDarkDarkFortress());
    //     player.indexColumn = 48;
    //     continue;
    //   }
    // }
  }

  @override
  void onPlayerJoined(Player player) {
     player.interact(
         message: "Welcome to Dark-Age!",
         responses: {
            "Tutorial": () => onInteractWithTutorial(player),
            "Play": player.endInteraction,
        }
     );
     player.deck.addAll([
       PowerFireball(),
       PowerLongShot(),
       PowerStunStrike(),
     ]);
     player.writeDeck();
  }
}
