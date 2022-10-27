

import 'package:gamestream_flutter/library.dart';

void renderNodeWindow(){
  switch (renderNodeOrientation) {
    case NodeOrientation.Half_North:
      RenderNode.renderStandardNodeHalfNorth(
        srcX: AtlasNode.Window_South_X,
        srcY: AtlasNode.Window_South_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      RenderNode.renderStandardNodeHalfEast(
        srcX: AtlasNode.Node_Window_West_X,
        srcY: AtlasNode.Node_Window_West_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Window_South_X,
        srcY: AtlasNode.Window_South_Y,
      );
      return;
    case NodeOrientation.Half_West:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Window_West_X,
        srcY: AtlasNode.Node_Window_West_Y,
      );
      return;
  }
}