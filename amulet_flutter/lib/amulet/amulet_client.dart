import 'package:amulet_flutter/isometric/components/isometric_components.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/isometric/components/isometric_environment.dart';
import 'package:amulet_flutter/isometric/components/isometric_options.dart';
import 'package:amulet_flutter/isometric/components/isometric_render.dart';
import 'package:amulet_flutter/isometric/components/isometric_screen.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_characters.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_editor.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_gameobjects.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_nodes.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_particles.dart';
import 'package:amulet_flutter/isometric/components/render/renderer_projectiles.dart';

import 'package:flutter/services.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../isometric/classes/isometric_game.dart';
import '../isometric/components/debug/isometric_debug.dart';
import '../isometric/components/editor/isometric_editor.dart';
import '../isometric/components/isometric_actions.dart';
import '../isometric/components/isometric_animation.dart';
import '../isometric/components/isometric_audio.dart';
import '../isometric/components/isometric_camera.dart';
import '../isometric/components/isometric_compositor.dart';
import '../isometric/components/isometric_events.dart';
import '../isometric/components/isometric_images.dart';
import '../isometric/components/isometric_io.dart';
import '../isometric/components/isometric_lighting.dart';
import '../isometric/components/isometric_mouse.dart';
import '../isometric/components/isometric_parser.dart';
import '../isometric/components/isometric_particles.dart';
import '../isometric/components/isometric_player.dart';
import '../isometric/components/isometric_scene.dart';
import '../isometric/components/isometric_server.dart';
import '../isometric/components/isometric_style.dart';
import '../isometric/components/isometric_ui.dart';
import '../isometric/ui/game_isometric_minimap.dart';
import '../isometric/ui/isometric_colors.dart';

class AmuletClient extends LemonEngine {

  late IsometricComponents components;

  AmuletClient() : super(
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
  ) {
    zoomMin = 0.3;
    components = IsometricComponents(
      engine: this,
      images: IsometricImages(),
      environment: IsometricEnvironment(),
      render: IsometricRender(),
      rendererCharacters: RendererCharacters(),
      rendererGameObjects: RendererGameObjects(),
      rendererNodes: RendererNodes(),
      rendererParticles: RendererParticles(),
      rendererProjectiles: RendererProjectiles(),
      rendererEditor: RendererEditor(),
      editor: IsometricEditor(),
      debug: IsometricDebug(),
      minimap: IsometricMinimap(),
      mouse: IsometricMouse(),
      ui: IsometricUI(),
      action: IsometricActions(),
      events: IsometricEvents(),
      responseReader: IsometricParser(),
      camera: IsometricCamera(),
      particles: IsometricParticles(),
      player: IsometricPlayer(),
      scene: IsometricScene(),
      io: IsometricIO(),
      network: IsometricServer(),
      audio: IsometricAudio(),
      options: IsometricOptions(),
      compositor: IsometricCompositor(),
      amulet: Amulet(),
      animation: IsometricAnimation(),
      screen: IsometricScreen(),
      lighting: IsometricLighting(),
      colors: IsometricColors(),
      style: IsometricStyle(),
      isometricEditor: IsometricGame(),
    );
  }

  @override
  Widget buildUI(BuildContext buildContext) =>
      components.ui.buildUI(buildContext);

  @override
  void onDispose() {
    components.onDispose();
  }

  @override
  void onDrawCanvas(Canvas canvas, Size size) {
    if (!components.ready){
      return;
    }
    components.render.drawCanvas(canvas, size);
  }

  @override
  void onDrawForeground(Canvas canvas, Size size) {
    // components.render.drawForeground(canvas, size);
  }

  @override
  Future onInit(SharedPreferences sharedPreferences)  async {
     await components.init(sharedPreferences);
   }


  @override
  void onUpdate(double delta) {
    if (!components.ready){
      return;
    }
    components.update(delta);
  }

  @override
  void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
  ) {

  }

  @override
  void onMouseEnterCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseEnterCanvas();
  }

  @override
  void onMouseExitCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseExitCanvas();
  }

  @override
  void onLeftClicked() {
    if (!components.ready){
      return;
    }
    components.options.amulet.onLeftClicked();
  }

  @override
  void onRightClicked() {
    if (!components.ready){
      return;
    }
    components.options.amulet.onRightClicked();
  }

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {

    if (!components.ready){
      return;
    }

    // if (key == PhysicalKeyboardKey.escape){
    //   components.engine.fullscreenToggle();
    // }

    // if (key == PhysicalKeyboardKey.enter){
    //   components.engine.fullscreenToggle();
    // }

    components.amulet.onKeyPressed(key);
  }
}