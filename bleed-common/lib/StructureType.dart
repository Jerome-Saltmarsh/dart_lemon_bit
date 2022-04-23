class StructureType {
  static const Tower = 0;
  static const Palisade = 1;
  
  static String getName(int type) {
     return const <int, String> {
         Tower: "Tower",
         Palisade: "Palisade",
     }[type] ?? "?";
  }
  
  static Cost getCost(int type) {
    final cost = const <int, Cost> {
      Tower: Cost(wood: 2, stone: 4, gold: 5),
      Palisade: Cost(wood: 2, stone: 2),
    }[type];
    if (cost == null){
      throw Exception("Invalid structure type $type");
    }
    return cost;
  }
}

class Cost {
  final wood;
  final stone;
  final gold;
  const Cost({this.wood = 0, this.stone = 0, this.gold = 0});
}
