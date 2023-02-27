

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/functions/random_item.dart';

class EquippedType {
  static const Primary = 0;
  static const Secondary = 1;
  static const Tertiary = 2;
}

class GameCombat extends Game {
  static const hints = [
     'Press the W,A,S,D keys to move',
     'Left click to use your weapon',
     'Press 1 to equip your heavy weapon',
     'Press 2 to equip your light weapon',
     'Press 3 to equip your hand to hand weapon',
     'Repeat to cycle through heavy weapons',
  ];

  static final hints_length = hints.length;

  GameCombat({
    required super.scene,
  }) : super(
      gameType: GameType.Combat,
      time: GameTime(enabled: true, hour: 15, minute: 30),
      environment: GameEnvironment(),
      options: GameOptions(
          perks: false,
          inventory: false,
          items: true,
          itemTypes: [
              ItemType.Weapon_Melee_Knife,
              ItemType.Weapon_Melee_Crowbar,
              ItemType.Weapon_Melee_Axe,
              ItemType.Weapon_Ranged_Plasma_Pistol,
              // ItemType.Weapon_Ranged_Handgun,
              // ItemType.Weapon_Ranged_Revolver,
              // ItemType.Weapon_Ranged_Bow,
              // ItemType.Weapon_Ranged_Rifle,
              // ItemType.Weapon_Ranged_Smg,
              ItemType.Weapon_Ranged_Plasma_Rifle,
              ItemType.Weapon_Ranged_Shotgun,
              ItemType.Weapon_Ranged_Sniper_Rifle,
              ItemType.Weapon_Ranged_Bazooka,
              ItemType.Weapon_Ranged_Flamethrower,
          ],
      ),
  );

  @override
  void customOnPlayerRevived(Player player) {
    moveToRandomPlayerSpawnPoint(player);
    player.items.clear();
    player.headType = randomItem(ItemType.Collection_Clothing_Head);
    player.bodyType = randomItem(ItemType.Collection_Clothing_Body);
    player.legsType = randomItem(ItemType.Collection_Clothing_Legs);
    player.items[ItemType.Weapon_Ranged_Rifle] = 1;
    player.items[ItemType.Weapon_Ranged_Handgun] = 1;
    player.items[ItemType.Weapon_Melee_Knife] = 1;
    characterEquipItemType(player, ItemType.Weapon_Ranged_Rifle);
    player.weaponPrimary = ItemType.Weapon_Ranged_Plasma_Rifle;
    player.weaponSecondary = ItemType.Weapon_Ranged_Plasma_Pistol;
    player.weaponMelee = ItemType.Weapon_Melee_Knife;
    player.credits = 100;
    player.writeEquipped();
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
        // characterUseWeapon(player);
        characterUseOrEquipWeapon(
          character: player,
          weaponType: player.weaponRanged,
          characterStateChange: true,
        );
        break;
      case CursorAction.Mouse_Right_Click:
        // characterAimWeapon(player);
        // characterUseWeapon(player);
        characterUseOrEquipWeapon(
          character: player,
          weaponType: player.weaponMelee,
          characterStateChange: false,
        );
        break;
      case CursorAction.Key_Space:
        characterUseOrEquipWeapon(
            character: player,
            weaponType: player.weaponMelee,
            characterStateChange: false,
        );
        break;
    }

    playerRunInDirection(player, direction);
  }

  @override
  void customUpdatePlayer(Player player){
     if (player.hintIndex >= hints_length) return;
     player.hintNext--;
     if (player.hintNext > 0) return;
     player.writeInfo('Tip: ${hints[player.hintIndex]}');
     player.hintNext = 300;
     player.hintIndex++;
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (src is Player) {
       src.credits += 10;
     }
  }
}