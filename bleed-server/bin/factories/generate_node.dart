
import '../classes/node.dart';
import '../common/grid_node_type.dart';

Node generateNode(int type){
  switch(type) {
    case GridNodeType.Empty:
      return Node.empty;
    case GridNodeType.Boundary:
      return Node.boundary;
    case GridNodeType.Water:
      return Node.water;
    case GridNodeType.Water_Flowing:
      return Node.waterFlowing;
    case GridNodeType.Grass:
      return NodeGrass();
    case GridNodeType.Bricks:
      return NodeBricks();
    case GridNodeType.Stairs_North:
      return NodeStairsNorth();
    case GridNodeType.Stairs_East:
      return NodeStairsEast();
    case GridNodeType.Stairs_South:
      return NodeStairsSouth();
    case GridNodeType.Stairs_West:
      return NodeStairsWest();
    case GridNodeType.Torch:
      return NodeTorch();
    case GridNodeType.Tree_Bottom:
      return NodeTreeBottom();
    case GridNodeType.Tree_Top:
      return NodeTreeTop();
    case GridNodeType.Grass_Long:
      return NodeGrassLong();
    case GridNodeType.Fireplace:
      return NodeFireplace();
    case GridNodeType.Wood:
      return NodeWood();
    case GridNodeType.Grass_Slope_North:
      return NodeGrassSlopeNorth();
    case GridNodeType.Grass_Slope_East:
      return NodeGrassSlopeEast();
    case GridNodeType.Grass_Slope_South:
      return NodeGrassSlopeSouth();
    case GridNodeType.Grass_Slope_West:
      return NodeGrassSlopeWest();
    case GridNodeType.Brick_Top:
      return NodeBrickTop();
    case GridNodeType.Wood_Half_Row_1:
      return NodeWoodHalfRow1();
    case GridNodeType.Wood_Half_Row_2:
      return NodeWoodHalfRow2();
    case GridNodeType.Wood_Half_Column_1:
      return NodeWoodHalfColumn1();
    case GridNodeType.Wood_Half_Column_2:
      return NodeWoodHalfColumn2();
    case GridNodeType.Wood_Corner_Top:
      return NodeWoodCornerTop();
    case GridNodeType.Wood_Corner_Right:
      return NodeWoodCornerRight();
    case GridNodeType.Wood_Corner_Bottom:
      return NodeWoodCornerBottom();
    case GridNodeType.Wood_Corner_Left:
      return NodeWoodCornerLeft();
    case GridNodeType.Roof_Tile_North:
      return NodeRoofTileNorth();
    case GridNodeType.Roof_Tile_South:
      return NodeRoofTileSouth();
    case GridNodeType.Soil:
      return NodeSoil();
    case GridNodeType.Roof_Hay_North:
      return NodeRoofHayNorth();
    case GridNodeType.Roof_Hay_South:
      return NodeRoofHaySouth();
    case GridNodeType.Stone:
      return NodeStone();
    case GridNodeType.Grass_Slope_Top:
      return NodeGrassSlopeTop();
    case GridNodeType.Grass_Slope_Right:
      return NodeGrassSlopeRight();
    case GridNodeType.Grass_Slope_Bottom:
      return NodeGrassSlopeBottom();
    case GridNodeType.Grass_Slope_Left:
      return NodeGrassSlopeLeft();
    case GridNodeType.Rain_Landing:
      return Node.empty;
    case GridNodeType.Rain_Falling:
      return Node.empty;
    default:
      print("Warning: Cannot generate node for type $type (${GridNodeType.getName(type)})");
      return Node.empty;
  }
}