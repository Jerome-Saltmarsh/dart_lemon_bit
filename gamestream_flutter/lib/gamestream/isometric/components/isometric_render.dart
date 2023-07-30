
import 'package:gamestream_flutter/common/src/isometric/node_orientation.dart';
import 'package:gamestream_flutter/common/src/isometric/node_size.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';

class IsometricRender {

  final Isometric isometric;

  IsometricRender(this.isometric);



  void renderTextPosition(Position v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: v3.renderX,
      y: v3.renderY + offsetY,
    );
  }

  void renderTextXYZ({
    required double x,
    required double y,
    required double z,
    required dynamic text,
  }) =>
      renderText(
        text: text.toString(),
        x: getRenderX(x, y, z),
        y: getRenderY(x, y, z),
      );

  void renderWireFrameBlue(
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

  void renderWireFrameRed(int row, int column, int z) {
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

  void renderCircle32(double x, double y, double z){
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

  void renderCharacterHealthBar(Character character) =>
      renderHealthBarPosition(
        position: character,
        percentage: character.health,
        color: character.color,
      );

  void renderHealthBarPosition({
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

  void renderEditWireFrames() {
    for (var z = 0; z < isometric.editor.z; z++) {
      isometric.render.renderWireFrameBlue(z, isometric.editor.row, isometric.editor.column);
    }
    isometric.render.renderWireFrameRed(isometric.editor.row, isometric.editor.column, isometric.editor.z);
  }

  void renderText({required String text, required double x, required double y}){
    const charWidth = 4.5;
    isometric.engine.writeText(text, x - charWidth * text.length, y);
  }


  void renderBarBlue(double x, double y, double z, double percentage) {
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

  void renderShadowBelowPosition(Position position) =>
      renderShadowBelowXYZ(position.x, position.y, position.z);

  void renderShadowBelowXYZ(double x, double y, double z){
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
}