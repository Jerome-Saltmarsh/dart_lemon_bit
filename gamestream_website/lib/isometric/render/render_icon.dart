import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

void renderIconWood(Vector2 position) {
  render(
    dstX: position.x,
    dstY: position.y,
    srcY: 0,
    srcX: 6189,
    srcWidth: 26,
    srcHeight: 37,
    anchorY: 0.66,
  );
}

void renderIconStone(Vector2 position) {
  render(
    dstX: position.x,
    dstY: position.y,
    srcX: 6216,
    srcY: 0,
    srcWidth: 26,
    srcHeight: 36,
    anchorY: 0.66,
  );
}

void renderIconCoin(Vector2 position) {
  // engine.renderCustomV2(
  //   dst: position,
  //   srcX: 6245,
  //   srcWidth: 25,
  //   srcHeight: 32,
  //   anchorY: 0.66,
  // );
}

void renderIconGold(Vector2 position) {
  // engine.renderCustomV2(
  //   dst: position,
  //   srcX: 6273,
  //   srcWidth: 26,
  //   srcHeight: 32,
  //   anchorY: 0.66,
  // );
}

void renderIconExperience(Vector2 position) {
  // engine.renderCustomV2(
  //   dst: position,
  //   srcX: 6304,
  //   srcWidth: 17,
  //   srcHeight: 26,
  //   anchorY: 0.66,
  // );
}