import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:lemon_engine/engine.dart';

void renderTreeAt(int z, int row, int column) {
  engine.renderCustom(
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * 24),
      srcX: 2049,
      srcY: 81.0 * gridLightDynamic[z][row][column],
      srcWidth: 64.0,
      srcHeight: 81.0);
}
