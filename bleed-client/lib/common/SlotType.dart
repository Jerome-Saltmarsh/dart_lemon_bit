enum SlotType {
  Empty,
  Silver_Pendant,
  Frogs_Amulet,
  Brace,
  Dagger,
  Short_Sword,
  Wooden_Sword,
  Forest_Bow,
  Wooden_Staff,
  Leather_Cap,
  Guards_Helmet
}

final List<SlotType> slotTypesAll = SlotType.values;
final _SlotTypes slotTypes = _SlotTypes();

class _SlotTypes {

  final List<SlotType> all = SlotType.values;

  final List<SlotType> weapons = [
    SlotType.Short_Sword,
    SlotType.Forest_Bow,
    SlotType.Wooden_Sword,
  ];

  final List<SlotType> armour = [
    SlotType.Leather_Cap,
    SlotType.Guards_Helmet,
  ];

  final List<SlotType> items = [
    SlotType.Silver_Pendant,
    SlotType.Frogs_Amulet,
  ];
}