import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';

import 'render_standard_node.dart';

void renderNodeTypeBrick({
  required int shade,
}) {
  switch (GameState.nodesOrientation[GameRender.currentNodeIndex]) {
    case NodeOrientation.Solid:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick,
        srcY: GameConstants.spriteHeightPadded * shade,
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Slope_North,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Slope_East,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Slope_South,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Slope_West,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Brick_Half_North,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Brick_Half_East,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Half_South,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Half_West,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Corner_Top,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Corner_Right,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Corner_Bottom,
        srcY: GameConstants.spriteHeight * shade,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Brick_Corner_Left,
        srcY: GameConstants.spriteHeight * shade,
      );
    default:
      throw Exception("renderNodeTypeBrick(orientation: ${NodeOrientation.getName(GameState.nodesOrientation[GameRender.currentNodeIndex])}");
  }
}
