
import 'dart:math';

import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
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
}