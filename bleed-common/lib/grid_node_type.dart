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
  static const Tree_Bottom = 15;
  static const Tree_Top = 16;
  static const Enemy_Spawn = 17;
  static const Rain_Falling = 18;
  static const Rain_Landing = 19;
  static const Fireplace = 20;

  static const values = [
    Empty,
    Boundary,
    Grass,
    Bricks,
    Stairs_North,
    Stairs_East,
    Stairs_South,
    Stairs_West,
    Water,
    Torch,
    Tree_Bottom_Pine,
    Tree_Top_Pine,
    Player_Spawn,
    Grass_Long,
    Tree_Bottom,
    Tree_Top,
    Enemy_Spawn,
    Rain_Falling,
    Rain_Landing,
    Fireplace,
  ];
  
  static String getName(int type){
     return const {
       Empty: 'Empty',
       Boundary: 'Boundary',
       Grass: 'Grass',
       Bricks: 'Bricks',
       Stairs_North: 'Stairs_North',
       Stairs_East: 'Stairs_East',
       Stairs_South: 'Stairs_South',
       Stairs_West: 'Stairs_West',
       Water: 'Water',
       Torch: 'Torch',
       Tree_Bottom_Pine: 'Tree_Bottom_Pine',
       Tree_Top_Pine: 'Tree_Top_Pine',
       Player_Spawn: 'Player_Spawn',
       Grass_Long: 'Grass_Long',
       Tree_Bottom: 'Tree_Bottom',
       Tree_Top: 'Tree_Top',
       Enemy_Spawn: 'Enemy_Spawn',
       Rain_Falling: 'Rain_Falling',
       Rain_Landing: 'Rain_Landing',
       Fireplace: 'Fireplace',
     }[type] ?? "unknown($type)";
  }

  static bool isStairs(int value) {
    return
      value == Stairs_North ||
          value == Stairs_East ||
          value == Stairs_West ||
          value == Stairs_South
    ;
  }
}