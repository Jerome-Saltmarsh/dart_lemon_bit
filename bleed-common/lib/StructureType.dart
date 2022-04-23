class StructureType {
  static const Tower = 0;
  static const Palisade = 1;
  
  static String getName(int type) {
     return const <int, String> {
         Tower: "Tower",
         Palisade: "Palisade",
     }[type] ?? "?";
  }
}
