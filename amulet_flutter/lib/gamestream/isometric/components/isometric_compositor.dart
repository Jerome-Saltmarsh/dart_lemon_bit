
import 'package:amulet_flutter/isometric/classes/render_group.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';

class IsometricCompositor with IsometricComponent {

  var order = 0;

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
    final engine = this.engine;
    final images = this.images;

    var charactersRemaining = characters.remaining;
    var projectilesRemaining = projectiles.remaining;
    var gameObjectsRemaining = gameObjects.remaining;
    var particlesRemaining = particles.remaining;
    var editorRemaining = editor.remaining;

    if (nodes.remaining){
      totalRemaining++;
    }
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

    var charactersOrder = characters.order;
    var projectilesOrder = projectiles.order;
    var gameObjectsOrder = gameObjects.order;
    var particlesOrder = particles.order;
    var editorOrder = editor.order;

    if (totalRemaining == 0) {
      return;
    }

    RenderGroup next = nodes;
    var nextOrder = next.order;

    while (true) {

      next = nodes;
      nextOrder = next.order;

      if (charactersRemaining && charactersOrder < nextOrder){
        next = characters;
        nextOrder = charactersOrder;
      }

      if (projectilesRemaining && projectilesOrder < nextOrder){
        next = projectiles;
        nextOrder = projectilesOrder;
      }

      if (gameObjectsRemaining && gameObjectsOrder < nextOrder){
        next = gameObjects;
        nextOrder = gameObjectsOrder;
      }

      if (particlesRemaining && particlesOrder < nextOrder){
        next = particles;
        nextOrder = particlesOrder;
      }

      if (editorRemaining && editorOrder < nextOrder){
        next = editor;
        nextOrder = editorOrder;
      }

      // this.order = nextOrder.toInt();
      // next.renderNext(engine, images);

      if (next.renderNext(engine, images)) {
        if (next == nodes){
          continue;
        }

        if (charactersRemaining && next == characters){
          charactersOrder = characters.order;
          continue;
        }

        if (projectilesRemaining && next == projectiles){
          projectilesOrder = projectiles.order;
          continue;
        }

        if (gameObjectsRemaining && next == gameObjects){
          gameObjectsOrder = gameObjects.order;
          continue;
        }

        if (particlesRemaining && next == particles){
          particlesOrder = particles.order;
          continue;
        }

        if (editorRemaining && next == editor){
          editorOrder = editor.order;
          continue;
        }
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


