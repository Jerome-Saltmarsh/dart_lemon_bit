import 'package:gamestream_ws/packages/common.dart';

class ItemSlot {
  AmuletItem? item;
  var cooldown = 0;

  @override
  String toString() => '{item: $item, cooldown: $cooldown}';

}

extension ItemSlotExtension on ItemSlot {
  void clear(){
    item = null;
    cooldown = 0;
  }
}