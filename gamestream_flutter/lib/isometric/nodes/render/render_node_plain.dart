
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/render_engine.dart';

import 'render_standard_node.dart';

void renderNodePlain(){
  switch (Game.nodesOrientation[RenderEngine.currentNodeIndex]){
    case NodeOrientation.Solid:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Solid,
        srcY: 0,
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
        color: colorShades[Game.nodesShade[RenderEngine.currentNodeIndex]],
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Plain_Half_Column_X,
        srcY: AtlasSrcX.Node_Plain_Half_Column_Y,
        color: colorShades[Game.nodesShade[RenderEngine.currentNodeIndex]],
      );
    case NodeOrientation.Half_South:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Half_West:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Corner_Top_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Top_Y,
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Corner_Right_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Right_Y,
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Corner_Bottom_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Bottom_Y,
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Plain_Corner_Left_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Left_Y,
      );
  }
}