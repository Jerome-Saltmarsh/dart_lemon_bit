

import '../../classes/library.dart';
import '../../classes/rat.dart';
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
            Weapon(type: WeaponType.Bow, damage: 5),
            Weapon(type: WeaponType.Sword, damage: 5),
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
        weaponType: WeaponType.Axe,
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
        weaponType: WeaponType.Staff,
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
      weaponType: WeaponType.Unarmed,
      onInteractedWith: onInteractWithJulia,
    );

    addNpcGuardBow(row: 10, column: 20);
    addNpcGuardBow(row: 20, column: 31);
    addNpcGuardBow(row: 30, column: 12);
    addNpcGuardBow(row: 18, column: 31);

    characters.add(Rat(z: 1, row: 30, column: 30, game: this)..wanderRadius = 100);
    characters.add(Rat(z: 1, row: 7, column: 47, game: this)..wanderRadius = 100);
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
     player.interactingWithNpc = true;
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
