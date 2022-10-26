
import 'package:gamestream_flutter/library.dart';

class RenderNode {
  static void renderNodeTorch(){
    if (!GameState.torchesIgnited.value) {
      Engine.renderSprite(
        image: GameImages.atlasNodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch,
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
      );
      return;
    }
    if (renderNodeWind == Wind.Calm){
      Engine.renderSprite(
        image: GameImages.atlasNodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
      );
      return;
    }
    Engine.renderSprite(
      image: GameImages.atlasNodes,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
    );
    return;
  }

  static void renderNodeWater() =>
    Engine.renderSprite(
      image: GameImages.atlasNodes,
      srcX: AtlasNodeX.Water,
      srcY: AtlasNodeY.Water + (((GameAnimation.animationFrameWater + ((GameRender.currentNodeRow + GameRender.currentNodeColumn) * 3)) % 10) * 72.0),
      srcWidth: GameConstants.spriteWidth,
      srcHeight: GameConstants.spriteHeight,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
      anchorY: 0.3334,
      color: renderNodeColor,
    );
}