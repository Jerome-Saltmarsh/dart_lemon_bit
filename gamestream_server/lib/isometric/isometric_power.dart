
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

  bool get isPositional => type.mode == PowerMode.Positional;

  bool get isTargeted => isTargetedEnemy || isTargetedAlly;

  bool get isTargetedEnemy => type.mode == PowerMode.Targeted_Enemy;

  bool get isTargetedAlly => type.mode == PowerMode.Targeted_Ally;

  bool get isSelf => type.mode == PowerMode.Self;

  bool get ready => cooldownRemaining <= 0;

  void update(){
     if (ready) return;
     cooldownRemaining--;
  }

  void activated(){
    cooldownRemaining = cooldown;
  }

}

