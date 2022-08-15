import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/nodes.dart';

Node generateNode(int z, int row, int column, int type){
  switch (type){
    case GridNodeType.Boundary:
      return Node.boundary;
    case GridNodeType.Empty:
      return Node.empty;
    case GridNodeType.Grass:
      return NodeGrass(row, column, z);
    case GridNodeType.Bricks:
      return NodeBricks(row, column, z);
    case GridNodeType.Roof_Hay_South:
      return NodeRoofHaySouth(row, column, z);
    case GridNodeType.Roof_Hay_North:
      return NodeRoofHayNorth(row, column, z);
    case GridNodeType.Fireplace:
      return NodeFireplace(row, column, z);
    case GridNodeType.Tree_Top:
      return NodeTreeTop(row, column, z);
    case GridNodeType.Tree_Bottom:
      return NodeTreeBottom(row, column, z);
    case GridNodeType.Stone:
      return NodeStone(row, column, z);
    case GridNodeType.Torch:
      return NodeTorch(row, column, z);
    case GridNodeType.Water_Flowing:
      return NodeWaterFlowing(row, column, z);
    case GridNodeType.Water:
      return NodeWater(row, column, z);
    case GridNodeType.Wood_Corner_Right:
      return NodeWoodCornerRight(row, column, z);
    case GridNodeType.Wood_Corner_Top:
      return NodeWoodCornerTop(row, column, z);
    case GridNodeType.Wood_Corner_Left:
      return NodeWoodCornerLeft(row, column, z);
    case GridNodeType.Wood_Corner_Bottom:
      return NodeWoodCornerBottom(row, column, z);
    case GridNodeType.Soil:
      return NodeSoil(row, column, z);
    case GridNodeType.Grass_Long:
      return NodeGrassLong(row, column, z);
    case GridNodeType.Grass_Slope_South:
      return NodeGrassSlopeSouth(row, column, z);
    case GridNodeType.Grass_Slope_North:
      return NodeGrassSlopeNorth(row, column, z);
    case GridNodeType.Grass_Slope_East:
      return NodeGrassSlopeEast(row, column, z);
    case GridNodeType.Grass_Slope_West:
      return NodeGrassSlopeWest(row, column, z);
    case GridNodeType.Grass_Slope_Left:
      return NodeGrassSlopeLeft(row, column, z);
    case GridNodeType.Grass_Slope_Top:
      return NodeGrassSlopeTop(row, column, z);
    case GridNodeType.Grass_Slope_Right:
      return NodeGrassSlopeRight(row, column, z);
    case GridNodeType.Grass_Slope_Bottom:
      return NodeGrassSlopeBottom(row, column, z);
    case GridNodeType.Wood:
      return NodeWood(row, column, z);
    case GridNodeType.Rain_Landing:
      return NodeRainLanding(row, column, z);
    case GridNodeType.Rain_Falling:
      return NodeRainFalling(row, column, z);
    case GridNodeType.Stairs_North:
      return NodeStairsNorth(row, column, z);
    case GridNodeType.Stairs_East:
      return NodeStairsEast(row, column, z);
    case GridNodeType.Stairs_South:
      return NodeStairsSouth(row, column, z);
    case GridNodeType.Stairs_West:
      return NodeStairsWest(row, column, z);
    case GridNodeType.Wood_Half_Column_1:
      return NodeWoodHalfColumn1(row, column, z);
    case GridNodeType.Wood_Half_Column_2:
      return NodeWoodHalfColumn2(row, column, z);
    case GridNodeType.Wood_Half_Row_1:
      return NodeWoodHalfRow1(row, column, z);
    case GridNodeType.Wood_Half_Row_2:
      return NodeWoodHalfRow2(row, column, z);
    case GridNodeType.Brick_Top:
      return NodeBrickTop(row, column, z);
    case GridNodeType.Roof_Tile_North:
      return NodeTileNorth(row, column, z);
    case GridNodeType.Roof_Tile_South:
      return NodeTileSouth(row, column, z);
    case GridNodeType.Grass_Edge_Top:
      return NodeGrassEdgeTop(row, column, z);
    case GridNodeType.Grass_Edge_Right:
      return NodeGrassEdgeRight(row, column, z);
    case GridNodeType.Grass_Edge_Bottom:
      return NodeGrassEdgeBottom(row, column, z);
    case GridNodeType.Grass_Edge_Left:
      return NodeGrassEdgeLeft(row, column, z);
    case GridNodeType.Bau_Haus:
      return NodeBauHaus(row, column, z);
    case GridNodeType.Bau_Haus_Roof_North:
      return NodeBauHausRoofNorth(row, column, z);
    case GridNodeType.Bau_Haus_Roof_South:
      return NodeBauHausRoofSouth(row, column, z);
    case GridNodeType.Bau_Haus_Window:
      return NodeBauHausWindow(row, column, z);
    case GridNodeType.Bau_Haus_Plain:
      return NodeBauHausPlain(row, column, z);
    case GridNodeType.Chimney:
      return NodeBauHausChimney(row, column, z);
    case GridNodeType.Bed_Top:
      return NodeBedTop(row, column, z);
    case GridNodeType.Bed_Bottom:
      return NodeBedBottom(row, column, z);
    case GridNodeType.Table:
      return NodeTable(row, column, z);
    case GridNodeType.Sunflower:
      return NodeSunflower(row, column, z);
    case GridNodeType.Oven:
      return NodeOven(row, column, z);
    default:
      throw Exception("Cannot build grid node type $type (${GridNodeType.getName(type)}");
  }
}
