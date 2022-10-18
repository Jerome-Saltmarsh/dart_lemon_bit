
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';

void onGameEventAttackPerformed(double x, double y, double z, double angle) {
  final attackType = serverResponseReader.readByte();
  switch (attackType){
    case AttackType.Handgun:
      GameAudio.pistol_shot_20.playXYZ(x, y, z);
      Game.spawnParticleShell(x, y, z);
      break;
    case AttackType.Shotgun:
      return GameAudio.shotgun_shot.playXYZ(x, y, z);
    case AttackType.Assault_Rifle:
      return GameAudio.assault_rifle_shot.playXYZ(x, y, z);
    case AttackType.Rifle:
      return GameAudio.sniper_shot_4.playXYZ(x, y, z);
    case AttackType.Revolver:
      return GameAudio.revolver_shot_2.playXYZ(x, y, z);
    case AttackType.Fireball:
      return GameAudio.fireBolt.playXYZ(x, y, z);
    case AttackType.Blade:
      return onGameEventAttackPerformedBlade(x, y, z, angle);
    case AttackType.Unarmed:
      return onGameEventAttackPerformedUnarmed(x, y, z, angle);
    case AttackType.Crowbar:
      GameAudio.swing_sword.playXYZ(x, y, z);
      return Game.spawnParticleSlashCrowbar(x, y, z, angle);
    default:
      return;
  }
}
