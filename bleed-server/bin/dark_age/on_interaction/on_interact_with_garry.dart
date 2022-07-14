
import '../../classes/player.dart';
import '../../classes/weapon.dart';
import '../../common/PlayerEvent.dart';
import '../../common/flag.dart';
import '../../common/weapon_type.dart';

void onInteractWithGarry(Player player) {
  player.writePlayerEvent(PlayerEvent.Hello_Male_01);

  if (!player.flagged(Flag.Acquire_Weapon_From_Garry)){
    return player.interact(
        message: "Hello. It appears I acquired too much loot on my last quest. Would you mind holding onto one of these for me?",
        responses: {
           "Staff": () {
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Staff, damage: 1);
             player.endInteraction();
             player.flags.add(Flag.Acquire_Weapon_From_Garry);
           },
           "Sword": () {
             player.setCharacterStateChanging();
             player.equippedWeapon = Weapon(type: WeaponType.Sword, damage: 1);
             player.endInteraction();
             player.flags.add(Flag.Acquire_Weapon_From_Garry);
            },
          "Bow": () {
            player.setCharacterStateChanging();
            player.equippedWeapon = Weapon(type: WeaponType.Bow, damage: 1);
            player.endInteraction();
            player.flags.add(Flag.Acquire_Weapon_From_Garry);
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