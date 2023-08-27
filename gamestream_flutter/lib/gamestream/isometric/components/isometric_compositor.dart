
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

    var charactersRemaining = characters.remaining;
    var projectilesRemaining = projectiles.remaining;
    var gameObjectsRemaining = gameObjects.remaining;
    var particlesRemaining = particles.remaining;
    var editorRemaining = editor.remaining;

    if (totalRemaining == 0)
      return;

    while (true) {
      next = nodes;

      if (charactersRemaining){
        next = checkNext(characters, next);
      }

      if (projectilesRemaining){
        next = checkNext(projectiles, next);
      }

      if (gameObjectsRemaining){
        next = checkNext(gameObjects, next);
      }

      if (particlesRemaining){
        next = checkNext(particles, next);
      }

      if (editorRemaining){
        next = checkNext(editor, next);
      }


      if (next.remaining) {
        next.renderNext();
        continue;
      }

      totalRemaining--;
      if (totalRemaining == 0)
        return;

      if (charactersRemaining && next == characters){
        charactersRemaining = false;
      } else
      if (projectilesRemaining && next == projectiles){
        projectilesRemaining = false;
      } else
      if (gameObjectsRemaining && next == gameObjects){
        gameObjectsRemaining = false;
      } else
      if (particlesRemaining && next == particles){
        particlesRemaining = false;
      } else
      if (editorRemaining && next == editor){
        editorRemaining = false;
      }

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


