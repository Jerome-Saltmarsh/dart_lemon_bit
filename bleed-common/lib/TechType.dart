class TechTree {
  var pickaxe = 0;
  var bow = 0;
  var sword = 0;

  double getRange(int type) {
    switch (type) {
      case TechType.Unarmed:
        return 20;
      case TechType.Pickaxe:
        return 20;
      case TechType.Bow:
        return 100;
      case TechType.Sword:
        return 30;
      default:
        throw Exception("Invalid tech type index $type");
    }
  }

  int getDamage(int type) {
    switch (type) {
      case TechType.Unarmed:
        return 1;
      case TechType.Pickaxe:
        return 1;
      case TechType.Bow:
        return 1;
      case TechType.Sword:
        return 2;
      default:
        throw Exception("Invalid tech type index $type");
    }
  }
}

class TechType {
  static const Unarmed = 0;
  static const Pickaxe = 1;
  static const Bow = 2;
  static const Sword = 3;
  static const Shotgun = 4;
  static const Handgun = 5;

  static bool isValid(int index) => index >= 0 && index <= Handgun;

  static String getName(int value) {
    assert (isValid(value));
    return const {
      Unarmed: "Unarmed",
      Pickaxe: "Pickaxe",
      Bow: "Bow",
      Sword: "Sword",
      Shotgun: "Shotgun",
      Handgun: "Handgun"
    }[value] ?? "?";
  }
  
  static String getDescription(int value) {
    assert (isValid(value));
    return const {
      Unarmed: "Unarmed",
      Pickaxe: "+5 Damage to Rocks",
      Bow: "Shoot enemies from a distance",
      Sword: "Fight enemies at close range",
      Shotgun: "Shotgun",
      Handgun: "Handgun"
    }[value] ?? "?";
    
  }

  static bool isBow(int value) {
    return value == Bow;
  }

  static bool isMelee(int value) {
    return const [
      Unarmed,
      Pickaxe,
      Sword,
    ].contains(value);
  }

  static int getDuration(int type) {
    return const {
      Unarmed: 20,
      Sword: 20,
      Bow: 25,
      Shotgun: 45,
    }[type] ?? 20;
  }
}

