
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_library.dart';

import 'isometric/grid.dart';

class GameEvents {
  static void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case AttackType.Shotgun:
        GameAudio.cock_shotgun_3.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }

  static void onChangedStoreVisible(bool storeVisible){
    GameState.inventoryVisible.value = storeVisible;
  }

  static void onChangedPlayerAlive(bool value) {
    if (!value) {
      GameState.actionInventoryClose();
    }
  }

  static void onChangedAmbientShade(int shade) {
    GameState.ambientColor = GameState.colorShades[shade];
    refreshLighting();
    GameState.torchesIgnited.value = shade != Shade.Very_Bright;
  }
}