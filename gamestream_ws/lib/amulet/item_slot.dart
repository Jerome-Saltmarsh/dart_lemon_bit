import 'package:gamestream_ws/packages/common.dart';

class ItemSlot {
  AmuletItem? amuletItem;
  var cooldown = 0;
  var cooldownDuration = 0;
  var charges = 0;
  var max = 0;

  @override
  String toString() => '{'
      'item: $amuletItem, '
      'cooldown: $cooldown, '
      'cooldownDuration: $cooldownDuration, '
      'charges: $charges, '
      'max: $max '
  '}';
}

extension ItemSlotExtension on ItemSlot {
  void clear(){
    amuletItem = null;
    cooldown = 0;
    cooldownDuration = 0;
    charges = 0;
    max = 0;
  }
}