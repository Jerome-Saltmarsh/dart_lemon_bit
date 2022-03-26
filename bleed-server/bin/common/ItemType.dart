enum ItemType {
  Health,
  Handgun,
  Shotgun,
  Orb_Ruby,
  Orb_Topaz,
  Orb_Emerald,
  Sword_Wooden,
  Sword_Steel,
  Armour_Plated,
  Wizards_Hat,
  Steel_Helm,
}

const itemTypes = ItemType.values;

final List<ItemType> orbItemTypes = [
  ItemType.Orb_Ruby,
  ItemType.Orb_Topaz,
  ItemType.Orb_Emerald,
];


extension ItemTypeExtension on ItemType {
  bool get isOrb {
    return orbItemTypes.contains(this);
  }
}

