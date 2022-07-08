
import '../classes/library.dart';
import '../common/library.dart';
import '../engine.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

class GameDarkAgeVillage extends GameDarkAge {

  GameDarkAgeVillage() : super(darkAgeScenes.village) {
    addNpc(
        name: "Bell",
        x: 1150,
        y: 700,
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
        }
    );

    addNpc(
        name: "Garry",
        x: 800,
        y: 900,
        z: 24.0,
        wanderRadius: 50,
        head: HeadType.Steel_Helm,
        armour: ArmourType.shirtCyan,
        pants: PantsType.red,
        onInteractedWith: (player) {
          player.writePlayerEvent(PlayerEvent.Hello_Male_01);
          player.setStoreItems([
            Weapon(type: WeaponType.Handgun, damage: 5),
            Weapon(type: WeaponType.Shotgun, damage: 5),
          ]);
        }
    );

    addNpcGuardBow(x: 1460, y: 630);
    addNpcGuardBow(x: 520, y: 1000);
    addNpcGuardBow(x: 985, y: 1500);

    addEnemySpawn(z: 1, row: 40, column: 5, health: 3);
    addEnemySpawn(z: 1, row: 40, column: 35, health: 3);
  }

  @override
  void updateInternal(){
     for (var i = 0; i < players.length; i++) {
        final player = players[i];
        if (player.indexRow != 19) continue;
        if (player.indexColumn != 49) continue;
        player.changeGame(engine.findGameDarkAgeCastle());
        player.x = 1420;
        player.y = 90;
     }
  }
}