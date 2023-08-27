
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';

class IsometricCompositor with IsometricComponent {

  bool resetRenderOrder(RenderGroup value){
    value.reset();
    return value.remaining;
  }

  static RenderGroup checkNext(RenderGroup renderer, RenderGroup next){
    if (
      !renderer.remaining ||
      renderer.order > next.order
    ) {
      return next;
    }
    return renderer;
  }

  void render3D() {
    var totalRemaining = 0;
    RenderGroup next = rendererNodes;

    if (resetRenderOrder(rendererNodes)){
      totalRemaining++;
    }
    if (resetRenderOrder(rendererCharacters)){
      totalRemaining++;
    }
    if (resetRenderOrder(rendererGameObjects)){
      totalRemaining++;
    }
    if (resetRenderOrder(rendererParticles)){
      totalRemaining++;
    }
    if (resetRenderOrder(rendererProjectiles)){
      totalRemaining++;
    }
    if (resetRenderOrder(rendererEditor)){
      totalRemaining++;
    }

    final nodes = rendererNodes;
    final characters = rendererCharacters;
    final projectiles = rendererProjectiles;
    final gameObjects = rendererGameObjects;
    final particles = rendererParticles;
    final editor = rendererEditor;

    if (totalRemaining == 0)
      return;

    while (true) {
      next = nodes;
      next = checkNext(characters, next);
      next = checkNext(projectiles, next);
      next = checkNext(gameObjects, next);
      next = checkNext(particles, next);
      next = checkNext(editor, next);

      if (next.remaining) {
        next.renderNext();
        continue;
      }

      totalRemaining--;
      if (totalRemaining == 0)
        return;

      if (totalRemaining == 1) {
        while (rendererNodes.remaining) {
          rendererNodes.renderNext();
        }
        while (rendererEditor.remaining) {
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


