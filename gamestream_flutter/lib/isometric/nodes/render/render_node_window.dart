

import 'package:gamestream_flutter/library.dart';

void renderNodeWindow(){
  const srcX = 1508.0;
  switch (renderNodeOrientation) {
    case NodeOrientation.Half_North:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: 80 + GameConstants.Sprite_Height_Padded,
        offsetX: -8,
        offsetY: -8,
      );
      return;
    case NodeOrientation.Half_South:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: 80 + GameConstants.Sprite_Height_Padded,
        offsetX: 8,
        offsetY: 8,
      );
      return;
    case NodeOrientation.Half_East:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: 80,
        offsetX: 8,
        offsetY: -8,
      );
      return;
    case NodeOrientation.Half_West:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: 80,
        offsetX: -8,
        offsetY: 8,
      );
      return;
    default:
      throw Exception("render_node_window(${NodeOrientation.getName(renderNodeOrientation)})");
  }
}