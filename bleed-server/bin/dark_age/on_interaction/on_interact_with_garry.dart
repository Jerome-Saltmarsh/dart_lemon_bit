
import '../../classes/player.dart';
import '../../classes/weapon.dart';
import '../../common/PlayerEvent.dart';
import '../../common/quest.dart';

void onInteractWithGarry(Player player) {
  player.writePlayerEvent(PlayerEvent.Hello_Male_01);

  if (player.questToDo(Quest.Garry_Kill_Farm_Zombies)){
     return player.interact(
         message: "Zombies keep on trampling all over my crops and destroying them. Would you be able to deal with them for me? I can lend you a weapon.",
         responses: {
           "Staff": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
             player.weapon = buildWeaponStaff();
             player.endInteraction();
           },
           "Sword": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
             player.weapon = buildWeaponSword();
             player.endInteraction();
           },
           "Bow": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
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