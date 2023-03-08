

import 'dart:math';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:bleed_server/src/constants/frames_per_second.dart';
import 'package:lemon_math/library.dart';

// wood (axe), stone (pickaxe), hammer (gold)

class TutorialType {
   static const Movement              = 0;
   static const Left_Click_Fire       = 1;
   static const Right_Click_Fire      = 2;
   static const Space_Throw_Grenade   = 3;
}

class GameCombat extends Game {
  static const hints = [
     'Use the W,A,S,D keys to move',
     'Left click to fire first weapon',
     'Right click to fire second weapon',
     'Press Space bar to melee attack',
     'Right Click item to equip',
  ];

  static final hints_length = hints.length;
  static final hints_frames_between = 600;
  static const Max_Grenades = 3;
  static const GameObject_Duration = 400;
  static const Crate_Respawn_Duration = 1000;
  static const Chance_Of_Item_Drop = 0.25;
  static const Credits_Collected = 5;

  static const weaponTypes = [
    ItemType.Weapon_Ranged_Flamethrower,
    ItemType.Weapon_Ranged_Bazooka,
    ItemType.Weapon_Ranged_Plasma_Pistol,
    ItemType.Weapon_Ranged_Plasma_Rifle,
    ItemType.Weapon_Ranged_Sniper_Rifle,
    ItemType.Weapon_Ranged_Shotgun,
    ItemType.Weapon_Ranged_Bow,
    ItemType.Weapon_Melee_Crowbar,
    ItemType.Weapon_Melee_Pickaxe,
  ];

  static const itemTypes = [
    // ItemType.Buff_Double_Damage,
    // ItemType.Buff_Infinite_Ammo,
    // ItemType.Buff_Fast,
    // ItemType.Buff_Invincible,
    ItemType.Consumables_Potion_Red,
    ItemType.Consumables_Ammo_Box,
    ItemType.Weapon_Thrown_Grenade,
    ItemType.Resource_Credit,
  ];

  var nextBuffUpdate = 0;

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
    player.item_level.clear();
    player.headType = randomItem(ItemType.Collection_Clothing_Head);
    player.bodyType = randomItem(ItemType.Collection_Clothing_Body);
    player.legsType = randomItem(ItemType.Collection_Clothing_Legs);

    final weaponPrimary = ItemType.Weapon_Ranged_Plasma_Rifle;
    final weaponSecondary = ItemType.Weapon_Ranged_Plasma_Pistol;
    final weaponTertiary = randomItem(const[
      ItemType.Weapon_Melee_Knife,
      ItemType.Weapon_Melee_Crowbar,
      ItemType.Weapon_Melee_Axe,
      ItemType.Weapon_Melee_Pickaxe,
      ItemType.Weapon_Melee_Hammer,
      ItemType.Weapon_Melee_Sword,
    ]);

    player.item_level[weaponPrimary] = 0;
    player.item_level[weaponSecondary] = 0;
    player.item_level[weaponTertiary] = 0;
    characterEquipItemType(player, weaponPrimary);
    player.weaponPrimary = weaponPrimary;
    player.weaponSecondary = weaponSecondary;
    player.weaponTertiary = weaponTertiary;
    player.weaponType = weaponPrimary;
    player.grenades = 3;
    player.credits = 0;
    player.item_quantity[weaponPrimary] = player.weaponPrimaryCapacity;
    player.item_quantity[weaponSecondary] = player.weaponSecondaryCapacity;
    player.writePlayerEquipment();
  }

  @override
  void onPlayerUpdateRequestReceived({
    required Player player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keyShiftDown,
    required bool keySpaceDown,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
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

    if (mouseLeftDown){
      final aimTarget = player.aimTarget;
      if (aimTarget != null) {

        player.aimTargetWeaponSide = Side.Left;
        if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          } else {
            setCharacterTarget(player, aimTarget);
          }
          return;
        }
        if (Collider.onSameTeam(player, aimTarget)){
          setCharacterTarget(player, aimTarget);
          return;
        }
      }
      characterUseOrEquipWeapon(
        character: player,
        weaponType: player.weaponPrimary,
        characterStateChange: player.weaponType != player.weaponTertiary,
      );
    }

    if (mouseRightDown) {
      player.aimTargetWeaponSide = Side.Right;
      final aimTarget = player.aimTarget;
      if (aimTarget != null){
        player.aimTargetWeaponSide = Side.Right;

        if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          } else {
            setCharacterTarget(player, aimTarget);
          }
        }
        if (Collider.onSameTeam(player, aimTarget)) {
          setCharacterTarget(player, aimTarget);
        }
      }
      characterUseOrEquipWeapon(
        character: player,
        weaponType: player.weaponSecondary,
        characterStateChange: player.weaponType != player.weaponTertiary,
      );
    }

    if (keySpaceDown) {
      playerThrowGrenade(player);
    }

    playerRunInDirection(player, direction);
  }

  @override
  void customUpdatePlayer(Player player){
      updateHint(player);
      updatePlayerAction(player);
  }

  @override
  void customUpdate() {
    updatePlayerBuffs();
  }

  void updatePlayerBuffs(){
    nextBuffUpdate--;
    if (nextBuffUpdate > 0) return;
    nextBuffUpdate = framesPerSecond;

    for (final player in players) {
       if (player.dead) continue;
       player.reduceBuffs();
    }
  }

  void spawnRandomItemAtPosition(Position3 position){
    final spawnedGameObject = spawnGameObjectAtPosition(
      position: position,
      type: randomItem(itemTypes),
    );

    spawnedGameObject
      ..physical = false
      ..interactable = ItemType.isTypeWeapon(spawnedGameObject.type)
      ..fixed = true
      ..strikable = false
      ..gravity = false
      ..collectable = true
    ;

    performScript(timer: GameObject_Duration)
        .writeGameObjectDeactivate(spawnedGameObject);
  }

  void updatePlayerAction(Player player){
    var minDistance = 50.0;
    GameObject? closestGameObject;

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!ItemType.isTypeWeapon(gameObject.type)) continue;
      final xDiff = (player.x - gameObject.x).abs();
      if (xDiff > minDistance) continue;
      final yDiff = (player.y - gameObject.y).abs();
      if (yDiff > minDistance) continue;
      minDistance = max(xDiff, yDiff);
      closestGameObject = gameObject;
    }

    if (closestGameObject == null) {
      player.action = PlayerAction.None;
      player.actionItemId = -1;
      return;
    }

    final itemType        = closestGameObject.type;
    final itemLevel       = player.getItemLevel(itemType);

    player.actionItemType = itemType;
    player.actionItemId   = closestGameObject.id;
    player.actionCost     = getItemPurchaseCost(itemType, itemLevel);

    if (player.weaponPrimary == itemType) {
      if (player.weaponPrimaryQuantity < player.weaponPrimaryCapacity){
         player.weaponPrimaryQuantity = player.weaponPrimaryCapacity;
         player.writeInfo('Ammo Acquired');
         player.writePlayerEventItemAcquired(itemType);
         deactivateCollider(closestGameObject);

         performScript(timer: 300).writeSpawnGameObject(
             type: randomItem(const [
               ItemType.Weapon_Ranged_Flamethrower,
               ItemType.Weapon_Ranged_Bazooka,
               ItemType.Weapon_Ranged_Plasma_Pistol,
               ItemType.Weapon_Ranged_Plasma_Rifle,
               ItemType.Weapon_Ranged_Sniper_Rifle,
               ItemType.Weapon_Ranged_Shotgun,
             ]),
             x: closestGameObject.x,
             y: closestGameObject.y,
             z: closestGameObject.z,
         );
      }
      return;
    }

    if (player.weaponSecondary == itemType) {
      if (player.weaponSecondaryQuantity < player.weaponSecondaryCapacity){
        player.weaponSecondaryQuantity = player.weaponSecondaryCapacity;
        player.writeInfo('Ammo Acquired');
        player.writePlayerEventItemAcquired(itemType);
        deactivateCollider(closestGameObject);

        performScript(timer: 300).writeSpawnGameObject(
          type: randomItem(const [
            ItemType.Weapon_Ranged_Flamethrower,
            ItemType.Weapon_Ranged_Bazooka,
            ItemType.Weapon_Ranged_Plasma_Pistol,
            ItemType.Weapon_Ranged_Plasma_Rifle,
            ItemType.Weapon_Ranged_Sniper_Rifle,
            ItemType.Weapon_Ranged_Shotgun,
          ]),
          x: closestGameObject.x,
          y: closestGameObject.y,
          z: closestGameObject.z,
        );
      }
      return;
    }

    player.action = PlayerAction.Equip;
  }


  void updateHint(Player player){
    if (player.hintIndex >= hints_length) return;
    player.hintNext--;
    if (player.hintNext > 0) return;
    player.writeInfo(hints[player.hintIndex]);
    player.hintNext = hints_frames_between;
    player.hintIndex++;
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (src is Player) {
       src.credits += 10;
     }

     if (target is AI) {
       performScript(timer: 300).writeSpawnAI(
         type: randomItem(const[CharacterType.Zombie, CharacterType.Dog]),
         x: target.x,
         y: target.y,
         z: target.z,
         team: TeamType.Evil,
       );

       if (random.nextDouble() < Chance_Of_Item_Drop) {
         spawnRandomItemAtPosition(target);
       }
     }
  }

  @override
  void performPlayerActionPrimary(Player player) {
    if (player.dead) return;
    if (player.action == PlayerAction.None) return;
    if (player.actionItemId == -1) return;

    final playerActionGameObject = findGameObjectById(player.actionItemId);
    if (playerActionGameObject == null) {
      player.actionItemId = -1;
      return;
    }
    playerEquipPrimary(player, playerActionGameObject.type);
    player.setItemQuantityMax(playerActionGameObject.type);
    deactivateGameObjectAndScheduleRespawn(playerActionGameObject);
  }

  void deactivateGameObjectAndScheduleRespawn(GameObject gameObject){
    if (!gameObject.active) return;
    deactivateCollider(gameObject);
    performScript(timer: 300).writeSpawnGameObject(
      type: randomItem(const [
        ItemType.Weapon_Ranged_Flamethrower,
        ItemType.Weapon_Ranged_Bazooka,
        ItemType.Weapon_Ranged_Plasma_Pistol,
        ItemType.Weapon_Ranged_Plasma_Rifle,
        ItemType.Weapon_Ranged_Sniper_Rifle,
        ItemType.Weapon_Ranged_Shotgun,
      ]),
      x: gameObject.x,
      y: gameObject.y,
      z: gameObject.z,
    );
  }

  @override
  void performPlayerActionSecondary(Player player) {
    if (player.dead) return;
    if (player.action == PlayerAction.None) return;
    if (player.actionItemId == -1) return;

    final playerActionGameObject = findGameObjectById(player.actionItemId);
    if (playerActionGameObject == null) {
      player.actionItemId = -1;
      return;
    }
    playerEquipSecondary(player, playerActionGameObject.type);
    player.setItemQuantityMax(playerActionGameObject.type);
    deactivateGameObjectAndScheduleRespawn(playerActionGameObject);
  }

  @override
  void playerPurchaseItemType(Player player, int itemType, {required Side weaponSide}){
     if (player.dead) return;

     final itemLevel = player.getItemLevel(itemType);

     if (itemLevel < 4) {
       final itemCost = getItemPurchaseCost(itemType, itemLevel);

       if (player.credits < itemCost){
         player.writeError('insufficient credits');
         return;
       }

       player.credits -= itemCost;
       player.item_level[itemType] = itemLevel + 1;
       player.item_quantity[itemType] = player.getItemCapacity(itemType);
       if (itemLevel == 0){
         player.writeInfo('${ItemType.getName(itemType)} Purchased');
       } else {
         player.writeInfo('${ItemType.getName(itemType)} Upgraded');
       }
       player.writePlayerEventItemPurchased(itemType);
     }

     switch (weaponSide) {
       case Side.Left:
         playerEquipPrimary(player, itemType);
         break;
       case Side.Right:
         playerEquipSecondary(player, itemType);
         break;
     }

     player.writePlayerEquipment();
     player.writePlayerWeapons();
  }

  void playerEquipPrimary(Player player, int itemType) {
    if (
      player.weaponPrimary == itemType &&
      player.weaponType == itemType
    ) return;

    if (player.canChangeEquipment) {
      setCharacterStateChanging(player);
    }

    if (player.weaponSecondary == itemType) {
      final previousWeaponPrimary = player.weaponPrimary;
      player.weaponPrimary = itemType;
      player.weaponSecondary = previousWeaponPrimary;
      return;
    }

    player.weaponPrimary = itemType;
    player.weaponType = itemType;
    player.weaponPrimaryQuantity = player.weaponPrimaryCapacity;
    player.writePlayerEquipment();
  }

  void playerEquipSecondary(Player player, int itemType) {
    if (
        player.weaponSecondary == itemType &&
        player.weaponType == itemType
    ) return;

    if (player.canChangeEquipment) {
      setCharacterStateChanging(player);
    }

    if (player.weaponPrimary == itemType) {
      final previousWeaponSecondary = player.weaponSecondary;
      player.weaponSecondary = itemType;
      player.weaponPrimary = previousWeaponSecondary;
      return;
    }

    player.weaponSecondary = itemType;
    player.weaponType = itemType;
    player.weaponSecondaryQuantity = player.weaponSecondaryCapacity;
  }


  @override
  void customInit() {
    for (final gameObject in gameObjects){
       if (!ItemType.isTypeWeapon(gameObject.type)) continue;
       gameObject
         ..physical = false
         ..interactable = true
         ..fixed = true
         ..strikable = false
         ..gravity = false
         ..collectable = true
       ;
    }

    for (final spawnPoint in scene.spawnPoints) {
       spawnAI(nodeIndex: spawnPoint, characterType: CharacterType.Zombie);
    }
  }

  @override
  void customOnPlayerInteractWithGameObject(Player player, GameObject gameObject){

    final gameObjectType = gameObject.type;

     if (!ItemType.isTypeWeapon(gameObjectType)) return;

     if (gameObjectType == ItemType.Weapon_Thrown_Grenade){
        if (player.grenades >= Max_Grenades){
          player.writeInfo('Grenades Full');
          return;
        }
        player.grenades = Max_Grenades;
        player.writePlayerEventItemAcquired(gameObjectType);
        deactivateCollider(gameObject);
        return;
     }


     if (gameObjectType == player.weaponPrimary) {
       if (player.weaponPrimaryQuantity >= player.weaponPrimaryCapacity) {
         player.writeInfo('${ItemType.getName(gameObjectType)} Full');
         return;
       }
     }

     if (gameObjectType == player.weaponSecondary) {
       if (player.weaponSecondaryQuantity >= player.weaponSecondaryCapacity) {
         player.writeInfo('${ItemType.getName(gameObjectType)} Full');
         return;
       }
     }

     player.setItemQuantityMax(gameObject.type);
     deactivateCollider(gameObject);

     if (player.aimTargetWeaponSide == Side.Left) {
       playerEquipPrimary(player, gameObject.type);
     } else {
       playerEquipSecondary(player, gameObject.type);
     }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
       if (!gameObject.collectable) return;

      if (gameObject.type == ItemType.Buff_Infinite_Ammo) {
        player.writeInfo('Infinite Ammo');
        player.buffInfiniteAmmo = 15;
        player.writePlayerBuffs();
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Buff_Double_Damage) {
        player.writeInfo('Double Damage');
        player.buffDoubleDamageTimer = 30;
        player.buffDoubleDamage = true;
        player.writePlayerBuffs();
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Buff_No_Recoil) {
        player.writeInfo('No Recoil');
        player.buffNoRecoil = 45;
        player.writePlayerBuffs();
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Buff_Invincible) {
        player.writeInfo('Invincible');
        player.buffInvincibleTimer = 15;
        player.buffInvincible = true;
        player.writePlayerBuffs();
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Buff_Fast) {
        player.writeInfo('Fast');
        player.buffFast = 25;
        player.writePlayerBuffs();
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Consumables_Potion_Red) {
        if (player.health >= player.maxHealth) return;
        player.health = player.maxHealth;
        player.writeInfo('Full Health');
        player.writePlayerEventItemTypeConsumed(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Consumables_Ammo_Box) {
        player.weaponPrimaryQuantity = player.weaponPrimaryCapacity;
        player.weaponSecondaryQuantity = player.weaponSecondaryCapacity;
        player.writeInfo('Full Ammo');
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

      if (gameObject.type == ItemType.Weapon_Thrown_Grenade) {

        if (player.grenades >= Max_Grenades) {
          player.writeInfo('Max Grenades');
          return;
        }
        player.grenades++;
        player.writeInfo('Grenade');
        player.writePlayerEventItemAcquired(gameObject.type);
        deactivateCollider(gameObject);
        return;
      }

       if (gameObject.type == ItemType.Resource_Credit) {
         player.credits += Credits_Collected;
         player.writePlayerEventItemAcquired(gameObject.type);
         deactivateCollider(gameObject);
         return;
       }

      final itemType = gameObject.type;

      if (ItemType.isTypeWeapon(itemType)) {
          if (player.weaponPrimary == itemType) {
            if (player.weaponPrimaryQuantity < player.weaponPrimaryCapacity) {
              player.weaponPrimaryQuantity = player.weaponPrimaryCapacity;
              player.writePlayerEvent(PlayerEvent.Ammo_Acquired);
            }
            return;
          }
          if (player.weaponSecondary == itemType) {
            if (player.weaponSecondaryQuantity < player.weaponSecondaryCapacity) {
              player.weaponSecondaryQuantity = player.weaponSecondaryCapacity;
              player.writePlayerEvent(PlayerEvent.Ammo_Acquired);
            }
            return;
          }

          if (player.weaponPrimary == ItemType.Empty) {
             playerEquipPrimary(player, itemType);
             deactivateCollider(gameObject);
             return;
          }

          if (player.weaponSecondary == ItemType.Empty) {
            playerEquipSecondary(player, itemType);
            deactivateCollider(gameObject);
            return;
          }
      }
  }

  @override
  void customOnHitApplied({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {
    if (target is GameObject) {
      if (target.type == ItemType.GameObjects_Crate_Wooden) {
        dispatchGameEventGameObjectDestroyed(target);
        deactivateCollider(target);
        performScript(timer: Crate_Respawn_Duration).writeSpawnGameObject(
          type: ItemType.GameObjects_Crate_Wooden,
          x: target.x,
          y: target.y,
          z: target.z,
        );

        spawnRandomItemAtPosition(target);
      }
    }
  }

  @override
  void customOnCharacterWeaponStateReady(Character character){
    if (character.weaponType == ItemType.Empty) return;
    if (character is! Player) return;

    if (character.weaponPrimaryEquipped) {
      if (!character.weaponPrimaryEmpty) return;
      character.weaponPrimary = ItemType.Empty;
      character.weaponType = ItemType.Empty;
      return;
    }

    if (!character.weaponSecondaryEmpty) return;
    character.weaponSecondary = ItemType.Empty;
    character.weaponType = ItemType.Empty;
    return;
  }

  @override
  void customOnPlayerCollectGameObject(Player player, GameObject target) {
    customOnCollisionBetweenPlayerAndGameObject(player, target);
  }

  @override
  void customActionSpawnAIAtIndex(int index){
    spawnAI(
      characterType: randomItem(const [CharacterType.Dog, CharacterType.Zombie]),
      nodeIndex: index,
      damage: 1,
      team: TeamType.Evil,
      health: 5,
    );
  }

  @override
  void customOnPlayerJoined(Player player) {
    writePlayerScoresAll();
  }

  @override
  void customOnPlayerDisconnected(Player player) {
    writePlayerScoresAll();
  }

  @override
  void customOnPlayerCreditsChanged(Player player) {
    for (final otherPlayer in players) {
      otherPlayer.writeApiPlayersPlayerScore(player);
    }
  }
}



