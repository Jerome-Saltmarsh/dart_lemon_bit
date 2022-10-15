
import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';

import 'render_standard_node.dart';

void renderNodeTorch(){
  if (!torchesIgnited.value) {
    renderAdvanced(
        srcX: AtlasSrcX.Node_Torch_X,
        srcY: AtlasSrcX.Node_Torch_Y,
        dstX: RenderEngine.currentNodeDstX,
        dstY: RenderEngine.currentNodeDstY,
        width: AtlasSrcX.Node_Torch_Width,
        height: AtlasSrcX.Node_Torch_Height,
    );
    return;
  }
  if (renderNodeWind == Wind.Calm){
    renderAdvanced(
      srcX: AtlasSrcX.Node_Torch_X,
      srcY: AtlasSrcX.Node_Torch_Y + AtlasSrcX.Node_Torch_Height + (((RenderEngine.currentNodeRow + (animationFrame)) % 6) * AtlasSrcX.Node_Torch_Height),
      dstX: RenderEngine.currentNodeDstX,
      dstY: RenderEngine.currentNodeDstY,
      width: AtlasSrcX.Node_Torch_Width,
      height: AtlasSrcX.Node_Torch_Height,
    );
    return;
  }
  renderAdvanced(
    srcX: AtlasSrcX.Node_Torch_Windy_X,
    srcY: AtlasSrcX.Node_Torch_Windy_Y + AtlasSrcX.Node_Torch_Height + (((RenderEngine.currentNodeRow + (animationFrame)) % 6) * AtlasSrcX.Node_Torch_Height),
    dstX: RenderEngine.currentNodeDstX,
    dstY: RenderEngine.currentNodeDstY,
    width: AtlasSrcX.Node_Torch_Width,
    height: AtlasSrcX.Node_Torch_Height,
  );
  return;
}