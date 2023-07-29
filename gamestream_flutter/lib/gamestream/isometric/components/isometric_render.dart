
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/isometric_constants.dart';
import 'render/renderer_characters.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_particles.dart';
import 'render/renderer_projectiles.dart';

class IsometricRender {

  final Isometric isometric;

  var totalRemaining = 0;
  var totalIndex = 0;

  late final RendererNodes rendererNodes;
  late final RendererProjectiles rendererProjectiles;
  late final RendererCharacters rendererCharacters;
  late final RendererParticles rendererParticles;
  late final RendererGameObjects rendererGameObjects;
  late IsometricRenderer next = rendererNodes;

  IsometricRender(this.isometric){
    print('IsometricRender()');
    rendererNodes = RendererNodes(isometric);
    rendererProjectiles = RendererProjectiles(isometric);
    rendererCharacters = RendererCharacters(isometric);
    rendererParticles = RendererParticles(isometric);
    rendererGameObjects = RendererGameObjects(isometric);
  }

  void resetRenderOrder(IsometricRenderer value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  void checkNext(IsometricRenderer renderer){
    if (
      !renderer.remaining ||
      renderer.order > next.order
    ) return;
    next = renderer;
  }

  void render3D() {
    totalRemaining = 0;
    resetRenderOrder(rendererNodes);
    resetRenderOrder(rendererCharacters);
    resetRenderOrder(rendererGameObjects);
    resetRenderOrder(rendererParticles);
    resetRenderOrder(rendererProjectiles);

    if (totalRemaining == 0) return;

    while (true) {
      next = rendererNodes;
      checkNext(rendererCharacters);
      checkNext(rendererProjectiles);
      checkNext(rendererGameObjects);
      checkNext(rendererParticles);
      if (next.remaining) {
        next.renderNext();
        continue;
      }
      totalRemaining--;
      if (totalRemaining == 0) return;

      if (totalRemaining == 1) {
        while (rendererNodes.remaining) {
          rendererNodes.renderNext();
        }
        while (rendererCharacters.remaining) {
          rendererCharacters.renderNext();
        }
        while (rendererParticles.remaining) {
          rendererParticles.renderNext();
        }
        while (rendererProjectiles.remaining) {
          rendererProjectiles.renderNext();
        }
      }
      return;
    }
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;

  void renderTextPosition(Position v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: Isometric.getPositionRenderX(v3),
      y: Isometric.getPositionRenderY(v3) + offsetY,
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
        x: Isometric.getRenderX(x, y, z),
        y: Isometric.getRenderY(x, y, z),
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
      dstX: Isometric.getRenderX(x, y, z),
      dstY: Isometric.getRenderY(x, y, z),
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
      dstX: Isometric.getPositionRenderX(position) - 26,
      dstY: Isometric.getPositionRenderY(position) - 45,
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
      dstX: Isometric.getRenderX(x, y, z) - 26,
      dstY: Isometric.getRenderY(x, y, z) - 55,
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



  static double getRenderXOfRowAndColumn(int row, int column) =>
      (row - column) * Node_Size_Half;

  static double getRenderYfOfRowColumn(int row, int column) =>
      (row + column) * Node_Size_Half;

  static double getRenderYOfRowColumnZ(int row, int column, int z) =>
      (row + column - z) * Node_Size_Half;

  static double convertWorldToGridX(double x, double y) => x + y;

  static double convertWorldToGridY(double x, double y) => y - x;

  static int convertWorldToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;

  static int convertWorldToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;
}


