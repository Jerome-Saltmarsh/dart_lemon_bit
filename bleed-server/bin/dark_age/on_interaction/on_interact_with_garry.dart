
import '../../classes/player.dart';
import '../../classes/weapon.dart';
import '../../common/PlayerEvent.dart';
import '../../common/quest.dart';
import '../../common/weapon_type.dart';

void onInteractWithGarry(Player player) {
  player.writePlayerEvent(PlayerEvent.Hello_Male_01);

  if (player.questToDo(Quest.Garry_Acquire_Weapon)){
    return player.interact(
        message: "Hello. It appears I acquired too much loot on my last quest. Would you mind holding onto one of these for me?",
        responses: {
           "Staff": () {
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Staff, damage: 1);
             player.endInteraction();
             player.beginQuest(Quest.Garry_Acquire_Weapon);
             player.completeQuest(Quest.Garry_Acquire_Weapon);
           },
           "Sword": () {
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Sword, damage: 1);
             player.endInteraction();
             player.beginQuest(Quest.Garry_Acquire_Weapon);
             player.completeQuest(Quest.Garry_Acquire_Weapon);
            },
          "Bow": () {
            player.setCharacterStateChanging();
            player.equippedWeapon = Weapon(type: WeaponType.Bow, damage: 1);
            player.endInteraction();
            player.beginQuest(Quest.Garry_Acquire_Weapon);
            player.completeQuest(Quest.Garry_Acquire_Weapon);
          }
        }
    );
  }

  player.interact(
      message: "Its so much fun going out into the wilderness to kill monsters and find treasure!",
      responses: {
        "It really is!": player.endInteraction,
        "I prefer board games": player.endInteraction,
      }
  );
}