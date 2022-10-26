import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_node.dart';

double mapNodeTypeToSrcY(int type) => {
  NodeType.Water: AtlasNode.Water_Y,
  NodeType.Torch: AtlasNode.Y_Torch,
  NodeType.Water_Flowing: 0.0,
  NodeType.Window: AtlasNode.Window_South_Y,
  NodeType.Spawn: AtlasNode.Spawn_Y,
  NodeType.Spawn_Weapon: AtlasNodeY.Spawn_Weapon,
  NodeType.Spawn_Player: AtlasNodeY.Spawn_Player,
  NodeType.Soil: AtlasNodeY.Soil,
  NodeType.Wood_2: AtlasNodeY.Wood,
}[type] ?? 0;

double mapNodeTypeToSrcWidth(int type) => {
  NodeType.Torch: AtlasNode.Width_Torch,
  NodeType.Tree_Bottom: AtlasNode.Width_Tree_Bottom,
  NodeType.Tree_Top: 62.0,
}[type] ?? 48;

double mapNodeTypeToSrcHeight(int type) => {

}[type] ?? 72;