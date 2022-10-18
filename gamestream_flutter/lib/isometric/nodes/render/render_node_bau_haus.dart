



import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/game_render.dart';

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
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_North_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_North_Y,
      );
      break;
    case NodeOrientation.Slope_East:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_East_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_East_Y,
      );
      break;
    case NodeOrientation.Slope_South:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_South_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_South_Y,
      );
      break;
    case NodeOrientation.Slope_West:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_West_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_West_Y,
      );
      break;
    case NodeOrientation.Slope_Inner_North_East:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_Inner_North_East_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_Inner_North_East_Y,
      );
      break;
    case NodeOrientation.Slope_Inner_South_East:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_Inner_South_East_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_Inner_South_East_Y,
      );
      break;
    case NodeOrientation.Slope_Inner_South_West:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_Inner_South_West_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_Inner_South_West_Y,
      );
      break;
    case NodeOrientation.Slope_Inner_North_West:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Bau_Haus_Slope_Inner_North_West_X,
        srcY: AtlasSrcX.Node_Bau_Haus_Slope_Inner_North_West_Y,
      );
      break;
  }
}