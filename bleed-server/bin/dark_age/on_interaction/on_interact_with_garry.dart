
import '../../classes/player.dart';
import '../../classes/weapon.dart';
import '../../common/PlayerEvent.dart';
import '../../common/flag.dart';
import '../../common/quest.dart';
import '../../common/weapon_type.dart';

void onInteractWithGarry(Player player) {
  player.writePlayerEvent(PlayerEvent.Hello_Male_01);

  if (player.questToDo(Quest.Garry_Kill_Farm_Zombies)){
     return player.interact(
         message: "Zombies keep on trampling all over my crops and destroying them. Would you be able to deal with them for me? I can lend you a weapon",
         responses: {
           "Staff": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Staff, damage: 1);
             player.endInteraction();
             player.flags.add(Flag.Acquire_Weapon_From_Garry);
           },
           "Sword": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Sword, damage: 1);
             player.endInteraction();
             player.flags.add(Flag.Acquire_Weapon_From_Garry);
           },
           "Bow": () {
             player.beginQuest(Quest.Garry_Kill_Farm_Zombies);
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Bow, damage: 1);
             player.endInteraction();
             player.flags.add(Flag.Acquire_Weapon_From_Garry);
           },
           "I can't right now": player.endInteraction,
        }
     );
  }

  if (player.questInProgress(Quest.Garry_Kill_Farm_Zombies)){
    return player.interact(message: "Try and kill at least 10 zombies in the farm");
  }

  return player.interact(message: "Thanks for clearing out those zombies for me");
}