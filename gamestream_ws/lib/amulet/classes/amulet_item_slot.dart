import 'package:gamestream_ws/packages/common.dart';

class AmuletItemSlot {
  AmuletItem? amuletItem;
  var cooldown = 0;
  var cooldownDuration = 0;
  var charges = 0;
  var max = 0;

  double get cooldownPercentage => cooldown / cooldownDuration;

  @override
  String toString() => '{'
      'item: $amuletItem, '
      'cooldown: $cooldown, '
      'cooldownDuration: $cooldownDuration, '
      'charges: $charges, '
      'max: $max '
  '}';

  void incrementCooldown(){
    assert (charges < max);
    cooldown++;
    if (cooldown < cooldownDuration)
      return;
    charges++;
    cooldown = 0;
  }

  void clear(){
    amuletItem = null;
    cooldown = 0;
    cooldownDuration = 0;
    charges = 0;
    max = 0;
  }

  bool get chargesEmpty => charges <= 0;

  void reduceCharges(){
     if (chargesEmpty){
       return;
     }
     charges--;
  }
}