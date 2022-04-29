import 'Cost.dart';

class TechTree {
  var pickaxe = 0;
  var bow = 0;
  var sword = 0;
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
      Pickaxe: "Used to mine rocks",
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

  static Cost? getCost(int type, int level) {
    assert (isValid(type));
    assert (level >= 0);
    final costs = const<int, List<Cost>> {
      Pickaxe: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 100, stone: 50, gold: 75),
        Cost(wood: 150, stone: 150, gold: 150),
        Cost(wood: 300, stone: 200, gold: 300),
      ],
      Sword: const[
        Cost(wood: 5, stone: 3, gold: 5),
        Cost(wood: 5, stone: 3, gold: 25),
        Cost(wood: 5, stone: 3, gold: 100),
        Cost(wood: 5, stone: 3, gold: 300),
      ],
      Bow: const[
        Cost(wood: 5, stone: 5, gold: 0),
        Cost(wood: 5, stone: 3),
        Cost(wood: 5, stone: 3),
        Cost(wood: 5, stone: 3),
      ],
    }[type];
    if (costs == null) throw Exception("cannot get cost for type $type");
    if (level >= costs.length) return null;
    return costs[level];
  }


  static double getRange(int type) {
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

}

