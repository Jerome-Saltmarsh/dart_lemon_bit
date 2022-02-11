enum SlotType {
  Empty,
  Silver_Pendant,
  Frogs_Amulet,
  Brace,
  Dagger,
  Sword_Wooden,
  Sword_Short,
  Sword_Long,
  Pants_Blue,
  Bow_Wooden,
  Bow_Green,
  Bow_Gold,
  Staff_Wooden,
  Staff_Blue,
  Staff_Golden,
  Leather_Cap,
  Steel_Helmet,
  Magic_Hat,
  Handgun,
  Shotgun,
  SniperRifle,
  AssaultRifle,
  Spell_Tome_Fireball,
  Body_Blue,
  Potion_Red,
  Potion_Blue,
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

  final List<SlotType> bows = [
    SlotType.Bow_Wooden,
    SlotType.Bow_Green,
    SlotType.Bow_Gold,
  ];

  final List<SlotType> melee = [
    SlotType.Empty,
    SlotType.Sword_Wooden,
    SlotType.Sword_Short,
    SlotType.Sword_Long,
  ];

  final List<SlotType> armour = [
    SlotType.Body_Blue,
  ];

  final List<SlotType> helms = [
    SlotType.Steel_Helmet,
    SlotType.Leather_Cap,
    SlotType.Magic_Hat,
  ];

  final List<SlotType> items = [
    SlotType.Silver_Pendant,
    SlotType.Frogs_Amulet,
  ];
}

extension SlotTypeProperties on SlotType {
  bool get isEmpty => this == SlotType.Empty;
  bool get isWeapon => slotTypes.weapons.contains(this);
  bool get isArmour => slotTypes.armour.contains(this);
  bool get isHelm => slotTypes.helms.contains(this);
  bool get isItem => slotTypes.items.contains(this);
  bool get isBow => slotTypes.bows.contains(this);
  bool get isMelee => slotTypes.melee.contains(this);

  int get damage {
    return slotTypeDamage[this] ?? 0;
  }

  int get health {
    return slotTypeHealth[this] ?? 0;
  }

  int get magic {
    return slotTypeMagic[this] ?? 0;
  }

  double get range {
    return slotTypeRange[this] ?? 0;
  }
}

const Map<SlotType, int> slotTypeDamage = {
  SlotType.Empty: 1,
  SlotType.Sword_Wooden: 2,
  SlotType.Sword_Short: 4,
  SlotType.Sword_Long: 8,
  SlotType.Bow_Wooden: 2,
  SlotType.Bow_Green: 4,
  SlotType.Bow_Gold: 5,
  SlotType.Staff_Wooden: 1,
  SlotType.Staff_Blue: 2,
  SlotType.Staff_Golden: 5,
};

const Map<SlotType, int> slotTypeHealth = {
  SlotType.Steel_Helmet: 5,
  SlotType.Body_Blue: 10,
};

const Map<SlotType, int> slotTypeMagic = {
  SlotType.Steel_Helmet: 5,
  SlotType.Body_Blue: 10,
};

const Map<SlotType, double> slotTypeRange = {
  SlotType.Empty: 25,
  SlotType.Sword_Wooden: 35,
  SlotType.Sword_Short: 60,
  SlotType.Sword_Long: 70,
  SlotType.Bow_Wooden: 300,
  SlotType.Bow_Green: 500,
  SlotType.Bow_Gold: 600,
};
