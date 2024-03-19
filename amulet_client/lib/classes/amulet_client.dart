import 'package:amulet_client/components/debug/isometric_debug.dart';
import 'package:amulet_client/components/editor/isometric_editor.dart';
import 'package:amulet_client/components/isometric_actions.dart';
import 'package:amulet_client/components/isometric_animation.dart';
import 'package:amulet_client/components/isometric_audio.dart';
import 'package:amulet_client/components/isometric_camera.dart';
import 'package:amulet_client/components/isometric_components.dart';
import 'package:amulet_client/components/isometric_compositor.dart';
import 'package:amulet_client/components/isometric_environment.dart';
import 'package:amulet_client/components/isometric_events.dart';
import 'package:amulet_client/components/isometric_images.dart';
import 'package:amulet_client/components/isometric_io.dart';
import 'package:amulet_client/components/isometric_lighting.dart';
import 'package:amulet_client/components/isometric_mouse.dart';
import 'package:amulet_client/components/isometric_options.dart';
import 'package:amulet_client/components/isometric_parser.dart';
import 'package:amulet_client/components/isometric_particles.dart';
import 'package:amulet_client/components/isometric_player.dart';
import 'package:amulet_client/components/isometric_render.dart';
import 'package:amulet_client/components/isometric_scene.dart';
import 'package:amulet_client/components/isometric_screen.dart';
import 'package:amulet_client/components/isometric_server.dart';
import 'package:amulet_client/components/isometric_style.dart';
import 'package:amulet_client/components/isometric_ui.dart';
import 'package:amulet_client/components/render/renderer_characters.dart';
import 'package:amulet_client/components/render/renderer_editor.dart';
import 'package:amulet_client/components/render/renderer_gameobjects.dart';
import 'package:amulet_client/components/render/renderer_nodes.dart';
import 'package:amulet_client/components/render/renderer_particles.dart';
import 'package:amulet_client/components/render/renderer_projectiles.dart';
import 'package:amulet_client/ui/game_isometric_minimap.dart';
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:flutter/material.dart';
import 'package:amulet_client/classes/amulet.dart';

import 'package:flutter/services.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amulet_ui.dart';

class AmuletClient {

  late IsometricComponents components;
  var initializing = false;
  var initialized = false;
  late AmuletUI amuletUI;
  final LemonEngine engine;

  AmuletClient(this.engine) : super(
    // title: 'AMULET',
    // themeData: ThemeData(fontFamily: 'VT323-Regular'),
    // backgroundColor: IsometricColors.Black,
  ) {
    engine.zoomMin = 0.3;
    components = IsometricComponents(
      engine: engine,
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
      // isometricEditor: IsometricGame(),
    );

    amuletUI = AmuletUI(components.amulet);
  }

  Widget buildUI(BuildContext context) =>
       amuletUI.buildUI(context);

  void dispose() => components.onDispose();

  void onDrawCanvas(Canvas canvas, Size size) {
    if (!components.ready){
      return;
    }
    components.render.drawCanvas(canvas, size);
  }

  void onDrawForeground(Canvas canvas, Size size) {
    // components.render.drawForeground(canvas, size);
  }

  Future onInit(SharedPreferences sharedPreferences)  async {
     if (initializing || initialized) return;
     print('amulet_client.onInit()');
     initializing = true;
     await components.init(sharedPreferences);
     // components.engine.fullScreenEnter();
     initialized = true;
   }

  void onUpdate(double delta) {
    if (!components.ready){
      return;
    }
    components.update(delta);
  }

  void onMouseEnterCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseEnterCanvas();
  }

  void onMouseExitCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseExitCanvas();
  }

  void onLeftClicked() {
    if (!components.ready){
      return;
    }
    // components.options.amulet.onLeftClicked();
  }

  void onRightClicked() {
    if (!components.ready){
      return;
    }
    // components.options.amulet.onRightClicked();
  }

  void onKeyPressed(PhysicalKeyboardKey key) {

    if (!components.ready){
      return;
    }
    components.amulet.onKeyPressed(key);
  }
}