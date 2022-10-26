

import 'package:gamestream_flutter/library.dart';

import 'render_standard_node.dart';

void renderNodeWindow(){
  switch (renderNodeOrientation) {
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasNode.Window_South_X,
        srcY: AtlasNode.Window_South_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasNode.Node_Window_West_X,
        srcY: AtlasNode.Node_Window_West_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      renderStandardNodeShaded(
        srcX: AtlasNode.Window_South_X,
        srcY: AtlasNode.Window_South_Y,
      );
      return;
    case NodeOrientation.Half_West:
      renderStandardNodeShaded(
        srcX: AtlasNode.Node_Window_West_X,
        srcY: AtlasNode.Node_Window_West_Y,
      );
      return;
  }
}