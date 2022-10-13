
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';

import 'render_standard_node.dart';

void renderNodeWood({
  required int orientation,
  required double dstX,
  required double dstY,
  required int color,
}){
  switch(orientation) {
    case NodeOrientation.Solid:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Solid,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Slope_North,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Slope_East,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Slope_South,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Slope_West,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Wood_Half_North,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Wood_Half_East,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Half_South,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Half_West,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Corner_Top,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Corner_Right,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Corner_Bottom,
        srcY: 0,
        color: color,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Wood_Corner_Left,
        srcY: 0,
        color: color,
      );
  }

}