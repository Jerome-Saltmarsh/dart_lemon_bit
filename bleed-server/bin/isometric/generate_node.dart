
import '../classes/node.dart';
import '../common/node_type.dart';

Node generateNode(int type){
  if (type == NodeType.Empty)
    return Node.empty;

  if (NodeType.isOriented(type))
    return NodeOriented(
      orientation: NodeType.getDefaultOrientation(type),
      type: type,
    );

  switch (type) {
    case NodeType.Boundary:
      return Node.boundary;
    case NodeType.Water:
      return Node.water;
    case NodeType.Water_Flowing:
      return Node.waterFlowing;
    case NodeType.Grass_Flowers:
      return Node.grassFlowers;
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
    case NodeType.Brick_Top:
      return NodeBrickTop();
    case NodeType.Soil:
      return Node.soil;
    case NodeType.Roof_Hay_North:
      return NodeRoofHayNorth();
    case NodeType.Roof_Hay_South:
      return NodeRoofHaySouth();
    case NodeType.Stone:
      return Node.stone;
    case NodeType.Rain_Landing:
      return Node.empty;
    case NodeType.Rain_Falling:
      return Node.empty;
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
    case NodeType.Respawning:
      return NodeRespawning();
    case NodeType.Spawn:
      return NodeSpawn();
    default:
      print("Warning: Cannot generate node for type $type (${NodeType.getName(type)})");
      return Node.empty;
  }
}