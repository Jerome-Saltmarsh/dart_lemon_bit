

import 'package:bleed_common/grid_node_type.dart';

import 'node.dart';

extension NodeExtensions on Node {

  bool get isGrass => this.type == GridNodeType.Grass;
  bool get isGrassLong => this.type == GridNodeType.Grass_Long;
  bool get isGrassSlopeNorth => this.type == GridNodeType.Grass_Slope_North;
  bool get isGrassSlopeEast => this.type == GridNodeType.Grass_Slope_East;
  bool get isGrassSlopeSouth => this.type == GridNodeType.Grass_Slope_South;
  bool get isGrassSlopeWest => this.type == GridNodeType.Grass_Slope_West;
}