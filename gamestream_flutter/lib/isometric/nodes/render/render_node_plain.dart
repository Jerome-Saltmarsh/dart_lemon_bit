
import 'package:gamestream_flutter/library.dart';

void renderNodePlain() {
  switch (GameRender.currentNodeOrientation) {
    case NodeOrientation.Solid:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNodeX.Plain_Solid,
        srcY: AtlasNodeY.Plain_Solid,
      );
    case NodeOrientation.Half_North:
      return RenderNode.renderStandardNodeHalfNorth(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
        color: GameRender.currentNodeColor,
      );
    case NodeOrientation.Half_East:
      return RenderNode.renderStandardNodeHalfEast(
        srcX: AtlasNode.Node_Plain_Half_Column_X,
        srcY: AtlasNode.Node_Plain_Half_Column_Y,
        color: GameRender.currentNodeColor,
      );
    case NodeOrientation.Half_South:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Half_West:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Corner_Top:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Top_X,
        srcY: AtlasNode.Node_Plain_Corner_Top_Y,
      );
    case NodeOrientation.Corner_Right:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Right_X,
        srcY: AtlasNode.Node_Plain_Corner_Right_Y,
      );
    case NodeOrientation.Corner_Bottom:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Bottom_X,
        srcY: AtlasNode.Node_Plain_Corner_Bottom_Y,
      );
    case NodeOrientation.Corner_Left:
      return RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Left_X,
        srcY: AtlasNode.Node_Plain_Corner_Left_Y,
      );
  }
}