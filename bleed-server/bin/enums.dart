import 'common/Tile.dart';

bool isShootable(int tile) {
  return isWalkable(tile) || tile == Tile.Water;
}

bool isWalkable(int tile){
  return  const <int, bool>{
    Tile.Grass: true,
    Tile.Flowers: true,
    Tile.Long_Grass: true,
    Tile.Zombie_Spawn: true,
    Tile.Concrete: true,
    Tile.Bridge: true,
    Tile.Wooden_Floor: true,
    Tile.Rock: true,
  }.containsKey(tile);
}



