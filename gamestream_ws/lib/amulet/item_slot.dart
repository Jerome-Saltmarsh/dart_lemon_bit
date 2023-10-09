import 'package:gamestream_ws/packages/common.dart';

class ItemSlot {
  AmuletItem? item;
  var cooldown = 0;
  var quantity = 0;

  @override
  String toString() => '{item: $item, cooldown: $cooldown, quantity: $quantity}';

}

extension ItemSlotExtension on ItemSlot {
  void clear(){
    item = null;
    cooldown = 0;
    quantity = 0;
  }
}