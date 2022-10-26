
import 'package:gamestream_flutter/library.dart';

import 'render_standard_node.dart';

void renderNodePlain(){
  switch (GameState.nodesOrientation[GameRender.currentNodeIndex]){
    case NodeOrientation.Solid:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Plain_Solid_X,
        srcY: 0,
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
        color: GameState.colorShades[GameState.nodesShade[GameRender.currentNodeIndex]],
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasNode.Node_Plain_Half_Column_X,
        srcY: AtlasNode.Node_Plain_Half_Column_Y,
        color: GameState.colorShades[GameState.nodesShade[GameRender.currentNodeIndex]],
      );
    case NodeOrientation.Half_South:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Half_West:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Half_Row_X,
        srcY: AtlasNode.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Top_X,
        srcY: AtlasNode.Node_Plain_Corner_Top_Y,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Right_X,
        srcY: AtlasNode.Node_Plain_Corner_Right_Y,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Bottom_X,
        srcY: AtlasNode.Node_Plain_Corner_Bottom_Y,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNodeShaded(
        srcX: AtlasNode.Node_Plain_Corner_Left_X,
        srcY: AtlasNode.Node_Plain_Corner_Left_Y,
      );
  }
}