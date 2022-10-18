

import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../../common/quest.dart';
import '../dark_age_scenes.dart';
import '../on_interaction/on_interact_with_jenkins.dart';
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
        armour: BodyType.shirtBlue,
        pants: LegType.brown,
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
        armour: BodyType.shirtCyan,
        pants: LegType.red,
        weapon: buildWeaponUnarmed(),
        onInteractedWith: onInteractWithGarry,
    );

    addNpc(
        name: "Jenkins",
        z: 1,
        row: 19,
        column: 17,
        head: HeadType.Wizards_Hat,
        armour: BodyType.shirtBlue,
        pants: LegType.white,
        weapon: buildWeaponUnarmed(),
        onInteractedWith: onInteractWithJenkins,
    );

    addNpc(
      name: "Julia",
      z: 4,
      row: 20,
      column: 16,
      head: HeadType.Blonde,
      armour: BodyType.tunicPadded,
      pants: LegType.brown,
      weapon: buildWeaponUnarmed(),
      onInteractedWith: onInteractWithJulia,
    );

    addNpcGuardBow(row: 10, column: 20);
    addNpcGuardBow(row: 20, column: 31);
    addNpcGuardBow(row: 30, column: 12);
    addNpcGuardBow(row: 18, column: 31);
  }

  void onInteractWithJulia(Player player) {
    player.interact(
        message: "Hello dear, are you looking for new clothing?",
        responses: {
          "Pants": (){
            player.interact(message: "Which color are you looking for?",
                responses: {
                  "brown": (){
                    setCharacterStateChanging(player);
                    player.equippedLegs = LegType.brown;
                    player.endInteraction();
                  },
                  "blue": (){
                    setCharacterStateChanging(player);
                    player.equippedLegs = LegType.blue;
                    player.endInteraction();
                  },
                  "red": (){
                    setCharacterStateChanging(player);
                    player.equippedLegs = LegType.red;
                    player.endInteraction();
                  },
                  "green": (){
                    setCharacterStateChanging(player);
                    player.equippedLegs = LegType.green;
                    player.endInteraction();
                  },
                  "white": (){
                    setCharacterStateChanging(player);
                    player.equippedLegs = LegType.white;
                    player.endInteraction();
                  },

                  "I changed my mind": player.endInteraction
                }
            );
          },
          "Shirt": (){

          },
        }
    );
  }


  void onInteractWithGarry(Player player){
    player.writePlayerEvent(PlayerEvent.Hello_Male_01);

    if (player.questToDo(Quest.Garry_Kill_Farm_Zombies)){
      return player.interact(
          message: "Zombies keep on trampling all over my crops and destroying them. Would you be able to deal with them for me? I can lend you a weapon.",
          responses: {
            "Staff": () {
              player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
              setCharacterStateChanging(player);
              player.weapon = buildWeaponStaff();
              player.endInteraction();
            },
            "Sword": () {
              player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
              setCharacterStateChanging(player);
              player.weapon = buildWeaponBlade();
              player.endInteraction();
            },
            "Bow": () {
              player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
              setCharacterStateChanging(player);
              player.weapon = buildWeaponBow();
              player.endInteraction();
            },
            "I can't right now": player.endInteraction,
          }
      );
    }

    if (player.questInProgress(Quest.Garry_Return_To_Garry)){
      player.completeQuest(Quest.Garry_Return_To_Garry);
      return player.interact(message: "Thank you for killing all those zombies, here is your reward");

    }

    return player.interact(message: "Thanks for clearing out those zombies for me");

  }

  void onInteractWithJenkins(Player player) {

    if (player.questToDo(Quest.Jenkins_Retrieve_Stolen_Scroll))
      return toDoJenkinsRetrieveStolenScroll(player);

    if (player.questInProgress(Quest.Jenkins_Retrieve_Stolen_Scroll))
      return inProgressJenkinsRetrieveStolenScroll(player);

    if (player.questInProgress(Quest.Jenkins_Return_Stole_Scroll_To_Jenkins)) {
      player.completeQuest(Quest.Jenkins_Return_Stole_Scroll_To_Jenkins);
      player.beginQuest(Quest.Jenkins_Deliver_Scroll_To_College);
      return player.interact(
        message: "Fantastic you have recovered the scroll! I have another favour to ask of you. That scroll needs to be delivered to the College is Westhorn, considering you capabilities would you be so kind as to deliver it for me?",
      );
    }


    if (player.questInProgress(Quest.Jenkins_Deliver_Scroll_To_College))
      return inProgressJenkinsDeliverScroll(player);

    return interactionJenkinsAllQuestsCompleted(player);
  }

}
