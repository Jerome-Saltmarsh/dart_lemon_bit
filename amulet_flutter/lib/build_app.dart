
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/engine.dart';
import 'package:amulet_flutter/user/user_service_http.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_screen.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_editor.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/game_isometric_minimap.dart';
import 'package:provider/provider.dart';
import 'gamestream/isometric/src.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget buildApp(){
  print('buildApp()');

  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    windowManager.ensureInitialized().then((value) {
      // windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      windowManager.setFullScreen(true);
    });
  }

  final engine = AppleEngine();

  final components = IsometricComponents(
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
      website: WebsiteGame(),
      amulet: Amulet(),
      animation: IsometricAnimation(),
      screen: IsometricScreen(),
      lighting: IsometricLighting(),
      colors: IsometricColors(),
      style: IsometricStyle(),
      user: UserServiceHttp(),
      engine: engine,
  );

  engine.components = components;
  return Provider<IsometricComponents>(
    create: (context) => components,
    child: engine,
  );
}