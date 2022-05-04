import 'Cost.dart';

class TechTree {
  var pickaxe = 0;
  var bow = 0;
  var sword = 0;
  var axe = 0;
  var hammer = 0;
}

class TechType {
  static const Unarmed = 0;
  static const Pickaxe = 1;
  static const Bow = 2;
  static const Sword = 3;
  static const Shotgun = 4;
  static const Handgun = 5;
  static const Axe = 6;
  static const Hammer = 7;
  static const Bag = 8;

  static bool isValid(int index) => index >= 0 && index <= Bag;

  static String getName(int value) {
    assert (isValid(value));
    return const {
      Unarmed: "Unarmed",
      Pickaxe: "Pickaxe",
      Bow: "Bow",
      Sword: "Sword",
      Shotgun: "Shotgun",
      Handgun: "Handgun",
      Axe: "Axe",
      Hammer: "Hammer",
      Bag: "Bag",
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
      Axe,
      Hammer,
    ].contains(value);
  }

  static int getDuration(int type) {
    return const {
      Unarmed: 20,
      Axe: 20,
      Sword: 20,
      Bow: 25,
      Shotgun: 45,
      Hammer: 45,
    }[type] ?? 20;
  }

  static Cost? getCost(int type, int level) {
    assert (isValid(type));
    assert (level >= 0);
    final costs = const<int, List<Cost>> {
      Pickaxe: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
      ],
      Sword: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
      ],
      Bow: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
      ],
      Axe: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
      ],
      Hammer: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
      ],
      Bag: const[
        Cost(wood: 10, stone: 10),
        Cost(wood: 20, stone: 20),
        Cost(wood: 40, stone: 40),
        Cost(wood: 80, stone: 80),
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
        return 250;
      case TechType.Sword:
        return 30;
      case TechType.Axe:
        return 20;
      case TechType.Hammer:
        return 20;
      case TechType.Bag:
        return 0;
      default:
        throw Exception("Invalid tech type index $type");
    }
  }
}

