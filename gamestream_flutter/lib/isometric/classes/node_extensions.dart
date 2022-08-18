

import 'package:bleed_common/node_type.dart';

import 'node.dart';

extension NodeExtensions on Node {

  bool get isGrass => this.type == NodeType.Grass;
  bool get isGrassLong => this.type == NodeType.Grass_Long;
  bool get isGrassSlopeNorth => this.type == NodeType.Grass_Slope_North;
  bool get isGrassSlopeEast => this.type == NodeType.Grass_Slope_East;
  bool get isGrassSlopeSouth => this.type == NodeType.Grass_Slope_South;
  bool get isGrassSlopeWest => this.type == NodeType.Grass_Slope_West;
}