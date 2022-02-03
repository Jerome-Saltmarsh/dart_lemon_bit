enum SlotType {
  Empty,
  Pendant,
  Amulet,
  Brace,
  Dagger,
  Short_Sword,
  Forest_Bow,
  Wooden_Staff,
  Leather_Cap,
  Guards_Helmet
}

final List<SlotType> slotTypeWeapons = [
  SlotType.Short_Sword,
  SlotType.Forest_Bow,
];

final List<SlotType> slotTypeArmour = [
  SlotType.Leather_Cap,
  SlotType.Guards_Helmet,
];

final List<SlotType> slotTypes = SlotType.values;