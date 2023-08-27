
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

    rendererNodes.reset();
    rendererCharacters.reset();
    rendererGameObjects.reset();
    rendererParticles.reset();
    rendererProjectiles.reset();
    rendererEditor.reset();


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

    if (charactersRemaining){
      totalRemaining++;
    }
    if (projectilesRemaining){
      totalRemaining++;
    }
    if (gameObjectsRemaining){
      totalRemaining++;
    }
    if (particlesRemaining){
      totalRemaining++;
    }
    if (editorRemaining){
      totalRemaining++;
    }

    // var charactersOrder = characters.order;
    // var projectilesOrder = projectiles.order;
    // var gameObjectsOrder = gameObjects.order;
    // var particlesOrder = particles.order;
    // var editorOrder = editor.order;

    if (totalRemaining == 0) {
      return;
    }

    while (true) {

      RenderGroup next = nodes;
      var nextOrder = next.order;

      if (charactersRemaining && characters.order < nextOrder){
        next = characters;
        nextOrder = next.order;
      }

      if (projectilesRemaining && projectiles.order < nextOrder){
        next = projectiles;
        nextOrder = next.order;
      }

      if (gameObjectsRemaining && gameObjects.order < nextOrder){
        next = gameObjects;
        nextOrder = next.order;
      }

      if (particlesRemaining && particles.order < nextOrder){
        next = particles;
        nextOrder = next.order;
      }

      if (editorRemaining && editor.order < nextOrder){
        next = editor;
        nextOrder = next.order;
      }

      next.renderNext();

      if (next.remaining){
        continue;
      }

      totalRemaining--;

      if (totalRemaining == 0){
        return;
      }

      if (charactersRemaining && next == characters){
        charactersRemaining = false;
        continue;
      }

      if (projectilesRemaining && next == projectiles){
        projectilesRemaining = false;
        continue;
      }

      if (gameObjectsRemaining && next == gameObjects){
        gameObjectsRemaining = false;
        continue;
      }

      if (particlesRemaining && next == particles){
        particlesRemaining = false;
        continue;
      }

      if (editorRemaining && next == editor){
        editorRemaining = false;
        continue;
      }

      return;
    }
  }
}


