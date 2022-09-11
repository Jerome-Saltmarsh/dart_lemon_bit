
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_math/library.dart';

void onGameEventAttackPerformed(double x, double y, double z, double angle) {
  final attackType = serverResponseReader.readByte();
  switch (attackType){
    case AttackType.Handgun:
      audioSingleHandgunFired.playXYZ(x, y, z);
      const distance = 20.0;
      final xForward = getAdjacent(angle, distance);
      final yForward = getOpposite(angle, distance);
      spawnParticleShell(x: x + xForward, y: y + yForward);
      spawnParticleHandgunFiring(x: x + xForward, y: y + yForward, z: z + 15, angle: angle);
      break;
    case AttackType.Shotgun:
      audioSingleShotgunShot.playXYZ(x, y, z);
      spawnParticleShell(x: x, y: y);
      break;
    case AttackType.Assault_Rifle:
      audioSingleAssaultRifle.playXYZ(x, y, z);
      // spawnParticleShell(x: x, y: y);
      break;
    default:
      return;
  }
}
