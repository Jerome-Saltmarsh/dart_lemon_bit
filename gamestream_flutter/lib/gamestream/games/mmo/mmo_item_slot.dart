
import 'package:gamestream_flutter/gamestream/games/mmo/ui/slot_type.dart';
import 'package:gamestream_flutter/library.dart';

class MMOItemSlot {
  final int index;
  final SlotType slotType;
  final item = Watch<MMOItem?>(null);
  final cooldown = Watch(0);

  MMOItemSlot({required this.slotType, required this.index});

  bool get isEmpty => item.value != null;

  bool acceptsDragFrom(MMOItemSlot src){
     return true;
  }
}

