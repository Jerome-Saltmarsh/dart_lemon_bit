import '../classes/library.dart';
import '../common/library.dart';
import '../common/quest.dart';
import '../engine.dart';
import 'game_dark_age.dart';
import 'dark_age_scenes.dart';

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
        onInteractedWith: (player) {
          player.writePlayerEvent(PlayerEvent.Hello_Male_01);
          player.setStoreItems([
            Weapon(type: WeaponType.Handgun, damage: 5),
            Weapon(type: WeaponType.Shotgun, damage: 5),
          ]);
        });

    addNpc(
        name: "Jenkins",
        x: 980,
        y: 835,
        z: 24.0,
        head: HeadType.None,
        armour: ArmourType.shirtBlue,
        pants: PantsType.brown,
        weaponType: WeaponType.Unarmed,
        onInteractedWith: (Player player) {
          if (!player.questsCompleted.contains(Quest.Jenkins_Meet)) {
            player.writeNpcTalk(
              text: "Greetings Traveller, I don't recall having seen your face prior.",
              options: {
                'Who are you?': () {
                  player.writeNpcTalk(
                    text: "The name's Jenkins. I'm a patron of this here Inn. I owe money to a local bandit. I'm afraid he's going to kill me if I don't pay him back soon",
                    options: {
                       "Good Luck With That": player.stopInteractingWithNpc,
                       "How can I help?": (){

                       },
                    },
                  );
                },
              },
            );
          } else {
            player.writeNpcTalk(
              text: "Hello again",
              options: {
                'Who are you?': () {},
              },
            );
          }
        });

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
      if (player.indexRow != 19) continue;
      if (player.indexColumn != 49) continue;
      player.changeGame(engine.findGameDarkAgeCastle());
      player.x = 1420;
      player.y = 90;
    }
  }
}
