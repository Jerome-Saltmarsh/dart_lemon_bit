
import 'dart:math';

import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'survival_player.dart';

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

  int getMaxQuantity(int itemType){
    return 5;
  }

  @override
  void customOnPlayerCollectGameObject(
      SurvivalPlayer player,
      IsometricGameObject target,
  ) {
    var quantityRemaining = target.quantity > 0 ? target.quantity : 1;
    final maxQuantity = getMaxQuantity(target.type);
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
          if (player.getDistance(target) >
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

      return;
    }

  }
}