
import 'dart:math';

import 'package:amulet_client/atlases/atlas_nodes.dart';
import 'package:amulet_client/functions/get_render.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/amulet_colors.dart';
import 'package:amulet_client/isometric/ui/isometric_colors.dart';
import 'package:amulet_client/classes/character.dart';
import 'package:amulet_client/classes/position.dart';
import 'package:flutter/material.dart';
import 'package:amulet_client/components/isometric_component.dart';
import 'package:amulet_client/isometric/ui/isometric_constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_sprite/lib.dart';

import 'render/functions/merge_32_bit_colors.dart';

class IsometricRender with IsometricComponent {

  var renderAimTargetName = false;
  var drawCanvasEnabled = true;
  var _initialized = false;

  late final List<Sprite> _flames ;

  @override
  void onComponentReady() {
    _initialized = true;
    _flames = [
      images.flame0,
      images.flame1,
      images.flame2,
    ];
  }

  void modulate({
    required Sprite sprite,
    required int frame,
    required int color1,
    required int color2,
    required double scale,
    required double dstX,
    required double dstY,
    double anchorX = 0.5,
    double anchorY = 0.5,
  }){
    final engine = this.engine;
    engine.setBlendModeModulate();
    this.sprite(
      sprite: sprite,
      frame: frame,
      color: color1,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
    this.sprite(
      sprite: sprite,
      frame: frame,
      color: color2,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
    engine.setBlendModeDstATop();
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
    // TODO Optimize
    if (sprite.src.isEmpty)
      return;

    final engine = this.engine;
    engine.bufferImage = sprite.image;
    final spriteSrc = sprite.src;
    final spriteDst = sprite.dst;
    final f = frame * 4;
    final srcLeft = spriteSrc[f + 0];
    final srcTop = spriteSrc[f + 1];
    engine.render(
        color: color,
        srcLeft: spriteDst[f + 0],
        srcTop: spriteDst[f + 1],
        srcRight: spriteDst[f + 2],
        srcBottom: spriteDst[f + 3],
        scale: scale,
        rotation: 0,
        dstX: dstX - (sprite.srcWidth * anchorX * scale) + (srcLeft * scale),
        dstY: dstY - (sprite.srcHeight * anchorY * scale) + (srcTop * scale),
    );
  }

  void drawCanvas(Canvas canvas, Size size) {

    if (!_initialized){
      return;
    }

    if (!drawCanvasEnabled){
      return;
    }

    if (scene.totalNodes <= 0){
      return;
    }

    camera.update();
    compositor.render3D();
    renderEditMode();
    renderMouseTargetName();

    if (options.renderCameraTargets){
      renderCameraTargets();
    }

    debugger.drawCanvas();
    options.amulet.drawCanvas(canvas, size);
    options.rendersSinceUpdate.value++;
  }

  void renderCameraTargets() {

    final cameraTarget = camera.target;
    if (cameraTarget != null){
      engine.color = Colors.blue;
      render.circleOutlineAtPosition(
        position: cameraTarget,
        radius: 16,
      );
    }

    // if (options.playMode){
    //   if (amulet.cameraTargetSet.value){
    //     engine.color = Colors.red;
    //       render.circleOutlineAtPosition(
    //          position: amulet.cameraTarget,
    //          radius: 16,
    //       );
    //   }
    // }
  }

  void renderPlayerHeightMap() {
    textPosition(player.position, scene.getHeightMapHeightAt(player.nodeIndex), offsetY: -20);
  }

  // void highlightAimTargetEnemy() {
  //   if (player.aimTargetAction.value == TargetAction.Attack){
  //     // player.aimTargetPosition
  //     final position = player.aimTargetPosition;
  //     final x = position.x;
  //     final y = position.y;
  //     final z = position.z;
  //     for (final character in scene.characters){
  //       if (character.x != x)
  //         continue;
  //       if (character.y != y)
  //         continue;
  //       if (character.z != z)
  //         continue;
  //
  //       // character.color = 0;
  //       break;
  //     }
  //   }
  // }

  void drawForeground(Canvas canvas, Size size){

    if (!server.connected){
      return;
    }

    // renderCursor(canvas);
    renderPlayerAimTargetNameText();

    // if (io.inputModeTouch) {
    //   io.touchController.drawCanvas(canvas);
    // }

    // amulet.renderForeground(canvas, size);
  }

  void textIndex(dynamic text, int index) =>
      textZRC(
        text,
        scene.getIndexZ(index),
        scene.getRow(index),
        scene.getColumn(index),
      );

  void textZRC(dynamic text, int z, int row, int column) =>
      textXYZ(
        x: (row * Node_Size) + Node_Size_Half,
        y: (column * Node_Size) + Node_Size_Half,
        z: (z * Node_Height) + Node_Height_Half,
        text: text,
      );

  void textPosition(Position v3, dynamic text, {double offsetX = 0, double offsetY = 0}){
    renderText(
      value: text.toString(),
      x: v3.renderX + offsetX,
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
        x: getRenderX(x, y),
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

  void wireFrameWhite(int index) {
    final row = scene.getRow(index);
    final column = scene.getColumn(index);
    final z = scene.getIndexZ(index);
    engine.renderSprite(
      image: images.atlas_nodes,
      dstX: getRenderXOfRowAndColumn(row, column),
      dstY: getRenderYOfRowColumnZ(row, column, z),
      srcX: 96,
      srcY: 1640,
      srcWidth: 48,
      srcHeight: 72,
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
      dstX: getRenderX(x, y),
      dstY: getRenderY(x, y, z),
    );
  }

  void renderHealthBarCharacter(Character character) =>
      renderHealthBarPosition(
        position: character,
        percentage: character.health,
        color: character.colorDiffuse,
      );

  void renderMagicBarCharacter(Character character) =>
      renderMagicBarPosition(
        position: character,
        percentage: character.magicPercentage,
        color: character.colorDiffuse,
      );

  void renderHealthBarPosition({
    required Position position,
    required double percentage,
    int color = 1,
  }) =>
      renderHealthBar(
        dstX: position.renderX - 16,
        dstY: position.renderY - 55,
        percentage: percentage,
        color: color,
      );

  void renderMagicBarPosition({
    required Position position,
    required double percentage,
    int color = 1,
  }) =>
      renderMagicBar(
        dstX: position.renderX - 16,
        dstY: position.renderY - 55 + 3,
        percentage: percentage,
        color: color,
      );

  void renderHealthBar({
    required double dstX,
    required double dstY,
    required double percentage,
    int color = 1,
  }) {
    renderBar(
        dstX: dstX,
        dstY: dstY,
        percentage: percentage,
        color1: AmuletColors.Health.value,
        color2: color,
    );
  }

  void renderBar({
    required double dstX,
    required double dstY,
    required double percentage,
    required int color1,
    required int color2,
  }) {
    const srcX = 864.0;
    const srcY = 176.0;
    const srcWidth = 160.0;
    const srcHeight = 16.0;
    const interpolation = 0.6;
    final image = images.atlas_amulet_items;
    const scale = 0.2;


    engine.setBlendModeModulate();

    engine.renderSprite(
      image: image,
      dstX: dstX,
      dstY: dstY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      anchorX: 0.0,
      color: interpolateColors(color1, Palette.Black.value, interpolation),
      scale: scale,
    );

    engine.renderSprite(
      image: image,
      dstX: dstX,
      dstY: dstY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      anchorX: 0.0,
      color: interpolateColors(color2, Palette.Black.value, interpolation),
      scale: scale,
    );

    engine.renderSprite(
      image: image,
      dstX: dstX,
      dstY: dstY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth * percentage,
      srcHeight: srcHeight,
      anchorX: 0.0,
      color: color1,
      scale: scale,
    );

    engine.renderSprite(
      image: image,
      dstX: dstX,
      dstY: dstY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth * percentage,
      srcHeight: srcHeight,
      anchorX: 0.0,
      color: color2,
      scale: scale,
    );

    engine.setBlendModeDstATop();
  }

  void renderMagicBar({
    required double dstX,
    required double dstY,
    required double percentage,
    int color = 1,
  }) {
    renderBar(
        dstX: dstX,
        dstY: dstY,
        percentage: percentage,
        color1: AmuletColors.Magic.value,
        color2: color,
    );

    // const srcWidth = 51.0;
    // const srcHeight = 7.44;
    // final image = images.atlas_gameobjects;
    //
    // engine.renderSprite(
    //   image: image,
    //   dstX: dstX,
    //   dstY: dstY,
    //   srcX: 171,
    //   srcY: 56,
    //   srcWidth: srcWidth,
    //   srcHeight: srcHeight,
    //   anchorX: 0.0,
    //   color: color,
    // );
    // engine.renderSprite(
    //   image: image,
    //   dstX: dstX,
    //   dstY: dstY,
    //   srcX: 171,
    //   srcY: 48,
    //   srcWidth: srcWidth * percentage,
    //   srcHeight: srcHeight,
    //   anchorX: 0.0,
    //   color: color,
    // );
  }

  void editWireFrames() {
    for (var z = 0; z < editor.z; z++) {
      render.wireFrameBlue(z, editor.row, editor.column);
    }
    render.wireFrameRed(editor.row, editor.column, editor.z);
  }

  void renderText({
    required String value,
    required double x,
    required double y,
    double scale = 1.0,
  }){
    // const charWidth = 4.5;
    final characters = value.characters;
    var i = 0;
    for (final character in characters){
      renderChar(character, x + (i * 16), y);
      i++;
    }
  }

  void renderChar(String char, double x, double y){
    if (char.length != 1){
      throw Exception();
    }

    final number = int.tryParse(char);

    if (number != null){
      renderInt(number, x, y);
      return;
    }

    engine.renderSprite(
      image: images.atlas_text,
      srcX: 0,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 32,
      dstX: x,
      dstY: y,
    );
  }

  void renderInt(int value, double x, double y) =>
      engine.renderSprite(
      image: images.atlas_text,
      srcX: value * 16,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 32,
      dstX: x,
      dstY: y,
        scale: 0.3,
    );





  void shadowBelowPosition(Position position) =>
      shadowBelowXYZ(position.x, position.y, position.z);

  void shadowBelowXYZ(double x, double y, double z){
    if (z < Node_Height)
      return;

    final scene = this.scene;

    if (z >= scene.lengthZ)
      return;

    final nodeOrientations = scene.nodeOrientations;
    final nodeIndex = scene.getIndexXYZ(x, y, z);
    final area = scene.area;
    var nodeBelowIndex = nodeIndex - area;
    var nodeBelowOrientation = nodeOrientations[nodeBelowIndex];
    var height = z % Node_Height;
    while (nodeBelowOrientation == NodeOrientation.None) {
      nodeBelowIndex -= area;
      if (nodeBelowIndex < area){
        return;
      }
      height += Node_Height;
      nodeBelowOrientation = nodeOrientations[nodeBelowIndex];
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
        getRenderX(x1, y1),
        getRenderY(x1, y1, z1),
        getRenderX(x2, y2),
        getRenderY(x2, y2, z2),
      );

  void circleOutlineAtPosition({
    required Position position,
    required double radius,
    int sections = 12,
  }) => circleOutline(
    x: position.x,
    y: position.y,
    z: position.z,
    radius: radius,
    sections: sections,
  );

  void circleOutlineAtIndex({
    required int index,
    required double radius,
    int sections = 12,
  }) => circleOutline(
      x: scene.getIndexPositionX(index) + Node_Size_Quarter,
      y: scene.getIndexPositionY(index) + Node_Size_Quarter,
      z: scene.getIndexPositionZ(index),
      radius: radius,
    );

  void circleOutline({
      required double x,
      required double y,
      required double z,
      required double radius,
      int sections = 12,
  }
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
      x: getRenderX(x, y),
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

  // void renderCursor(Canvas canvas) {
  //
  //   if (!options.renderCursorEnable)
  //     return;
  //
  //   if (amulet.dragging.value != null)
  //     return;
  //
  //   final cooldown = player.weaponCooldown.value;
  //   final accuracy = player.accuracy.value;
  //   final distance = ((1.0 - cooldown) + (1.0 - accuracy)) * 10.0 + 5;
  //
  //   switch (options.cursorType) {
  //     case IsometricCursorType.CrossHair_White:
  //       canvasRenderCursorCrossHair(canvas, distance);
  //       break;
  //     case IsometricCursorType.Hand:
  //       canvasRenderCursorHand(canvas);
  //       return;
  //     case IsometricCursorType.Talk:
  //       canvasRenderCursorTalk(canvas);
  //       return;
  //     case IsometricCursorType.CrossHair_Red:
  //       canvasRenderCursorCrossHairRed(canvas, distance);
  //       break;
  //   }
  // }

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
    if (options.playing) return;
    if (editor.gameObject.value != null){
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

    if (!renderAimTargetName)
      return;


    if (player.aimTargetName.value.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      player.aimTargetName.value,
      engine.worldToScreenX(player.aimTargetPosition.renderX),
      engine.worldToScreenY(player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void projectShadow(Position position, {double scale = 1}){
    final scene = this.scene;
    if (!scene.inBoundsPosition(position)) return;

    final z = scene.getProjectionZ(position);
    if (z < 0) return;
    if (z > position.z)
      return;

    particles.spawnParticle(
      particleType: ParticleType.Shadow,
      x: position.x,
      y: position.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
      // frictionAir: 1.0,
      scale: scale,
    );
  }


  void flame({
    required double dstX,
    required double dstY,
    required int wind,
    double scale = 1.0,
    int seed = 0,
  }){
    final sprite = _flames[wind];
    final frame = sprite.getFrame(
        row: 0,
        column: seed + animation.frameRate2,
        mode: AnimationMode.loop,
    );
    render.sprite(
      sprite: sprite,
      frame: frame,
      color: 0,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
    );
  }

  void lineBetweenIndexes(int indexSrc, int indexTgt) {
    final scene = this.scene;
    line(
        scene.getIndexPositionX(indexSrc),
        scene.getIndexPositionY(indexSrc),
        scene.getIndexPositionZ(indexSrc) + 16,
        scene.getIndexPositionX(indexTgt),
        scene.getIndexPositionY(indexTgt),
        scene.getIndexPositionZ(indexTgt) + 16,
    );
  }

  void renderSpriteAutoIndexed({
    required Sprite sprite,
    required double dstX,
    required double dstY,
    required int index,
    double scale = 1.0,
    double anchorY = 0.5,
  }) {
    final scene = this.scene;
    render.renderSpriteAuto(
      sprite: sprite,
      dstX: dstX,
      dstY: dstY,
      colorNorth: scene.colorNorth(index),
      colorEast: scene.colorEast(index),
      colorSouth: scene.colorSouth(index),
      colorWest: scene.colorWest(index),
      anchorY: anchorY,
      scale: scale,
    );
  }

  void renderSpriteAutoIndexedNESW({
    required Sprite sprite,
    required double dstX,
    required double dstY,
    required int index,
    double scale = 1.0,
    double anchorY = 0.5,
  }) {
    final scene = this.scene;
    render.renderSpriteAutoNESW(
      sprite: sprite,
      dstX: dstX,
      dstY: dstY,
      colorNorth: scene.colorNorth(index),
      colorEast: scene.colorEast(index),
      colorSouth: scene.colorSouth(index),
      colorWest: scene.colorWest(index),
      anchorY: anchorY,
      scale: scale,
    );
  }

  /// renders a sprite composed of four frames
  /// flat, shadow, south, west
  void renderSpriteAuto({
    required Sprite sprite,
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    double scale = 1.0,
    double anchorY = 0.5,
  }) {

    final ambientRatio = 1.0 - (scene.ambientAlpha / 255);

    final colorNW = merge32BitColors(colorNorth, colorWest);
    final colorSE = merge32BitColors(colorSouth, colorEast);
    final colorFlat = merge32BitColors(colorNW, colorSE);
    final adjustedSE = interpolateColors(colorSE, scene.ambientColorNight, ambientRatio);

    // shadow
    render.sprite(
      sprite: sprite,
      frame: 1,
      color: colorFlat,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: sprite,
      frame: 0,
      color: colorFlat,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: sprite,
      frame: 2,
      color: adjustedSE,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: sprite,
      frame: 3,
      color: colorNW,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
  }

  void renderSpriteAutoNESW({
    required Sprite sprite,
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    double scale = 1.0,
    double anchorY = 0.5,
  }) {
    // final ambientRatio = 1.0 - (scene.ambientAlpha / 255);
    final colorNW = merge32BitColors(colorNorth, colorWest);
    final colorSE = merge32BitColors(colorSouth, colorEast);
    final colorFlat = merge32BitColors(colorNW, colorSE);
    // final adjustedSE = interpolateColors(colorSE, scene.ambientColorNight, ambientRatio);

    // shadow
    render.sprite(
      sprite: sprite,
      frame: 2,
      color: colorFlat,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    // north
    render.sprite(
      sprite: sprite,
      frame: 1,
      color: colorNorth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    // east
    render.sprite(
      sprite: sprite,
      frame: 0,
      color: colorEast,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    // south
    render.sprite(
      sprite: sprite,
      frame: 3,
      color: colorSE,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    // west
    render.sprite(
      sprite: sprite,
      frame: 4,
      color: colorNW,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );


  }


}