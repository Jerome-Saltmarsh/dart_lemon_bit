import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_node.dart';

double mapNodeTypeToSrcX(int type) => {
  NodeType.Brick_2: AtlasNode.Brick_Solid,
  NodeType.Grass: AtlasNode.Grass,
  NodeType.Wood_2: AtlasNode.Wood_Solid_X,
  NodeType.Torch: AtlasNode.X_Torch,
  NodeType.Grass_Long: AtlasNode.Grass_Long,
  NodeType.Grass_Flowers: AtlasNode.Grass_Flowers,
  NodeType.Brick_Top: 0.0,
  NodeType.Fireplace: AtlasNode.Campfire_X,
  NodeType.Table: AtlasNode.Table_X,
  NodeType.Stone: AtlasNode.Stone_X,
  NodeType.Plain: AtlasNode.Plain_Solid_X,
  NodeType.Soil: AtlasNode.Soil_X,
  NodeType.Bau_Haus: AtlasNode.Bau_Haus_Solid_X,
  NodeType.Chimney: AtlasNode.Chimney_X,
  NodeType.Bed_Bottom: AtlasNode.Bed_Bottom_X,
  NodeType.Bed_Top: AtlasNode.Bed_Top_X,
  NodeType.Sunflower: AtlasNode.Sunflower_X,
  NodeType.Oven: AtlasNode.Oven_X,
  NodeType.Cottage_Roof: -1.0,
  NodeType.Tree_Bottom: AtlasNode.Tree_Bottom_X,
  NodeType.Tree_Top: AtlasNode.Tree_Top_X,
  NodeType.Wooden_Plank: AtlasNode.Wooden_Plank_Solid_X,
  NodeType.Bau_Haus_2: AtlasNode.Bau_Haus_Solid_X,
  NodeType.Boulder: AtlasNode.Boulder_X,
  NodeType.Spawn: AtlasNode.Spawn_X,
  NodeType.Empty: 0.0,
  NodeType.Water: AtlasNode.Water_X,
  NodeType.Spawn_Weapon: 0.0,
  NodeType.Spawn_Player: 0.0,
}[type] ?? 7055;

double mapNodeTypeToSrcY(int type) => {
  NodeType.Water: AtlasNode.Water_Y,
  NodeType.Torch: AtlasNode.Y_Torch,
  NodeType.Water_Flowing: 0.0,
  NodeType.Window: AtlasNode.Window_South_Y,
  NodeType.Spawn: AtlasNode.Spawn_Y,
  NodeType.Spawn_Weapon: 153.0,
  NodeType.Spawn_Player: 225.0,
}[type] ?? 0;

double mapNodeTypeToSrcWidth(int type) => {
  NodeType.Torch: AtlasNode.Width_Torch,
  NodeType.Tree_Bottom: AtlasNode.Width_Tree_Bottom,
  NodeType.Tree_Top: 62.0,
}[type] ?? 48;

double mapNodeTypeToSrcHeight(int type) => {

}[type] ?? 72;