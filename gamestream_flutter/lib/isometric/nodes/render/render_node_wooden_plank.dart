
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';

import 'render_constants.dart';
import 'render_node.dart';
import 'render_standard_node.dart';

void renderNodeWoodenPlank(){
  switch(renderNodeOrientation){
    case NodeOrientation.Solid:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: 0,
      );
      return;
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex2,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex1,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex2,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_West:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex1,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Corner_Top:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex3,
      );
      return;
    case NodeOrientation.Corner_Right:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex4,
      );
      return;
    case NodeOrientation.Corner_Bottom:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex5,
      );
      return;
    case NodeOrientation.Corner_Left:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Wooden_Plank,
        srcY: srcYIndex6,
      );
      return;
  }

}