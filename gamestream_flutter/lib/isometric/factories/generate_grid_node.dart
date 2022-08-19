import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/nodes.dart';

Node generateNode(int z, int row, int column, int type){
  switch (type){
    case NodeType.Boundary:
      return Node.boundary;
    case NodeType.Empty:
      return Node.empty;
    case NodeType.Grass:
      return NodeGrass(row, column, z);
    case NodeType.Grass_Flowers:
      return NodeGrassFlowers(row, column, z);
    case NodeType.Bricks:
      return NodeBricks(row, column, z);
    case NodeType.Roof_Hay_South:
      return NodeRoofHaySouth(row, column, z);
    case NodeType.Roof_Hay_North:
      return NodeRoofHayNorth(row, column, z);
    case NodeType.Fireplace:
      return NodeFireplace(row, column, z);
    case NodeType.Tree_Top:
      return NodeTreeTop(row, column, z);
    case NodeType.Tree_Bottom:
      return NodeTreeBottom(row, column, z);
    case NodeType.Stone:
      return NodeStone(row, column, z);
    case NodeType.Torch:
      return NodeTorch(row, column, z);
    case NodeType.Water_Flowing:
      return NodeWaterFlowing(row, column, z);
    case NodeType.Water:
      return NodeWater(row, column, z);
    case NodeType.Wood_Corner_Right:
      return NodeWoodCornerRight(row, column, z);
    case NodeType.Wood_Corner_Top:
      return NodeWoodCornerTop(row, column, z);
    case NodeType.Wood_Corner_Left:
      return NodeWoodCornerLeft(row, column, z);
    case NodeType.Wood_Corner_Bottom:
      return NodeWoodCornerBottom(row, column, z);
    case NodeType.Soil:
      return NodeSoil(row, column, z);
    case NodeType.Grass_Long:
      return NodeGrassLong(row, column, z);
    case NodeType.Grass_Slope_South:
      return NodeGrassSlopeSouth(row, column, z);
    case NodeType.Grass_Slope_North:
      return NodeGrassSlopeNorth(row, column, z);
    case NodeType.Grass_Slope_East:
      return NodeGrassSlopeEast(row, column, z);
    case NodeType.Grass_Slope_West:
      return NodeGrassSlopeWest(row, column, z);
    case NodeType.Grass_Slope_Left:
      return NodeGrassSlopeLeft(row, column, z);
    case NodeType.Grass_Slope_Top:
      return NodeGrassSlopeTop(row, column, z);
    case NodeType.Grass_Slope_Right:
      return NodeGrassSlopeRight(row, column, z);
    case NodeType.Grass_Slope_Bottom:
      return NodeGrassSlopeBottom(row, column, z);
    case NodeType.Wood:
      return NodeWood(row, column, z);
    case NodeType.Rain_Landing:
      return NodeRainLanding(row, column, z);
    case NodeType.Rain_Falling:
      return NodeRainFalling(row, column, z);
    case NodeType.Stairs_North:
      return NodeStairsNorth(row, column, z);
    case NodeType.Stairs_East:
      return NodeStairsEast(row, column, z);
    case NodeType.Stairs_South:
      return NodeStairsSouth(row, column, z);
    case NodeType.Stairs_West:
      return NodeStairsWest(row, column, z);
    case NodeType.Wood_Half_Column_1:
      return NodeWoodHalfColumn1(row, column, z);
    case NodeType.Wood_Half_Column_2:
      return NodeWoodHalfColumn2(row, column, z);
    case NodeType.Wood_Half_Row_1:
      return NodeWoodHalfRow1(row, column, z);
    case NodeType.Wood_Half_Row_2:
      return NodeWoodHalfRow2(row, column, z);
    case NodeType.Brick_Top:
      return NodeBrickTop(row, column, z);
    case NodeType.Roof_Tile_North:
      return NodeTileNorth(row, column, z);
    case NodeType.Roof_Tile_South:
      return NodeTileSouth(row, column, z);
    case NodeType.Grass_Edge_Top:
      return NodeGrassEdgeTop(row, column, z);
    case NodeType.Grass_Edge_Right:
      return NodeGrassEdgeRight(row, column, z);
    case NodeType.Grass_Edge_Bottom:
      return NodeGrassEdgeBottom(row, column, z);
    case NodeType.Grass_Edge_Left:
      return NodeGrassEdgeLeft(row, column, z);
    case NodeType.Bau_Haus:
      return NodeBauHaus(row, column, z);
    case NodeType.Bau_Haus_Roof_North:
      return NodeBauHausRoofNorth(row, column, z);
    case NodeType.Bau_Haus_Roof_South:
      return NodeBauHausRoofSouth(row, column, z);
    case NodeType.Bau_Haus_Window:
      return NodeBauHausWindow(row, column, z);
    case NodeType.Bau_Haus_Plain:
      return NodeBauHausPlain(row, column, z);
    case NodeType.Chimney:
      return NodeBauHausChimney(row, column, z);
    case NodeType.Bed_Top:
      return NodeBedTop(row, column, z);
    case NodeType.Bed_Bottom:
      return NodeBedBottom(row, column, z);
    case NodeType.Table:
      return NodeTable(row, column, z);
    case NodeType.Sunflower:
      return NodeSunflower(row, column, z);
    case NodeType.Oven:
      return NodeOven(row, column, z);
    case NodeType.Brick_Stairs:
      return NodeBrickStairs(row, column, z);
    case NodeType.Wood_2:
      return NodeWood2(row, column, z);
    case NodeType.Cottage_Roof:
      return NodeCottageRoof(row, column, z);
    case NodeType.Grass_2:
      return NodeGrass2(row, column, z);
    default:
      throw Exception("Cannot build grid node type $type (${NodeType.getName(type)}");
  }
}

