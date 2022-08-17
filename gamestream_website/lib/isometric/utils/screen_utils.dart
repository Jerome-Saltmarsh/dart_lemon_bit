import 'package:lemon_engine/engine.dart';

double get screenCenterRenderX {
  // final x = (engine.screen.left + engine.screen.right) / 2;
  // final y = (engine.screen.top + engine.screen.bottom) / 2;
  // final row = convertWorldToRow(x, y, 0);
  // final column = convertWorldToColumn(x, y, 0);
  // return (row - column) * tileSizeHalf;
  return (engine.screen.left + engine.screen.right) / 2;
}
