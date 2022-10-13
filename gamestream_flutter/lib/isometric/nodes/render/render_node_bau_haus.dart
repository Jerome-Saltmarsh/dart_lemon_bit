



import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';

import 'atlas_src_x.dart';
import 'render_standard_node.dart';


void renderNodeBauHaus() {
  switch (renderNodeOrientation) {
    case NodeOrientation.Solid:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Solid_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Solid_Y,
      );
      break;
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Bau_Haus_Half_South_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Half_South_Y,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Bau_Haus_Half_West_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Half_West_Y,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Half_South:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Half_South_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Half_South_Y,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Half_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Half_South_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Half_South_Y,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Corner_Top:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Corner_Top_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Corner_Top_Y,
      );
      break;
    case NodeOrientation.Corner_Right:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Corner_Right_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Corner_Right_Y,
      );
      break;
    case NodeOrientation.Corner_Bottom:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Corner_Bottom_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Corner_Bottom_Y,
      );
      break;
    case NodeOrientation.Corner_Left:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Corner_Left_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Corner_Left_Y,
      );
      break;
    case NodeOrientation.Slope_North:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 0,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 73.0,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_South:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 146.0,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 73.0 * 3,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_Inner_North_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 292,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_Inner_South_East:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 365,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_Inner_South_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 438,
        color: renderNodeColor,
      );
      break;
    case NodeOrientation.Slope_Inner_North_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope,
        srcY: 511,
        color: renderNodeColor,
      );
      break;
  }
}