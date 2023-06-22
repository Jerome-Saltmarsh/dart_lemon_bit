
import 'dart:math';

import 'package:bleed_server/common/src/interact_mode.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/isometric/src.dart';
import 'package:bleed_server/src/games/survival/survival_player.dart';

class SurvivalGame extends IsometricGame<SurvivalPlayer> {

  SurvivalGame({
    required super.scene,
    required super.time,
    required super.environment,
    required super.gameType,
  });


  @override
  SurvivalPlayer buildPlayer() => SurvivalPlayer(this);

  @override
  int get maxPlayers => 12;

  @override
  void customOnPlayerDead(SurvivalPlayer player) {
    super.customOnPlayerDead(player);
    player.interactMode = InteractMode.None;
  }

  @override
  void customOnPlayerCollectGameObject(
      SurvivalPlayer player,
      IsometricGameObject target,
  ) {
    var quantityRemaining = target.quantity > 0 ? target.quantity : 1;
    final maxQuantity = ItemType.getMaxQuantity(target.type);
    if (maxQuantity > 1) {
      for (var i = 0; i < player.inventory.length; i++) {
        if (player.inventory[i] != target.type) continue;
        if (player.inventoryQuantity[i] + quantityRemaining < maxQuantity) {
          player.inventoryQuantity[i] += quantityRemaining;
          player.inventoryDirty = true;
          deactivateCollider(target);
          player.writePlayerEventItemAcquired(target.type);
          clearCharacterTarget(player);
          return;
        }
        quantityRemaining -= maxQuantity - player.inventoryQuantity[i];
        player.inventoryQuantity[i] = maxQuantity;
        player.inventoryDirty = true;
      }
    }

    assert(quantityRemaining >= 0);
    if (quantityRemaining <= 0) return;

    final emptyInventoryIndex = player.getEmptyInventoryIndex();
    if (emptyInventoryIndex != null) {
      player.inventory[emptyInventoryIndex] = target.type;
      player.inventoryQuantity[emptyInventoryIndex] =
          min(quantityRemaining, maxQuantity);
      player.inventoryDirty = true;
      deactivateCollider(target);
      player.writePlayerEventItemAcquired(target.type);
      clearCharacterTarget(player);
    } else {
      clearCharacterTarget(player);
      player.writePlayerEventInventoryFull();
      return;
    }
    clearCharacterTarget(player);
    return;
  }

  @override
  void updatePlayer(SurvivalPlayer player) {
    super.updatePlayer(player);

    final target = player.target;

    if (target is IsometricCollider) {
      if (target is IsometricGameObject) {
        if (!target.active) {
          clearCharacterTarget(player);
          return;
        }
        if (target.collectable || target.interactable) {
          // if (getDistanceBetweenV3(player, target) >
          if (player.getDistance3(target) >
              IsometricSettings.Interact_Radius) {
            setCharacterStateRunning(player);
            return;
          }
          if (target.interactable) {
            player.setCharacterStateIdle();
            customOnPlayerInteractWithGameObject(player, target);
            player.target = null;
            return;
          }
          if (target.collectable) {
            player.setCharacterStateIdle();
            customOnPlayerCollectGameObject(player, target);
            player.target = null;
            return;
          }
        }
      } else {
        if (!target.active || !target.hitable) {
          clearCharacterTarget(player);
          return;
        }
      }

      if (player.targetIsEnemy) {
        player.lookAt(target);
        if (player.withinAttackRange(target)) {
          if (!player.weaponStateBusy) {
            characterUseWeapon(player);
          }
          clearCharacterTarget(player);
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (target is IsometricAI && player.targetIsAlly) {
        if (player.withinRadiusPosition(target, 100)) {
          if (!target.deadOrBusy) {
            target.face(player);
          }
          final onInteractedWith = target.onInteractedWith;
          if (onInteractedWith != null) {
            player.interactMode = InteractMode.Talking;
            onInteractedWith(player);
          }
          clearCharacterTarget(player);
          player.setCharacterStateIdle();
          return;
        }
        setCharacterStateRunning(player);
        return;
      }
      return;
    }

  }
}