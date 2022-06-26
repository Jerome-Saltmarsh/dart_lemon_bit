class GridNodeType {
  static const Empty = 0;
  static const Boundary = 1;
  static const Grass = 2;
  static const Bricks = 3;
  static const Stairs_North = 4;
  static const Stairs_East = 5;
  static const Stairs_South = 6;
  static const Stairs_West = 7;
  static const Water = 8;
  static const Torch = 9;
  static const Tree_Bottom_Pine = 10;
  static const Tree_Top_Pine = 11;
  static const Player_Spawn = 12;
  static const Grass_Long = 13;
  static const Wooden_Wall_Row = 14;
  static const Tree_Bottom_Oak = 15;
  static const Tree_Top_Oak = 16;
  static const Enemy_Spawn = 17;
  static const Rain = 18;

  static bool isStairs(int value){
    return 
        value == Stairs_North || 
        value == Stairs_East ||
        value == Stairs_West || 
        value == Stairs_South
    ;
  }
}