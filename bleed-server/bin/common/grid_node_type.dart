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
  static const Tree_Bottom = 10;
  static const Tree_Top = 11;
  static const Player_Spawn = 12;
  static const Grass_Long = 13;
  static const Wooden_Wall_Row = 14;
  static const Enemy_Spawn = 17;
  static const Rain_Falling = 18;
  static const Rain_Landing = 19;
  static const Fireplace = 20;
  static const Wood = 21;

  static isSolid(int type){
    if (type == GridNodeType.Bricks) return true;
    if (type == GridNodeType.Grass) return true;
    if (type == GridNodeType.Wood) return true;
    return false;
  }
  
  static isStone(int type){
    return const [
        Bricks,
        Stairs_North,
        Stairs_East,
        Stairs_South,
        Stairs_West,
    ].contains(type);
  }

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
    Tree_Bottom,
    Tree_Top,
    Player_Spawn,
    Grass_Long,
    Enemy_Spawn,
    Rain_Falling,
    Rain_Landing,
    Fireplace,
    Wood,
  ];
  
  static String getName(int type){
     return const {
       Empty: 'Empty',
       Boundary: 'Boundary',
       Grass: 'Grass',
       Bricks: 'Bricks',
       Stairs_North: 'Stairs North',
       Stairs_East: 'Stairs East',
       Stairs_South: 'Stairs South',
       Stairs_West: 'Stairs West',
       Water: 'Water',
       Torch: 'Torch',
       Tree_Bottom: 'Tree Bottom',
       Tree_Top: 'Tree Top',
       Player_Spawn: 'Player Spawn',
       Grass_Long: 'Grass Long',
       Enemy_Spawn: 'Enemy Spawn',
       Rain_Falling: 'Rain Falling',
       Rain_Landing: 'Rain Landing',
       Fireplace: 'Fireplace',
       Wood: "Wood",
     }[type] ?? "unknown($type)";
  }
  
  static bool isFire(int value) {
    return value == Fireplace || value == Torch; 
  }
  
  static bool isRain(int value){
    return value == Rain_Falling || value == Rain_Landing;
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