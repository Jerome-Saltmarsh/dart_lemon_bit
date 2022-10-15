
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';

void onGameEventAttackPerformed(double x, double y, double z, double angle) {
  final attackType = serverResponseReader.readByte();
  switch (attackType){
    case AttackType.Handgun:
      AudioEngine.audioSinglePistolShot20.playXYZ(x, y, z);
      spawnParticleShell(x, y, z);
      break;
    case AttackType.Shotgun:
      return AudioEngine.audioSingleShotgunShot.playXYZ(x, y, z);
    case AttackType.Assault_Rifle:
      return AudioEngine.audioSingleAssaultRifle.playXYZ(x, y, z);
    case AttackType.Rifle:
      return AudioEngine.audioSingleSniperRifleFired.playXYZ(x, y, z);
    case AttackType.Revolver:
      return AudioEngine.audioSingleRevolverFired.playXYZ(x, y, z);
    case AttackType.Fireball:
      return AudioEngine.audioSingleFireball.playXYZ(x, y, z);
    case AttackType.Blade:
      return onGameEventAttackPerformedBlade(x, y, z, angle);
    case AttackType.Unarmed:
      return onGameEventAttackPerformedUnarmed(x, y, z, angle);
    case AttackType.Crowbar:
      AudioEngine.audioSingleSwingSword.playXYZ(x, y, z);
      return spawnParticleSlashCrowbar(x, y, z, angle);
    default:
      return;
  }
}
