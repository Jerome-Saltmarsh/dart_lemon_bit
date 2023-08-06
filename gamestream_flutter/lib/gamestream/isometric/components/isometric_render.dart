
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/library.dart';

import '../classes/src.dart';
import 'isometric_images.dart';

class IsometricRender with IsometricComponent {

  late final Float32List bufferSrc;
  late final Float32List bufferDst;
  late final Int32List bufferClr;

  @override
  Future onComponentInit(sharedPreferences) async {
    engine.onDrawCanvas = drawCanvas;
    engine.onDrawForeground = drawForeground;
  }

  @override
  void onComponentReady() {
    bufferClr = engine.bufferClr;
    bufferDst = engine.bufferDst;
    bufferSrc = engine.bufferSrc;
  }

  void sprite({
    required Sprite sprite,
    required int frame,
    required int color,
    required double scale,
    required double dstX,
    required double dstY,
    double anchorX = 0.5,
    double anchorY = 0.5,
  }){
    engine.bufferImage = sprite.image;
    final bufferIndex = engine.bufferIndex;
    final values = sprite.values;
    final fStart = bufferIndex << 2;
    var f = fStart;
    var j = frame * 6; // each frame consumes for indexes



    bufferClr[bufferIndex] = color;
    bufferSrc[f++] = values[j++];
    bufferSrc[f++] = values[j++];
    bufferSrc[f++] = values[j++];
    bufferSrc[f++] = values[j++];
    f = fStart;
    bufferDst[f++] = scale;
    bufferDst[f++] = 0; // rotation


    final spriteDstX = values[j++];
    final spriteDstY = values[j++];

    final a = -(sprite.width * anchorX * scale) + (spriteDstX * 0.5);
    final b = -(sprite.height * 0.25 * scale) + (spriteDstY * 0.75);

    // final x = spriteDstX * anchorX * scale;
    // final y = spriteDstY * anchorY * scale;

    bufferDst[f++] = dstX - a;
    bufferDst[f++] = dstY - b;
    engine.incrementBufferIndex();
  }

  void drawCanvas(Canvas canvas, Size size) {

    if (options.gameType.value == GameType.Website) {
      images.cacheImages();
      return;
    }

    camera.update();
    particles.onComponentUpdate();
    compositor.render3D();
    renderEditMode();
    renderMouseTargetName();
    debug.drawCanvas();
    options.game.value.drawCanvas(canvas, size);
    options.rendersSinceUpdate.value++;

    final posX = 1000.0;
    final posY = 1000.0;
    final posZ = 25.0;

    sprite(
        sprite: images.spriteShirtBlueRunning,
        frame: animation.frame % 64,
        color: 0,
        scale: 1,
        dstX: getRenderX(posX, posY, posZ),
        dstY: getRenderY(posX, posY, posZ),
    );
  }

  void drawForeground(Canvas canvas, Size size){

    if (!network.websocket.connected)
      return;

    renderCursor(canvas);
    renderPlayerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.drawCanvas(canvas);
    }

    options.game.value.renderForeground(canvas, size);
  }


  void textPosition(Position v3, dynamic text, {double offsetY = 0}){
    renderText(
      value: text.toString(),
      x: v3.renderX,
      y: v3.renderY + offsetY,
    );
  }

  void textXYZ({
    required double x,
    required double y,
    required double z,
    required dynamic text,
  }) =>
      renderText(
        value: text.toString(),
        x: getRenderX(x, y, z),
        y: getRenderY(x, y, z),
      );

  void wireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    engine.renderSprite(
      image: images.atlas_nodes,
      dstX: getRenderXOfRowAndColumn(row, column),
      dstY: getRenderYOfRowColumnZ(row, column,z),
      srcX: AtlasNodeX.Wireframe_Blue,
      srcY: AtlasNodeY.Wireframe_Blue,
      srcWidth: IsometricConstants.Sprite_Width,
      srcHeight: IsometricConstants.Sprite_Height,
      anchorY: IsometricConstants.Sprite_Anchor_Y,
    );
    return;
  }

  void wireFrameRed(int row, int column, int z) {
    engine.renderSprite(
      image: images.atlas_nodes,
      dstX: getRenderXOfRowAndColumn(row, column),
      dstY: getRenderYOfRowColumnZ(row, column,z),
      srcX: AtlasNodeX.Wireframe_Red,
      srcY: AtlasNodeY.Wireframe_Red,
      srcWidth: IsometricConstants.Sprite_Width,
      srcHeight: IsometricConstants.Sprite_Height,
      anchorY: IsometricConstants.Sprite_Anchor_Y,
    );
  }

  void circle32(double x, double y, double z){
    engine.renderSprite(
      image: images.atlas_gameobjects,
      srcX: 16,
      srcY: 48,
      srcWidth: 32,
      srcHeight: 32,
      dstX: getRenderX(x, y, z),
      dstY: getRenderY(x, y, z),
    );
  }

  void characterHealthBar(Character character) =>
      healthBarPosition(
        position: character,
        percentage: character.health,
        color: character.color,
      );

  void healthBarPosition({
    required Position position,
    required double percentage,
    int color = 1,
  }) => engine.renderSprite(
    image: images.atlas_gameobjects,
    dstX: position.renderX - 26,
    dstY: position.renderY - 45,
    srcX: 171,
    srcY: 16,
    srcWidth: 51.0 * percentage,
    srcHeight: 8,
    anchorX: 0.0,
    color: color,
  );

  void editWireFrames() {
    for (var z = 0; z < editor.z; z++) {
      render.wireFrameBlue(z, editor.row, editor.column);
    }
    render.wireFrameRed(editor.row, editor.column, editor.z);
  }

  void renderText({required String value, required double x, required double y}){
    const charWidth = 4.5;
    engine.writeText(value, x - charWidth * value.length, y);
  }


  void barBlue(double x, double y, double z, double percentage) {
    engine.renderSprite(
      image: images.atlas_gameobjects,
      dstX: getRenderX(x, y, z) - 26,
      dstY: getRenderY(x, y, z) - 55,
      srcX: 171,
      srcY: 48,
      srcWidth: 51.0 * percentage,
      srcHeight: 8,
      anchorX: 0.0,
      color: 1,
    );
  }

  void shadowBelowPosition(Position position) =>
      shadowBelowXYZ(position.x, position.y, position.z);

  void shadowBelowXYZ(double x, double y, double z){
    if (z < Node_Height)
      return;
    if (z >= scene.lengthZ)
      return;

    final nodeIndex = scene.getIndexXYZ(x, y, z);
    var nodeBelowIndex = nodeIndex - scene.area;
    var nodeBelowOrientation = scene.nodeOrientations[nodeBelowIndex];
    var height = z % Node_Height;
    while (nodeBelowOrientation == NodeOrientation.None) {
      nodeBelowIndex -= scene.area;
      if (nodeBelowIndex < scene.area){
        return;
      }
      height += Node_Height;
      nodeBelowOrientation = scene.nodeOrientations[nodeBelowIndex];
    }

    renderShadow(
      x,
      y,
      scene.getIndexPositionZ(nodeBelowIndex) + Node_Height_Half,
      scale: 1.0 / (height * 0.125),
    );
  }

  void renderShadow(double x, double y, double z, {double scale = 1}) =>
      engine.renderSprite(
        image: images.atlas_gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: min(scale, 1),
      );

  void line(double x1, double y1, double z1, double x2, double y2, double z2) =>
      engine.renderLine(
        getRenderX(x1, y1, z1),
        getRenderY(x1, y1, z1),
        getRenderX(x2, y2, z2),
        getRenderY(x2, y2, z2),
      );

  void circleOutlineAtPosition({
    required Position position,
    required double radius,
    int sections = 12,
  }) => circleOutline(
    position.x,
    position.y,
    position.z,
    radius,
    sections: sections,
  );

  void circleOutline(
      double x,
      double y,
      double z,
      double radius,
      {int sections = 12}
      ){
    if (radius <= 0) return;
    if (sections < 3) return;

    final anglePerSection = pi2 / sections;
    var lineX1 = adj(0, radius);
    var lineY1 = opp(0, radius);
    var lineX2 = lineX1;
    var lineY2 = lineY1;
    for (var i = 1; i <= sections; i++){
      final a = i * anglePerSection;
      lineX2 = adj(a, radius);
      lineY2 = opp(a, radius);
      line(
        x + lineX1,
        y + lineY1,
        z,
        x + lineX2,
        y + lineY2,
        z,
      );
      lineX1 = lineX2;
      lineY1 = lineY2;
    }
  }

  void circleFilled(double x, double y, double z, double radius) =>
    engine.renderCircleFilled(
      radius: radius,
      x: getRenderX(x, y, z),
      y: getRenderY(x, y, z),
    );

  void renderMouseTargetName() {
    if (!player.mouseTargetAllie.value) return;
    final mouseTargetName = player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    render.renderText(
        value: mouseTargetName,
        x: player.aimTargetPosition.renderX,
        y: player.aimTargetPosition.renderY - 55);
  }

  void starsPosition(Position v3) =>
      stars(v3.renderX, v3.renderY - 40);

  void stars(double x, double y) =>
      engine.renderSprite(
        image: images.sprite_stars,
        srcX: 125.0 * animation.frame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );

  void renderCursor(Canvas canvas) {

    if (!options.renderCursorEnable)
      return;

    final cooldown = player.weaponCooldown.value;
    final accuracy = player.accuracy.value;
    final distance = ((1.0 - cooldown) + (1.0 - accuracy)) * 10.0 + 5;

    switch (options.cursorType) {
      case IsometricCursorType.CrossHair_White:
        canvasRenderCursorCrossHair(canvas, distance);
        break;
      case IsometricCursorType.Hand:
        canvasRenderCursorHand(canvas);
        return;
      case IsometricCursorType.Talk:
        canvasRenderCursorTalk(canvas);
        return;
      case IsometricCursorType.CrossHair_Red:
        canvasRenderCursorCrossHairRed(canvas, distance);
        break;
    }
  }

  void canvasRenderCursorCrossHair(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range,
        anchorY: 1.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range,
        anchorY: 0.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY(),
        anchorX: 1.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY(),
        anchorX: 0.0
    );
  }


  void canvasRenderCursorHand(Canvas canvas){
    renderCanvas(
      canvas: canvas,
      image: images.atlas_icons,
      srcX: 0,
      srcY: 256,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorTalk(Canvas canvas){
    renderCanvas(
      canvas: canvas,
      image: images.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorCrossHairRed(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  void renderEditMode() {
    if (options.playMode) return;
    if (editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        radius: 30,
        x: editor.gameObject.value!.renderX,
        y: editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      render.circleOutlineAtPosition(position: editor.gameObject.value!, radius: 50);
      return;
    }

    render.editWireFrames();
    renderMouseWireFrame();
  }

  void renderMouseWireFrame() {
    io.mouseRaycast(render.wireFrameBlue);
  }

  void renderPlayerAimTargetNameText(){
    if (player.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (player.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      player.aimTargetName,
      engine.worldToScreenX(player.aimTargetPosition.renderX),
      engine.worldToScreenY(player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void projectShadow(Position v3){
    if (!scene.inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    particles.spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(Position vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex =  scene.getIndexXYZ(x, y, z);
      final nodeOrientation =  scene.nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= IsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }
}