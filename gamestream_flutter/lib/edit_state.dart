import 'package:bleed_common/grid_node_type.dart';
import 'package:lemon_watch/watch.dart';

final edit = EditState();

class EditState {
  var row = 0;
  var column = 0;
  var z = 0;
  var type = Watch(GridNodeType.Bricks);
}