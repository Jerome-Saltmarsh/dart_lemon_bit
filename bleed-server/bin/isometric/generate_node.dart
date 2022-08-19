
import '../classes/node.dart';
import '../common/node_type.dart';

Node generateNode(int type){
  if (type == NodeType.Empty) {
    return Node.empty;
  }

  if (NodeType.isOriented(type)){
    return NodeOriented(
      orientation: NodeType.getDefaultOrientation(type),
      type: type,
    );
  }

  switch(type) {
    case NodeType.Boundary:
      return Node.boundary;
    case NodeType.Water:
      return Node.water;
    case NodeType.Water_Flowing:
      return Node.waterFlowing;
    case NodeType.Grass:
      return Node.grass;
    case NodeType.Grass_Flowers:
      return Node.grassFlowers;
    case NodeType.Bricks:
      return Node.bricks;
    case NodeType.Stairs_North:
      return NodeStairsNorth();
    case NodeType.Stairs_East:
      return NodeStairsEast();
    case NodeType.Stairs_South:
      return NodeStairsSouth();
    case NodeType.Stairs_West:
      return NodeStairsWest();
    case NodeType.Torch:
      return NodeTorch();
    case NodeType.Tree_Bottom:
      return NodeTreeBottom();
    case NodeType.Tree_Top:
      return Node.treeTop;
    case NodeType.Grass_Long:
      return NodeGrassLong();
    case NodeType.Fireplace:
      return NodeFireplace();
    case NodeType.Wood:
      return Node.wood;
    case NodeType.Grass_Slope_North:
      return NodeGrassSlopeNorth();
    case NodeType.Grass_Slope_East:
      return NodeGrassSlopeEast();
    case NodeType.Grass_Slope_South:
      return NodeGrassSlopeSouth();
    case NodeType.Grass_Slope_West:
      return NodeGrassSlopeWest();
    case NodeType.Brick_Top:
      return NodeBrickTop();
    case NodeType.Wood_Half_Row_1:
      return NodeWoodHalfRow1();
    case NodeType.Wood_Half_Row_2:
      return NodeWoodHalfRow2();
    case NodeType.Wood_Half_Column_1:
      return NodeWoodHalfColumn1();
    case NodeType.Wood_Half_Column_2:
      return NodeWoodHalfColumn2();
    case NodeType.Wood_Corner_Top:
      return NodeWoodCornerTop();
    case NodeType.Wood_Corner_Right:
      return NodeWoodCornerRight();
    case NodeType.Wood_Corner_Bottom:
      return NodeWoodCornerBottom();
    case NodeType.Wood_Corner_Left:
      return NodeWoodCornerLeft();
    case NodeType.Roof_Tile_North:
      return NodeRoofTileNorth();
    case NodeType.Roof_Tile_South:
      return NodeRoofTileSouth();
    case NodeType.Soil:
      return Node.soil;
    case NodeType.Roof_Hay_North:
      return NodeRoofHayNorth();
    case NodeType.Roof_Hay_South:
      return NodeRoofHaySouth();
    case NodeType.Stone:
      return Node.stone;
    case NodeType.Grass_Slope_Top:
      return NodeGrassSlopeTop();
    case NodeType.Grass_Slope_Right:
      return NodeGrassSlopeRight();
    case NodeType.Grass_Slope_Bottom:
      return NodeGrassSlopeBottom();
    case NodeType.Grass_Slope_Left:
      return NodeGrassSlopeLeft();
    case NodeType.Rain_Landing:
      return Node.empty;
    case NodeType.Rain_Falling:
      return Node.empty;
    case NodeType.Grass_Edge_Top:
      return NodeGrassEdgeTop();
    case NodeType.Grass_Edge_Right:
      return NodeGrassEdgeRight();
    case NodeType.Grass_Edge_Bottom:
      return NodeGrassEdgeBottom();
    case NodeType.Grass_Edge_Left:
      return NodeGrassEdgeLeft();
    case NodeType.Bau_Haus:
      return NodeBauHaus();
    case NodeType.Bau_Haus_Roof_North:
      return NodeBauHausRoofNorth();
    case NodeType.Bau_Haus_Roof_South:
      return NodeBauHausRoofSouth();
    case NodeType.Bau_Haus_Window:
      return NodeBauHausWindow();
    case NodeType.Bau_Haus_Plain:
      return NodeBauHausPlain();
    case NodeType.Chimney:
      return NodeChimney();
    case NodeType.Bed_Bottom:
      return NodeBedBottom();
    case NodeType.Bed_Top:
      return NodeBedTop();
    case NodeType.Table:
      return NodeTable();
    case NodeType.Sunflower:
      return NodeSunflower();
    case NodeType.Oven:
      return NodeOven();
    case NodeType.Brick_Stairs:
      return NodeBrickStairs();
    default:
      print("Warning: Cannot generate node for type $type (${NodeType.getName(type)})");
      return Node.empty;
  }
}