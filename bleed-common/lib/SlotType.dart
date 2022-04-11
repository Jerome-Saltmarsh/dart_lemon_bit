class SlotType {
  static const Empty = 0;
  static const Armour_Padded = 1;
  static const Silver_Pendant = 2;
  static const Golden_Necklace = 3;
  static const Brace = 4;
  static const Dagger = 5;
  static const Sword_Wooden = 6;
  static const Sword_Short = 7;
  static const Sword_Long = 8;
  static const Pants_Blue = 9;
  static const Bow_Wooden = 10;
  static const Bow_Green = 11;
  static const Bow_Gold = 12;
  static const Staff_Wooden = 13;
  static const Staff_Blue = 14;
  static const Staff_Golden = 15;
  static const Leather_Cap = 16;
  static const Steel_Helmet = 17;
  static const Magic_Hat = 18;
  static const Spell_Tome_Fireball = 19;
  static const Spell_Tome_Ice_Ring = 20;
  static const Spell_Tome_Split_Arrow = 21;
  static const Body_Blue = 22;
  static const Potion_Red = 23;
  static const Potion_Blue = 24;
  static const Rogue_Hood = 25;
  static const Magic_Robes = 26;
  static const Handgun = 27;
  static const Shotgun = 28;
  static const Sniper_Rifle = 29;
  static const Assault_Rifle = 30;

  static bool isWeapon(int value) {
    return isSword(value) || isBow(value) || isStaff(value) || isFirearm(value);
  }

  static int getDamage(int value) {
    return const <int, int>{
      Empty: 1,
      Sword_Wooden: 2,
      Sword_Short: 4,
      Sword_Long: 8,
      Bow_Wooden: 2,
      Bow_Green: 4,
      Bow_Gold: 5,
      Staff_Wooden: 2,
      Staff_Blue: 4,
      Staff_Golden: 6,
      Handgun: 2,
      Shotgun: 6,
    }[value] ?? 0;
  }

  static int getHealth(int slotType) {
    return const <int, int>{
      Steel_Helmet: 5,
      Body_Blue: 10,
      Golden_Necklace: 4,
      Armour_Padded: 10,
      Magic_Robes: 6,
    }[slotType] ?? 0;
  }

  static int getMagic(int value) {
    return const <int, int>{
      Steel_Helmet: 5,
      Body_Blue: 10,
      Magic_Hat: 10,
      Staff_Wooden: 10,
      Staff_Blue: 15,
      Staff_Golden: 20,
      Golden_Necklace: 4,
      Magic_Robes: 15,
    }[value] ?? 0;
  }

  static String getName(int value) {
    return const <int, String>{
      Golden_Necklace: "King's Necklace",
      Sword_Wooden: "Wooden Sword",
      Sword_Short: "Steel Sword",
      Sword_Long: "Iron Sword",
      Bow_Wooden: "Wooden Bow",
      Bow_Gold: "Golden Bow",
      Bow_Green: "Forest Bow",
      Staff_Wooden: "Gnarled Staff",
      Staff_Blue: "Sapphire Staff",
      Staff_Golden: "Golden Staff",
      Spell_Tome_Fireball: "Ability Fireball",
      Spell_Tome_Ice_Ring: "Ability Ice Ring",
      Spell_Tome_Split_Arrow: "Ability Split Arrows",
      Steel_Helmet: "Knight's Helm",
      Armour_Padded: "Padded Armour",
      Body_Blue: "Steel Tunic",
      Potion_Red: "Health Potion",
      Rogue_Hood: "Rogue's Hood",
      Potion_Blue: "Magic Potion",
      Magic_Hat: "Wizards Hat",
      Magic_Robes: "Robes of Magic",
      Handgun: "handgun",
      Shotgun: "Shotgun",
    } [value] ?? "?";
  }

  static bool isFirearm(int value) {
    return const <int>[
      Handgun,
      Shotgun,
    ].contains(value);
  }

  static bool isSword(int value) {
    return const [
      Sword_Wooden,
      Sword_Short,
      Sword_Long,
    ].contains(value);
  }

  static bool isStaff(int value) {
    return const <int>[
      Staff_Wooden,
      Staff_Golden,
      Staff_Blue,
    ].contains(value);
  }

  static bool isMetal(int value) {
    return const <int>[
      Sword_Short,
      Sword_Long,
    ].contains(value);
  }

  static bool isArmour(int value) {
    return const <int>[
      Body_Blue,
      Armour_Padded,
      Magic_Robes,
    ].contains(value);
  }

  static bool isHelm(int value) {
    return const <int>[
      Steel_Helmet,
      Leather_Cap,
      Magic_Hat,
      Rogue_Hood,
    ].contains(value);
  }

  static bool isItem(int value) {
    return const <int>[
      Silver_Pendant,
      Golden_Necklace,
    ].contains(value);
  }


  static bool isMelee(int value){
    return value == Empty || isSword(value) || isStaff(value);
  }

  static bool isBow(int value) {
    return const [
      Bow_Wooden,
      Bow_Green,
      Bow_Gold,
    ].contains(value);
  }

  static int getDuration(int value) {
    return const {
      Empty: 20,
      Sword_Wooden: 20,
      Sword_Short: 25,
      Sword_Long: 30,
      Shotgun: 45,
      Handgun: 20,
      Bow_Wooden: 20,
      Bow_Green: 20,
      Bow_Gold: 20,
    }[value] ?? 30;
  }

  static double getRange(int value) {
    return const<int, double>{
      Empty: 25,
      Sword_Wooden: 35,
      Sword_Short: 60,
      Sword_Long: 70,
      Bow_Wooden: 300,
      Bow_Green: 500,
      Bow_Gold: 600,
      Staff_Wooden: 45,
      Staff_Blue: 45,
      Staff_Golden: 45,
      Handgun: 400,
      Shotgun: 300,
    }[value] ?? 0;
  }
}


