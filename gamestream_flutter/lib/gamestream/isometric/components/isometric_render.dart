
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricRender {

  final Isometric isometric;

  IsometricRender(this.isometric);

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
    isometric.engine.renderSprite(
      image: isometric.images.atlas_nodes,
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
    isometric.engine.renderSprite(
      image: isometric.images.atlas_nodes,
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
    isometric.engine.renderSprite(
      image: isometric.images.atlas_gameobjects,
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
  }) => isometric.engine.renderSprite(
    image: isometric.images.atlas_gameobjects,
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
    for (var z = 0; z < isometric.editor.z; z++) {
      isometric.render.wireFrameBlue(z, isometric.editor.row, isometric.editor.column);
    }
    isometric.render.wireFrameRed(isometric.editor.row, isometric.editor.column, isometric.editor.z);
  }

  void renderText({required String value, required double x, required double y}){
    const charWidth = 4.5;
    isometric.engine.writeText(value, x - charWidth * value.length, y);
  }


  void barBlue(double x, double y, double z, double percentage) {
    isometric.engine.renderSprite(
      image: isometric.images.atlas_gameobjects,
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
    if (z < Node_Height) return;
    final scene = isometric.scene;
    if (z >= scene.lengthZ) return;
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

    isometric.renderShadow(
      x,
      y,
      isometric.scene.getIndexPositionZ(nodeBelowIndex) + Node_Height_Half,
      scale: 1.0 / (height * 0.125),
    );
  }

  void line(double x1, double y1, double z1, double x2, double y2, double z2) =>
      isometric.engine.renderLine(
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
    isometric.engine.renderCircleFilled(
      radius: radius,
      x: getRenderX(x, y, z),
      y: getRenderY(x, y, z),
    );
}