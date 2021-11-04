import 'package:bleed_client/audio.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/utils.dart';

void updatePlayer() {
  if (game.playerId < 0) return;

  sendRequestUpdatePlayer();

  // on player weapon changed
  if (previousWeapon != game.playerWeapon) {
    previousWeapon = game.playerWeapon;
    switch (game.playerWeapon) {
      case Weapon.HandGun:
        playAudioReload(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.Shotgun:
        playAudioCockShotgun(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.SniperRifle:
        playAudioSniperEquipped(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.AssaultRifle:
        playAudioReload(screenCenterWorldX, screenCenterWorldY);
        break;
    }
    rebuildUI();
  }
}
