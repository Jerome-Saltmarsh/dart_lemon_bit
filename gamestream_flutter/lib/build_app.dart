
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/user/user.dart';
import 'package:gamestream_flutter/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_screen.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_editor.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_minimap.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/loading_page.dart';
import 'package:provider/provider.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'gamestream/isometric/src.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';

Widget buildApp(){
  print('buildApp()');

  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine(
    init: (_){},
    update: () {},
    render: (canvas, size) {}, // overridden when components are ready
    onDrawForeground: (canvas, size) {}, // overridden when components are ready
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    buildUI: (context) => LoadingPage(),
    buildLoadingScreen: (context) => LoadingPage(),
  );

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
      network: IsometricNetwork(),
      audio: IsometricAudio(),
      options: IsometricOptions(),
      compositor: IsometricCompositor(),
      website: WebsiteGame(),
      mmo: Amulet(),
      animation: IsometricAnimation(),
      screen: IsometricScreen(),
      lighting: IsometricLighting(),
      colors: IsometricColors(),
      style: IsometricStyle(),
      user: User(),
      engine: engine,
  );

  return Provider<IsometricComponents>(
    create: (context) => components,
    child: engine,
  );

}