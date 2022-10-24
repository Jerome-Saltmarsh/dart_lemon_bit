
import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/library.dart';


void renderNodeTorch(){
  if (!GameState.torchesIgnited.value) {
    Engine.renderSprite(
      image: GameImages.nodes,
      srcX: AtlasSrcX.Node_Torch_X,
      srcY: AtlasSrcX.Node_Torch_Y,
      srcWidth: AtlasSrcX.Node_Torch_Width,
      srcHeight: AtlasSrcX.Node_Torch_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
    );
    return;
  }
  if (renderNodeWind == Wind.Calm){
    Engine.renderSprite(
      image: GameImages.nodes,
      srcX: AtlasSrcX.Node_Torch_X,
      srcY: AtlasSrcX.Node_Torch_Y + AtlasSrcX.Node_Torch_Height + (((GameRender.currentNodeRow + (animationFrame)) % 6) * AtlasSrcX.Node_Torch_Height),
      srcWidth: AtlasSrcX.Node_Torch_Width,
      srcHeight: AtlasSrcX.Node_Torch_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
    );
    return;
  }
  Engine.renderSprite(
    image: GameImages.nodes,
    srcX: AtlasSrcX.Node_Torch_Windy_X,
    srcY: AtlasSrcX.Node_Torch_Windy_Y + AtlasSrcX.Node_Torch_Height + (((GameRender.currentNodeRow + (animationFrame)) % 6) * AtlasSrcX.Node_Torch_Height),
    srcWidth: AtlasSrcX.Node_Torch_Width,
    srcHeight: AtlasSrcX.Node_Torch_Height,
    dstX: GameRender.currentNodeDstX,
    dstY: GameRender.currentNodeDstY,
  );
  return;
}