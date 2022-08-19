

import 'package:bleed_common/node_type.dart';

import 'node.dart';

extension NodeExtensions on Node {

  bool get isGrass => this.type == NodeType.Grass_2;
  bool get isGrassLong => this.type == NodeType.Grass_Long;
}