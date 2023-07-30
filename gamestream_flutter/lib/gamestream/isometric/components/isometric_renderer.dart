
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

import 'render/renderer_characters.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_particles.dart';
import 'render/renderer_projectiles.dart';

class IsometricRenderer {

  final Isometric isometric;

  var totalRemaining = 0;
  var totalIndex = 0;

  late final RendererNodes rendererNodes;
  late final RendererProjectiles rendererProjectiles;
  late final RendererCharacters rendererCharacters;
  late final RendererParticles rendererParticles;
  late final RendererGameObjects rendererGameObjects;
  late RenderGroup next = rendererNodes;

  IsometricRenderer(this.isometric){
    print('IsometricRender()');
    rendererNodes = RendererNodes(isometric);
    rendererProjectiles = RendererProjectiles(isometric);
    rendererCharacters = RendererCharacters(isometric);
    rendererParticles = RendererParticles(isometric);
    rendererGameObjects = RendererGameObjects(isometric);
  }

  void resetRenderOrder(RenderGroup value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  void checkNext(RenderGroup renderer){
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
}


