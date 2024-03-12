
import 'package:amulet_engine/common.dart';

enum ValidationError {
   Too_Low,
   Too_High,
}

ValidationError? getAmuletItemValidationError(AmuletItem amuletItem){
   final amount = amuletItem.quantify;
   final constraint = getConstraint(amuletItem.quality, amuletItem.slotType);
   if (amount < constraint.min){
     return ValidationError.Too_Low;
   }
   if (amount > constraint.max){
     return ValidationError.Too_High;
   }
   return null;
}


Constraint getConstraint(ItemQuality itemQuality, SlotType slotType) =>
    switch (slotType) {
      SlotType.Weapon => switch (itemQuality){
          ItemQuality.Common => const Constraint(min: 1, max: 2.5),
          ItemQuality.Unique => const Constraint(min: 3, max: 5),
          ItemQuality.Rare => const Constraint(min: 6, max: 8)
        },
      SlotType.Helm => switch (itemQuality){
          ItemQuality.Common => const Constraint(min: 1, max: 2.5),
          ItemQuality.Unique => const Constraint(min: 3, max: 5),
          ItemQuality.Rare => const Constraint(min: 6, max: 8)
        },
      SlotType.Armor => switch (itemQuality){
          ItemQuality.Common => const Constraint(min: 3, max: 5),
          ItemQuality.Unique => const Constraint(min: 3, max: 5),
          ItemQuality.Rare => const Constraint(min: 6, max: 8)
        },
      SlotType.Shoes => switch (itemQuality){
          ItemQuality.Common => const Constraint(min: 1, max: 2.5),
          ItemQuality.Unique => const Constraint(min: 3, max: 5),
          ItemQuality.Rare => const Constraint(min: 6, max: 8)
        },
      SlotType.Consumable => const Constraint(min: 0, max: 0)
  };

