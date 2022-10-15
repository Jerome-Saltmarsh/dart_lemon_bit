

import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/render_engine.dart';

import 'render_standard_node.dart';

void renderNodeWindow(){
  switch (renderNodeOrientation) {
    case NodeOrientation.Half_North:
      renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Window_South_X,
        srcY: AtlasSrcX.Node_Window_South_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Window_West_X,
        srcY: AtlasSrcX.Node_Window_West_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Window_South_X,
        srcY: AtlasSrcX.Node_Window_South_Y,
      );
      return;
    case NodeOrientation.Half_West:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Window_West_X,
        srcY: AtlasSrcX.Node_Window_West_Y,
      );
      return;
  }
}