
import 'package:gamestream_flutter/common/src/isometric/weapon_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

extension IsometricLighting on Isometric {

  void applyEmissionsCharacters() {
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;

      if (character.weaponType == WeaponType.Staff){
        applyVector3Emission(
          character,
          alpha: 150,
          saturation: 100,
          value: 100,
          hue: 50,
        );
      } else {
        applyVector3EmissionAmbient(
          character,
          alpha: emissionAlphaCharacter,
        );
      }
    }
  }

}