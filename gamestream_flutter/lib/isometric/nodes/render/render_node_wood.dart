
import 'package:gamestream_flutter/library.dart';

void renderNodeWood(){
  switch (renderNodeOrientation) {
    case NodeOrientation.Solid:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Wood_Solid_X,
        srcY: AtlasNode.Node_Wood_Solid_Y,
      );
      return;
    case NodeOrientation.Slope_North:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Slope_North_X,
        srcY: AtlasNode.Node_Wood_Slope_North_Y,
      );
      return;
    case NodeOrientation.Slope_East:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Slope_East_X,
        srcY: AtlasNode.Node_Wood_Slope_East_Y,
      );
      return;
    case NodeOrientation.Slope_South:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Slope_South_X,
        srcY: AtlasNode.Node_Wood_Slope_South_Y,
      );
      return;
    case NodeOrientation.Slope_West:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Slope_West_X,
        srcY: AtlasNode.Node_Wood_Slope_West_Y,
      );
      return;
    case NodeOrientation.Half_North:
      RenderNode.renderStandardNodeHalfNorthOld(
        srcX: AtlasNode.Node_Wood_Half_South_X,
        srcY: AtlasNode.Node_Wood_Half_South_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_East:
      RenderNode.renderStandardNodeHalfEastOld(
        srcX: AtlasNode.Node_Wood_Half_West_X,
        srcY: AtlasNode.Node_Wood_Half_West_Y,
        color: renderNodeColor,
      );
      return;
    case NodeOrientation.Half_South:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Half_South_X,
        srcY: AtlasNode.Node_Wood_Half_South_Y,
      );
      return;
    case NodeOrientation.Half_West:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Half_West_X,
        srcY: AtlasNode.Node_Wood_Half_West_Y,
      );
      return;
    case NodeOrientation.Corner_Top:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Corner_Top_X,
        srcY: AtlasNode.Node_Wood_Corner_Top_Y,
      );
      return;
    case NodeOrientation.Corner_Right:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Corner_Right_X,
        srcY: AtlasNode.Node_Wood_Corner_Right_Y,
      );
      return;
    case NodeOrientation.Corner_Bottom:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Corner_Bottom_X,
        srcY: AtlasNode.Node_Wood_Corner_Bottom_Y,
      );
      return;
    case NodeOrientation.Corner_Left:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Node_Wood_Corner_Left_X,
        srcY: AtlasNode.Node_Wood_Corner_Left_Y,
      );
      return;
  }
}