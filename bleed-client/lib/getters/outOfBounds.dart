
import 'package:bleed_client/state/game.dart';

bool outOfBounds(int row, int column){
  if (row < 0) return true;
  if (column < 0) return true;
  if (row >= game.totalRows) return true;
  if (column >= game.totalColumns) return true;
  return false;
}