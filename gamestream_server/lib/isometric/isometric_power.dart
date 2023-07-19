
import 'package:gamestream_server/common/src.dart';

class IsometricPower {

  var cooldownRemaining = 0;
  var level = 1;

  final int duration;
  final int cooldown;
  final double range;
  final PowerType type;

  IsometricPower({
    required this.type,
    required this.range,
    required this.cooldown,
    this.duration = 0,
  });

  bool get isPositional => type.mode == CaptureTheFlagPowerMode.Positional;

  bool get isTargeted => isTargetedEnemy || isTargetedAlly;

  bool get isTargetedEnemy => type.mode == CaptureTheFlagPowerMode.Targeted_Enemy;

  bool get isTargetedAlly => type.mode == CaptureTheFlagPowerMode.Targeted_Ally;

  bool get isSelf => type.mode == CaptureTheFlagPowerMode.Self;

  bool get ready => cooldownRemaining <= 0;

  void update(){
     if (ready) return;
     cooldownRemaining--;
  }

  void activated(){
    cooldownRemaining = cooldown;
  }

}

