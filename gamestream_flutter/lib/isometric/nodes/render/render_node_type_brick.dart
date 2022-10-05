import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';

import 'render_standard_node.dart';

void renderNodeTypeBrick({
  required double x,
  required double y,
  required int orientation,
  required int shade,
}) {
  switch (orientation) {
    case NodeOrientation.Solid:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Slope_North,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Slope_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Slope_South,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Slope_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_North:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Half_North,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Half_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Half_South,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Half_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Corner_Top,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Corner_Right,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Corner_Bottom,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Brick_Corner_Left,
        srcY: spriteHeight * shade,
      );
    default:
      throw Exception("renderNodeTypeBrick(orientation: ${NodeOrientation.getName(orientation)}");
  }
}
