import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void actionGridSetBlock(int z, int row, int column, int type, int orientation){
  if (type == NodeType.Boundary) return;
  final current = gridNodeZRCType(z, row, column);
  if (current == NodeType.Boundary) return;
  if (current == type) return;
  sendClientRequestSetBlock(row, column, z, type, orientation);
}