import 'package:gamestream_ws/packages/common.dart';

class ItemSlot {
  final SlotType slotType;
  AmuletItem? item;
  var cooldown = 0;

  ItemSlot({required this.slotType});

  @override
  String toString() => '{item: $item, cooldown: $cooldown}';

  void clear(){
    item = null;
    cooldown = 0;
  }

  void validate(){
      assert (item == null || cooldown <= 0);
  }
}