import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/queries/get_grid_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void actionGridSetBlock(int z, int row, int column, int type){
  if (type == GridNodeType.Boundary) return;
  final current = gridGetType(z, row, column);
  if (current == GridNodeType.Boundary) return;
  if (current == type) return;
  sendClientRequestSetBlock(row, column, z, type);
}