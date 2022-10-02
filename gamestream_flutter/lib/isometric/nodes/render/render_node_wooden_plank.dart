
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src.dart';

import 'render_constants.dart';
import 'render_node.dart';

void renderNodeWoodenPlank({
  required int orientation,
  required double dstX,
  required double dstY,
  required int color,
}){
  switch(orientation){
    case NodeOrientation.Solid:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_North:
      return renderStandardNode(
        dstX: dstX - 17,
        dstY: dstY - 17,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex2,
        color: color,
      );
    case NodeOrientation.Half_East:
      return renderStandardNode(
        dstX: dstX + 17,
        dstY: dstY - 17,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex1,
        color: color,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex2,
        color: color,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex1,
        color: color,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex3,
        color: color,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex4,
        color: color,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex5,
        color: color,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Wooden_Plank,
        srcY: srcYIndex6,
        color: color,
      );
  }

}