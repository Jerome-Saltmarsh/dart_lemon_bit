
import 'package:gamestream_flutter/library.dart';


void renderNodeTorch(){
  if (!GameState.torchesIgnited.value) {
    Engine.renderSprite(
      image: GameImages.nodes,
      srcX: AtlasNode.X_Torch,
      srcY: AtlasNode.Y_Torch,
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
    );
    return;
  }
  if (renderNodeWind == Wind.Calm){
    Engine.renderSprite(
      image: GameImages.nodes,
      srcX: AtlasNode.X_Torch,
      srcY: AtlasNode.Y_Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
    );
    return;
  }
  Engine.renderSprite(
    image: GameImages.nodes,
    srcX: AtlasNode.X_Torch_Windy,
    srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
    srcWidth: AtlasNode.Width_Torch,
    srcHeight: AtlasNode.Height_Torch,
    dstX: GameRender.currentNodeDstX,
    dstY: GameRender.currentNodeDstY,
  );
  return;
}