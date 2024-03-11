
import 'package:amulet_engine/common.dart';

enum ValidationError {
   Too_Low,
   Too_High,
}

ValidationError? getAmuletItemValidationError(AmuletItem amuletItem){
   final amount = amuletItem.quantify;
   final constraint = getItemQualityConstraint(amuletItem.quality);
   if (amount < constraint.min){
     return ValidationError.Too_Low;
   }
   if (amount > constraint.max){
     return ValidationError.Too_High;
   }
}

Constraint getItemQualityConstraint(ItemQuality itemQuality) =>
    switch (itemQuality){
      ItemQuality.Common => const Constraint(min: 1, max: 3),
      ItemQuality.Unique => const Constraint(min: 4, max: 6),
      ItemQuality.Rare => const Constraint(min: 6, max: 8)
    };

class Constraint {
  final double min;
  final double max;
  const Constraint({required this.min, required this.max});
}


