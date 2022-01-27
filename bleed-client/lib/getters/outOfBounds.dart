
import 'package:bleed_client/modules/modules.dart';

bool outOfBounds(int row, int column){
  if (row < 0) return true;
  if (column < 0) return true;
  if (row >= modules.isometric.state.totalRows) return true;
  if (column >= modules.isometric.state.totalColumns) return true;
  return false;
}