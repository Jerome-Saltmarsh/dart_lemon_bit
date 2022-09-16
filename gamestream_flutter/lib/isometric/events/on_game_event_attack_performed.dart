
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_math/library.dart';

void onGameEventAttackPerformed(double x, double y, double z, double angle) {
  final attackType = serverResponseReader.readByte();
  switch (attackType){
    case AttackType.Handgun:
      audioSinglePistolShot20.playXYZ(x, y, z);
      const distance = 20.0;
      final xForward = getAdjacent(angle, distance);
      final yForward = getOpposite(angle, distance);
      spawnParticleHandgunFiring(x: x + xForward, y: y + yForward, z: z + 15, angle: angle);
      break;
    case AttackType.Shotgun:
      return audioSingleShotgunShot.playXYZ(x, y, z);
    case AttackType.Assault_Rifle:
      return audioSingleAssaultRifle.playXYZ(x, y, z);
    case AttackType.Fireball:
      return audioSingleFireball.playXYZ(x, y, z);
    case AttackType.Blade:
      return onGameEventSwordSlash(x, y, z, angle);
    case AttackType.Crowbar:
      audioSingleSwingSword.playXYZ(x, y, z);
      return spawnParticleSlashCrowbar(x, y, z, angle);
    default:
      return;
  }
}
