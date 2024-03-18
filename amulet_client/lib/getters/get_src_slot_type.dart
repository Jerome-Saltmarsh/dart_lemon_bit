import 'package:amulet_common/src.dart';


List<double> getSrcSlotType(SlotType slotType) =>
    switch (slotType) {
      SlotType.Consumable => const [528, 0, 32 ,32],
      SlotType.Helm => const [528, 32, 32 ,32],
      SlotType.Armor => const [528, 64, 32 ,32],
      SlotType.Shoes => const [528, 96, 32 ,32],
      SlotType.Weapon => const [528, 128, 32 ,32],
    };
