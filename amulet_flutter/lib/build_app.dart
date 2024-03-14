
import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/components/isometric_components.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet_app.dart';
import 'package:amulet_flutter/website/website_game.dart';
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
import 'package:provider/provider.dart';
import 'isometric/src.dart';

Widget buildApp(){
  print('buildApp()');

  validateAmulet();
  WidgetsFlutterBinding.ensureInitialized();

  final engine = AmuletApp();
  // engine.fullScreenEnter();

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
      // user: UserServiceHttp(),
      engine: engine,
  );

  engine.components = components;
  return Provider<IsometricComponents>(
    create: (context) => components,
    child: engine,
  );
}

void validateAmulet() {

  for (final weaponType in WeaponType.values){
    if (WeaponType.names.containsKey(weaponType)) continue;
    throw Exception('validation exception. WeaponType.names[$weaponType] is null');
  }

  for (final amuletItem in AmuletItem.values){
    if (!amuletItem.isValid()){
      throw Exception();
    }
  }
}