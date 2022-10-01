



import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/classes/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';

import 'atlas_src.dart';


void renderNodeBauHaus({
  required int orientation,
  required double dstX,
  required double dstY,
  required int color,
}){
  switch (orientation){
    case NodeOrientation.Solid:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: 0,
        color: color,
      );
      break;
    case NodeOrientation.Half_North:
      renderStandardNode(
        dstX: dstX - 17,
        dstY: dstY - 17,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex1,
        color: color,
      );
      break;
    case NodeOrientation.Half_East:
      renderStandardNode(
        dstX: dstX + 17,
        dstY: dstY - 17,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex2,
        color: color,
      );
      break;
    case NodeOrientation.Half_South:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex1,
        color: color,
      );
      break;
    case NodeOrientation.Half_West:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex2,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Top:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex3,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Right:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex4,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Bottom:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex5,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Left:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Solid,
        srcY: srcYIndex6,
        color: color,
      );
      break;
    case NodeOrientation.Slope_North:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_East:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 73.0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_South:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 146.0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_West:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 73.0 * 3,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_North_East:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 292,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_South_East:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 365,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_South_West:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 438,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_North_West:
      renderStandardNode(
        dstX: dstX,
        dstY: dstY,
        srcX: AtlasSrc.Node_Bau_Haus_Slope,
        srcY: 511,
        color: color,
      );
      break;
  }
}