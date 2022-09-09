
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onChangedPlayerAttackType(int value) {

  if (playModeEdit){
    if (value != AttackType.Node_Cannon){
       setPlayModePlay();
    }
  }

   switch (value) {
     case AttackType.Node_Cannon:
       setPlayModeEdit();
       break;
   }
}