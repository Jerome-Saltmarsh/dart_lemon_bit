



import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';

import 'atlas_src_x.dart';
import 'render_constants.dart';
import 'render_standard_node.dart';


void renderNodeBauHaus({
  required int orientation,
  required double dstX,
  required double dstY,
  required int color,
}){
  switch (orientation){
    case NodeOrientation.Solid:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: 0,
        color: color,
      );
      break;
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex1,
        color: color,
      );
      break;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex2,
        color: color,
      );
      break;
    case NodeOrientation.Half_South:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex1,
        color: color,
      );
      break;
    case NodeOrientation.Half_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex2,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Top:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex3,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Right:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex4,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Bottom:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex5,
        color: color,
      );
      break;
    case NodeOrientation.Corner_Left:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid,
        srcY: srcYIndex6,
        color: color,
      );
      break;
    case NodeOrientation.Slope_North:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 73.0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_South:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 146.0,
        color: color,
      );
      break;
    case NodeOrientation.Slope_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 73.0 * 3,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_North_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 292,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_South_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 365,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_South_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 438,
        color: color,
      );
      break;
    case NodeOrientation.Slope_Inner_North_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 511,
        color: color,
      );
      break;
  }
}