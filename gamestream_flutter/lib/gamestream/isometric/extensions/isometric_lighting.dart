
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/library.dart';

extension IsometricLighting on Isometric {

  void applyEmissionsCharacters() {
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;

      if (character.weaponType == WeaponType.Staff){
        // emitLightColoredAtPosition(
        //   character,
        // );
      } else {
        applyVector3EmissionAmbient(
          character,
          alpha: lighting.emissionAlphaCharacter,
        );
      }
    }
  }


  /// @brightness 0 is the most bright
  void shootLightTreeAmbient({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int alpha,
    required int vx,
    required int vy,
    required int vz,
  }){
    // assert (brightness >= 0);
    if (brightness < 0)
      return;

    while (true) {
      var velocity = vx.abs() + vy.abs() + vz.abs();
      brightness -= velocity;

      if (brightness < 0)
        return;

      if (vx != 0) {
        row += vx;
        if (row < 0 || row >= scene.totalRows)
          return;
      }

      if (vy != 0) {
        column += vy;
        if (column < 0 || column >= scene.totalColumns)
          return;
      }

      if (vz != 0) {
        z += vz;
        if (z < 0 || z >= scene.totalZ)
          return;
      }

      const padding = Node_Size + Node_Size_Half;

      final index = (z * scene.area) + (row * scene.totalColumns) + column;

      if (!bakeStackRecording){
        final renderX = scene.getIndexRenderX(index);

        if (renderX < engine.Screen_Left - padding && (vx < 0 || vy > 0))
          return;

        if (renderX > engine.Screen_Right + padding && (vx > 0 || vy < 0))
          return;

        final renderY = scene.getIndexRenderY(index);

        if (renderY < engine.Screen_Top - padding && (vx < 0 || vy < 0 || vz > 0))
          return;

        if (renderY > engine.Screen_Bottom + padding && (vx > 0 || vy > 0))
          return;
      }


      final nodeType = scene.nodeTypes[index];
      final nodeOrientation = scene.nodeOrientations[index];

      if (!scene.isNodeTypeTransparent(nodeType)) {
        if (nodeOrientation == NodeOrientation.Solid)
          return;

        if (vx < 0) {
          if (const [
            NodeOrientation.Half_South,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Slope_South,
          ].contains(nodeOrientation)) return;

          if (const [
            NodeOrientation.Half_North,
            NodeOrientation.Corner_North_East,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Slope_North,
          ].contains(nodeOrientation)) vx = 0;
        } else if (vx > 0) {
          if (const [
            NodeOrientation.Half_North,
            NodeOrientation.Corner_North_East,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Slope_North,
          ].contains(nodeOrientation)) return;

          if (const [
            NodeOrientation.Half_South,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Slope_South,
          ].contains(nodeOrientation)) vx = 0;
        }

        if (vy < 0) {
          if (const [
            NodeOrientation.Half_West,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Slope_West,
          ].contains(nodeOrientation)) return;

          if (const [
            NodeOrientation.Half_East,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_North_East,
            NodeOrientation.Slope_East,
          ].contains(nodeOrientation)) vy = 0;
        } else if (vy > 0) {
          if (const [
            NodeOrientation.Half_East,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_North_East,
            NodeOrientation.Slope_East,
          ].contains(nodeOrientation)) return;

          if (const [
            NodeOrientation.Half_West,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Slope_West,
          ].contains(nodeOrientation)) vy = 0;
        }

        if (vz < 0) {
          if (const [
            NodeOrientation.Half_Vertical_Bottom,
          ].contains(nodeOrientation)) {
            return;
          }

          if (const [
            NodeOrientation.Half_Vertical_Bottom,
            NodeOrientation.Half_Vertical_Center,
          ].contains(nodeOrientation)) {
            vz = 0;
          }
        }

        if (vz > 0) {
          if (const [NodeOrientation.Half_Vertical_Top]
              .contains(nodeOrientation)) {
            return;
          }

          if (const [
            NodeOrientation.Half_Vertical_Top,
            NodeOrientation.Half_Vertical_Center,
          ].contains(nodeOrientation)) {
            vz = 0;
          }
        }
      }

      final intensity = brightness > 5 ? 1.0 : scene.interpolations[brightness];

      scene.applyAmbient(
        index: index,
        alpha: interpolate(scene.ambientAlpha, alpha, intensity).toInt(),
      );

      if (bakeStackRecording) {
        bakeStackIndex[bakeStackTotal] = index;
        bakeStackBrightness[bakeStackTotal] = brightness;
        bakeStackTotal++;
      }

      if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
      ].contains(nodeType)) {
        brightness--;
        if (brightness < 0)
          return;
      }

      velocity = vx.abs() + vy.abs() + vz.abs();

      if (velocity <= 0)
        return;

      if (velocity > 1)
        break;
    }
    if (vx.abs() + vy.abs() + vz.abs() == 3) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: vx,
        vy: vy,
        vz: vz,
      );
    }

    if (vx.abs() + vy.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: vx,
        vy: vy,
        vz: 0,
      );
    }

    if (vx.abs() + vz.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: vx,
        vy: 0,
        vz: vz,
      );
    }

    if (vy.abs() + vz.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: 0,
        vy: vy,
        vz: vz,
      );
    }

    if (vy != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: 0,
        vy: vy,
        vz: 0,
      );
    }

    if (vx != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: vx,
        vy: 0,
        vz: 0,
      );
    }

    if (vz != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        alpha: alpha,
        vx: 0,
        vy: 0,
        vz: vz,
      );
    }
  }
}