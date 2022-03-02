bool isBow(SlotType slotType){
  return _bows.contains(slotType);
}

bool isStaff(SlotType slotType){
  return _staffs.contains(slotType);
}

bool isFirearm(SlotType slotType){
  return _firearms.contains(slotType);
}

enum SlotType {
  Empty,
  Armour_Padded,
  Silver_Pendant,
  Golden_Necklace,
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
  Spell_Tome_Fireball,
  Spell_Tome_Ice_Ring,
  Spell_Tome_Split_Arrow,
  Body_Blue,
  Potion_Red,
  Potion_Blue,
  Rogue_Hood,
  Magic_Robes,
  Handgun,
  Shotgun,
  Sniper_Rifle,
  Assault_Rifle,
}

final List<SlotType> slotTypes = SlotType.values;

const List<SlotType> _bows = [
  SlotType.Bow_Wooden,
  SlotType.Bow_Green,
  SlotType.Bow_Gold,
];

const List<SlotType> _firearms = [
  SlotType.Handgun,
  SlotType.Shotgun,
];

const List<SlotType> _swords = [
  SlotType.Sword_Wooden,
  SlotType.Sword_Short,
  SlotType.Sword_Long,
];

const List<SlotType> _staffs = [
  SlotType.Staff_Wooden,
  SlotType.Staff_Golden,
  SlotType.Staff_Blue,
];

const List<SlotType> _metal = [
  SlotType.Sword_Short,
  SlotType.Sword_Long,
];

const List<SlotType> _armour = [
  SlotType.Body_Blue,
  SlotType.Armour_Padded,
  SlotType.Magic_Robes,
];

const List<SlotType> _helms = [
  SlotType.Steel_Helmet,
  SlotType.Leather_Cap,
  SlotType.Magic_Hat,
  SlotType.Rogue_Hood,
];

const List<SlotType> _items = [
  SlotType.Silver_Pendant,
  SlotType.Golden_Necklace,
];

extension SlotTypeProperties on SlotType {
  bool get isEmpty => this == SlotType.Empty;
  bool get isWeapon => isBow || isSword || isStaff || isFirearm;
  bool get isMelee => isEmpty || isSword || isStaff;
  bool get isArmour => _armour.contains(this);
  bool get isHelm => _helms.contains(this);
  bool get isItem => _items.contains(this);
  bool get isBow => _bows.contains(this);
  bool get isShotgun => this == SlotType.Shotgun;
  bool get isHandgun => this == SlotType.Handgun;
  bool get isFirearm => _firearms.contains(this);
  bool get isSword => _swords.contains(this);
  bool get isStaff => _staffs.contains(this);
  bool get isMetal => _metal.contains(this);

  int get damage {
    return _slotTypeDamage[this] ?? 0;
  }

  int get health {
    return _slotTypeHealth[this] ?? 0;
  }

  int get magic {
    return _slotTypeMagic[this] ?? 0;
  }

  double get range {
    return _slotTypeRange[this] ?? 0;
  }

  int get duration {
    return _slotTypeDuration[this] ?? 30;
  }
}

const Map<SlotType, int> _slotTypeDamage = {
  SlotType.Empty: 1,
  SlotType.Sword_Wooden: 2,
  SlotType.Sword_Short: 4,
  SlotType.Sword_Long: 8,
  SlotType.Bow_Wooden: 2,
  SlotType.Bow_Green: 4,
  SlotType.Bow_Gold: 5,
  SlotType.Staff_Wooden: 2,
  SlotType.Staff_Blue: 4,
  SlotType.Staff_Golden: 6,
  SlotType.Handgun: 2,
  SlotType.Shotgun: 6,
};

const Map<SlotType, int> _slotTypeHealth = {
  SlotType.Steel_Helmet: 5,
  SlotType.Body_Blue: 10,
  SlotType.Golden_Necklace: 4,
  SlotType.Armour_Padded: 10,
  SlotType.Magic_Robes: 6,
};

const Map<SlotType, int> _slotTypeMagic = {
  SlotType.Steel_Helmet: 5,
  SlotType.Body_Blue: 10,
  SlotType.Magic_Hat: 10,
  SlotType.Staff_Wooden: 10,
  SlotType.Staff_Blue: 15,
  SlotType.Staff_Golden: 20,
  SlotType.Golden_Necklace: 4,
  SlotType.Magic_Robes: 15,
};

const Map<SlotType, int> _slotTypeDuration = {
  SlotType.Empty: 20,
  SlotType.Sword_Wooden: 20,
  SlotType.Sword_Short: 25,
  SlotType.Sword_Long: 30,
  SlotType.Shotgun: 45,
  SlotType.Handgun: 20,
  SlotType.Bow_Wooden: 20,
  SlotType.Bow_Green: 20,
  SlotType.Bow_Gold: 20,
};

const Map<SlotType, double> _slotTypeRange = {
  SlotType.Empty: 25,
  SlotType.Sword_Wooden: 35,
  SlotType.Sword_Short: 60,
  SlotType.Sword_Long: 70,
  SlotType.Bow_Wooden: 300,
  SlotType.Bow_Green: 500,
  SlotType.Bow_Gold: 600,
  SlotType.Staff_Wooden: 45,
  SlotType.Staff_Blue: 45,
  SlotType.Staff_Golden: 45,
  SlotType.Handgun: 400,
  SlotType.Shotgun: 300,
};
