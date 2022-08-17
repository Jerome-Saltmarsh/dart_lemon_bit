
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/render.dart';

void renderWireFrameBlue(
    int z,
    int row,
    int column,
    ) {
  return render(
    dstX: getTileWorldX(row, column),
    dstY: getTileWorldY(row, column) - (z * tileHeight),
    srcX: 6944,
    srcY: 0,
    srcWidth: 48,
    srcHeight: 72,
    anchorY: 0.3334,
  );
}

void renderWireFrameRed(int row, int column, int z) {
  return render(
    dstX: getTileWorldX(row, column),
    dstY: getTileWorldY(row, column) - (z * tileHeight),
    srcX: 6895,
    srcY: 0,
    srcWidth: 48,
    srcHeight: 72,
    anchorY: 0.3334,
  );
}
