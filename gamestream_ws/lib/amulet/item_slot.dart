import 'package:gamestream_ws/packages/common.dart';

class ItemSlot {
  AmuletItem? item;
  var cooldown = 0;

  int get health => item?.health ?? 0;

  double get movement => item?.movement ?? 0;

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