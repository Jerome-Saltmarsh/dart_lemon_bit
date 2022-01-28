
import 'package:bleed_client/modules/modules.dart';

final _state = modules.isometric.state;

bool outOfBounds(int row, int column){
  if (row < 0) return true;
  if (column < 0) return true;
  if (row >= _state.totalRowsInt) return true;
  if (column >= _state.totalColumnsInt) return true;
  return false;
}