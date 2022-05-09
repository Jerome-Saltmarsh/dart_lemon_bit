import 'Cost.dart';

class StructureType {
  static const Tower = 0;
  static const Palisade = 1;
  static const Torch = 2;
  static const House = 3;

  static String getName(int type) {
     return const <int, String> {
         Tower: "Tower",
         Palisade: "Palisade",
         Torch: "Torch",
         House: "House",
     }[type] ?? "?";
  }
  
  static Cost getCost(int type) {
    final cost = const <int, Cost> {
      Tower: Cost(wood: 2, stone: 4, gold: 5),
      Palisade: Cost(wood: 2, stone: 2),
      Torch: Cost(wood: 1),
    }[type];
    if (cost == null) {
      throw Exception("Invalid structure type $type");
    }
    return cost;
  }

  static bool isValid(int value) {
     return value >= 0 && value <= House;
  }
}

