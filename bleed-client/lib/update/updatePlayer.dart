import 'package:bleed_client/audio.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/utils.dart';

void updatePlayer() {
  if (compiledGame.playerId < 0) return;

  sendRequestUpdatePlayer();

  // on player weapon changed
  if (previousWeapon != compiledGame.playerWeapon) {
    previousWeapon = compiledGame.playerWeapon;
    switch (compiledGame.playerWeapon) {
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
