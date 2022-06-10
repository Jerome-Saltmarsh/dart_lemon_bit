import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:lemon_watch/watch.dart';

final edit = EditState();

class EditState {
  var row = 0;
  var column = 0;
  var z = 0;
  final type = Watch(GridNodeType.Bricks);
  final tab = Watch(EditTab.Tile);
}

enum EditTab {
  Tile,
  Object,
}