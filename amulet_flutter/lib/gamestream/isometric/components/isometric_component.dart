
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/user_service/src.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:amulet_flutter/gamestream/isometric/src.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_screen.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/game_isometric_minimap.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:amulet_flutter/packages/lemon_components.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'render/renderer_editor.dart';

mixin IsometricComponent implements Component {
  late final LemonEngine engine;
  late final IsometricAnimation animation;
  late final IsometricServer server;
  late final IsometricParticles particles;
  late final IsometricPlayer player;
  late final IsometricScene scene;
  late final IsometricEnvironment environment;
  late final IsometricAudio audio;
  late final RendererCharacters rendererCharacters;
  late final RendererNodes rendererNodes;
  late final RendererParticles rendererParticles;
  late final RendererProjectiles rendererProjectiles;
  late final RendererGameObjects rendererGameObjects;
  late final RendererEditor rendererEditor;
  late final IsometricEditor editor;
  late final IsometricDebug debug;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricUI ui;
  late final IsometricRender render;
  late final IsometricActions actions;
  late final IsometricEvents events;
  late final IsometricOptions options;
  late final IsometricParser parser;
  late final WebsiteGame website;
  late final Amulet amulet;
  late final IsometricIO io;
  late final IsometricImages images;
  late final IsometricScreen screen;
  late final IsometricLighting lighting;
  late final IsometricColors colors;
  late final IsometricCompositor compositor;
  late final IsometricStyle style;
  late final UserServiceHttp userServiceHttp;

  /// (save to override)
  Future onComponentInit(SharedPreferences sharedPreferences) async {  }

  /// (save to override)
  void onComponentReady(){  }

  /// (save to override)
  void onComponentError(Object error, StackTrace stack) {}

  /// (save to override)
  void onComponentDispose() {

  }
}