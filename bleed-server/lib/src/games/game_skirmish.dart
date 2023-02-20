

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/functions/random_item.dart';

class GameSkirmish extends Game {
  GameSkirmish({
    required super.scene,
  }) : super(
      gameType: GameType.Skirmish,
      time: GameTime(enabled: false, hour: 15, minute: 30),
      environment: GameEnvironment(),
      options: GameOptions(
          perks: false,
          inventory: false,
          items: true,
          itemDamage: const {
            ItemType.Weapon_Rifle_M4: 30,
            ItemType.Weapon_Ranged_Shotgun: 5,
            }),
  );

  @override
  void customOnPlayerRevived(Player player) {
    moveToRandomPlayerSpawnPoint(player);

    player.headType = randomItem(const [
      ItemType.Head_Swat,
      ItemType.Head_Steel_Helm,
      ItemType.Head_Rogues_Hood,
      ItemType.Head_Wizards_Hat,
    ]);

    player.belt1_itemType = ItemType.Weapon_Ranged_Shotgun;
    player.belt1_quantity = ItemType.getMaxQuantity(player.belt1_itemType);

    player.belt2_itemType = ItemType.Weapon_Rifle_M4;
    player.belt2_quantity = ItemType.getMaxQuantity(player.belt2_itemType);

    player.equippedWeaponIndex = ItemType.Belt_1;

    player.items.clear();

    for (final itemType in const [
      ItemType.Head_Rogues_Hood,
      ItemType.Weapon_Smg_Mp5,
      ItemType.Head_Wizards_Hat,
    ]){
      player.items[itemType] = 0;
    }

    player.items[ItemType.Head_Wizards_Hat] = 1;
    player.items[ItemType.Body_Shirt_Blue] = 1;
    player.items[ItemType.Legs_Green] = 1;
    player.items[ItemType.Weapon_Rifle_M4] = 1;
    player.items[ItemType.Weapon_Handgun_Glock] = 1;
  }
}