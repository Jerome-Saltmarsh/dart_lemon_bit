
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';

import 'render_standard_node.dart';

void renderNodeWoodenPlank(){
  switch(renderNodeOrientation){
    case NodeOrientation.Solid:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Solid_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Solid_Y,
      );
      return;
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Wooden_Plank_Half_South_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Half_South_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Wooden_Plank_Half_West_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Half_West_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Half_South_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Half_South_Y,
      );
      return;
    case NodeOrientation.Half_West:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Half_West_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Half_West_Y,
      );
      return;
    case NodeOrientation.Corner_Top:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Corner_Top_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Corner_Top_Y,
      );
      return;
    case NodeOrientation.Corner_Right:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Corner_Right_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Corner_Right_Y,
      );
      return;
    case NodeOrientation.Corner_Bottom:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Corner_Bottom_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Corner_Bottom_Y,
      );
      return;
    case NodeOrientation.Corner_Left:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank_Corner_Left_X,
        srcY: AtlasSrcX.Node_Wooden_Plank_Corner_Left_Y,
      );
      return;
  }

}