enum SlotType {
  Empty,
  Silver_Pendant,
  Frogs_Amulet,
  Brace,
  Dagger,
  Sword_Wooden,
  Sword_Short,
  Sword_Long,
  Bow_Wooden,
  Bow_Green,
  Bow_Gold,
  Staff_Wooden,
  Staff_Blue,
  Staff_Golden,
  Leather_Cap,
  Guards_Helmet,
  Handgun,
  Shotgun,
  SniperRifle,
  AssaultRifle,
  Spell_Tome_Fireball
}

final List<SlotType> slotTypesAll = SlotType.values;
final _SlotTypes slotTypes = _SlotTypes();

class _SlotTypes {

  final List<SlotType> all = SlotType.values;

  final List<SlotType> weapons = [
    SlotType.Sword_Short,
    SlotType.Bow_Wooden,
    SlotType.Sword_Wooden,
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