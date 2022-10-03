
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src.dart';

import 'render_constants.dart';
import 'render_node.dart';

void renderNodePlain({
  required int orientation,
  required double dstX,
  required double dstY,
  required int color,
}){
  switch (orientation){
    case NodeOrientation.Solid:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex1,
        color: color,
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex2,
        color: color,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex1,
        color: color,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex2,
        color: color,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex6,
        color: color,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex5,
        color: color,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex4,
        color: color,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Plain_Solid,
        srcY: srcYIndex3,
        color: color,
      );
  }
}