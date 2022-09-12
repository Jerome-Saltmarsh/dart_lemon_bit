import 'package:bleed_common/node_type.dart';

double mapNodeTypeToSrcX(int type) => {
  NodeType.Brick_2: 11377.0,
  NodeType.Grass_2: 7158.0,
  NodeType.Wood_2: 7590.0,
  NodeType.Torch: 2086.0,
  NodeType.Grass_Long: 10118.0,
  NodeType.Grass_Flowers: 9782.0,
  NodeType.Brick_Top: 8621.0,
  NodeType.Fireplace: 6469.0,
  NodeType.Table: 7639.0,
  NodeType.Stone: 9831.0,
  NodeType.Plain: 10738.0,
  NodeType.Soil: 10176.0,
  NodeType.Bau_Haus: 10544.0,
  NodeType.Chimney: 10787.0,
  NodeType.Bed_Bottom: 10836.0,
  NodeType.Bed_Top: 10885.0,
  NodeType.Sunflower: 10934.0,
  NodeType.Oven: 10983.0,
  NodeType.Cottage_Roof: 11228.0,
  NodeType.Tree_Bottom: 1478.0,
  NodeType.Tree_Top: 1540.0,
  NodeType.Wooden_Plank: 7688.0,
  NodeType.Bau_Haus_2: 11712.0,
  NodeType.Boulder: 11773.0,
}[type] ?? 7055;

double mapNodeTypeToSrcY(int type) => {
  NodeType.Water: 73.0,
  NodeType.Torch: 64.0,
  NodeType.Water_Flowing: 145.0,
  NodeType.Window: 218.0,
}[type] ?? 0;

double mapNodeTypeToSrcWidth(int type) => {
  NodeType.Torch: 25.0,
  NodeType.Tree_Bottom: 62.0,
  NodeType.Tree_Top: 62.0,
}[type] ?? 48;

double mapNodeTypeToSrcHeight(int type) => {

}[type] ?? 72;