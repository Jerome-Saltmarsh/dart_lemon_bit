import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';

import '../../library.dart';

/// @percentage is a double between 0 and 1
/// determines how full it is
void renderBarGreen(double x, double y, double z, double percentage) {
  Engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: GameConvert.getRenderX(x, y, z) - AtlasGameObjects.Bar_Green_Width_Half,
    dstY: GameConvert.getRenderY(x, y, z) - 45,
    srcX: 171,
    srcY: 16,
    srcWidth: 51.0 * percentage,
    srcHeight: 8,
    anchorX: 0.0,
    color: 1,
  );
}

void renderCharacterHealthBar(Character character){
  renderBarGreen(character.x, character.y, character.z, character.health);

  // Engine.renderSprite(
  //     image: Images.gameobjects,
  //     dstX: character.renderX - srcWidthHalf,
  //     dstY: character.renderY - marginY,
  //     srcX: srcX,
  //     srcY: character.allie ? 24 : 8,
  //     srcWidth: AtlasSrcGameObjects.Bar_Width,
  //     srcHeight: AtlasSrcGameObjects.Bar_Height,
  //     anchorX: 0,
  //     color: color,
  // );

  // Engine.renderBuffer(
  //     dstX: character.renderX - srcWidthHalf,
  //     dstY: character.renderY - marginY,
  //     srcX: srcX,
  //     srcY: character.allie ? 16 : 0,
  //     srcWidth: srcWidth * character.health,
  //     srcHeight: srcHeight,
  //     anchorX: 0,
  //     color: color,
  // );
}



void renderCharacterBarWeaponRounds({
  required double x,
  required double y,
  required double percentage,
}){
  const srcX = 2400.0;
  const srcWidth = 40.0;
  const srcHeight = 8.0;
  const marginY = 45;
  const srcWidthHalf = srcWidth * 0.5;

  Engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 32,
    srcWidth: srcWidth,
    srcHeight: srcHeight,
    anchorX: 0,
  );

  Engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 40,
    srcWidth: srcWidth * percentage,
    srcHeight: srcHeight,
    anchorX: 0,
    // color: color,
  );
}
