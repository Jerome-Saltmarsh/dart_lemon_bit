import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/nodes.dart';

Node generateNode(int z, int row, int column, int type){
  switch (type){
    case NodeType.Boundary:
      return Node.boundary;
    case NodeType.Empty:
      return Node.empty;
    case NodeType.Grass_Flowers:
      return NodeGrassFlowers(row, column, z);
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
    case NodeType.Soil:
      return NodeSoil(row, column, z);
    case NodeType.Grass_Long:
      return NodeGrassLong(row, column, z);
    case NodeType.Rain_Landing:
      return NodeRainLanding(row, column, z);
    case NodeType.Rain_Falling:
      return NodeRainFalling(row, column, z);
    case NodeType.Brick_Top:
      return NodeBrickTop(row, column, z);
    case NodeType.Roof_Tile_North:
      return NodeTileNorth(row, column, z);
    case NodeType.Roof_Tile_South:
      return NodeTileSouth(row, column, z);
    case NodeType.Bau_Haus:
      return NodeBauHaus(row, column, z);
    case NodeType.Bau_Haus_2:
      return NodeBauHaus(row, column, z);
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
    case NodeType.Brick_2:
      return NodeBricks2(row, column, z);
    case NodeType.Wood_2:
      return NodeWood2(row, column, z);
    case NodeType.Cottage_Roof:
      return NodeCottageRoof(row, column, z);
    case NodeType.Grass_2:
      return NodeGrass2(row, column, z);
    case NodeType.Plain:
      return NodePlain(row, column, z);
    case NodeType.Window:
      return NodeWindow(row, column, z);
    case NodeType.Wooden_Plank:
      return NodeWoodenPlank(row, column, z);
    default:
      throw Exception("Cannot build grid node type $type (${NodeType.getName(type)}");
  }
}

