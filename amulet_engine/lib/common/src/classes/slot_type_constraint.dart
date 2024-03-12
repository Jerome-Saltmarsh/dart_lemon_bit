import '../isometric/slot_type.dart';
import 'constraint.dart';

class SlotTypeConstraint {
  final Constraint weapon;
  final Constraint helm;
  final Constraint armor;
  final Constraint shoes;
  final Constraint consumable;

  const SlotTypeConstraint({
    required this.weapon,
    required this.helm,
    required this.armor,
    required this.shoes,
    required this.consumable,
  });

  Constraint get(SlotType slotType) =>
      switch (slotType){
        SlotType.Weapon => weapon,
        SlotType.Helm => helm,
        SlotType.Armor => armor,
        SlotType.Shoes => shoes,
        SlotType.Consumable => consumable
      };
}
