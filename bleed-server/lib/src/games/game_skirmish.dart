

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/functions/random_item.dart';

class EquippedType {
  static const Primary = 0;
  static const Secondary = 1;
  static const Tertiary = 2;
}

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
    player.items[ItemType.Weapon_Rifle_AK_47] = 1;
    player.items[ItemType.Weapon_Rifle_Jager] = 1;
    player.items[ItemType.Weapon_Handgun_Glock] = 1;
    player.items[ItemType.Weapon_Handgun_Revolver] = 1;
    player.items[ItemType.Weapon_Handgun_Desert_Eagle] = 1;
    player.items[ItemType.Weapon_Melee_Crowbar] = 1;
    player.items[ItemType.Weapon_Melee_Axe] = 1;
    player.items[ItemType.Weapon_Melee_Knife] = 1;

    player.weaponPrimary = ItemType.Weapon_Rifle_M4;
    player.weaponSecondary = ItemType.Weapon_Handgun_Glock;
    player.weaponTertiary = ItemType.Weapon_Melee_Crowbar;
  }

  @override
  void onPlayerUpdateRequestedReceived({
    required Player player,
    required int direction,
    required int cursorAction,
    required bool perform2,
    required bool perform3,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
    required bool runToMouse,
  }) {
    player.framesSinceClientRequest = 0;
    player.screenLeft = screenLeft;
    player.screenTop = screenTop;
    player.screenRight = screenRight;
    player.screenBottom = screenBottom;
    player.mouse.x = mouseX;
    player.mouse.y = mouseY;

    if (player.deadOrBusy) return;

    playerUpdateAimTarget(player);

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    switch (cursorAction) {
      case CursorAction.Set_Target:
        if (direction != Direction.None) {
          if (!player.weaponStateBusy){
            characterUseWeapon(player);
          }
        } else {
          final aimTarget = player.aimTarget;
          if (aimTarget == null){
            player.runToMouse();
          } else {
            setCharacterTarget(player, aimTarget);
          }
        }
        break;
      case CursorAction.Stationary_Attack_Cursor:
        if (!player.weaponStateBusy) {
          characterUseWeapon(player);
          // characterWeaponAim(player);
        }
        break;
      case CursorAction.Stationary_Attack_Auto:
        if (!player.weaponStateBusy){
          playerAutoAim(player);
          characterUseWeapon(player);
        }
        break;
      case CursorAction.Mouse_Left_Click:
        final aimTarget = player.aimTarget;
        if (aimTarget != null){
          if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
            setCharacterTarget(player, aimTarget);
            break;
          }
          if (Collider.onSameTeam(player, aimTarget)){
            setCharacterTarget(player, aimTarget);
            break;
          }
        }
        characterUseOrEquipWeapon(
          character: player,
          weaponType: player.weaponPrimary,
          characterStateChange: true,
        );
        break;
      case CursorAction.Mouse_Right_Click:
        characterUseOrEquipWeapon(
          character: player,
          weaponType: player.weaponSecondary,
          characterStateChange: true,
        );
        break;
      case CursorAction.Key_Space:
        characterUseOrEquipWeapon(
            character: player,
            weaponType: player.weaponTertiary,
            characterStateChange: false,
        );
        break;
    }

    playerRunInDirection(player, direction);
  }
}