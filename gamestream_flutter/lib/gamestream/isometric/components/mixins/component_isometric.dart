
import 'package:gamestream_flutter/gamestream/game_io.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_projectiles.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_events.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_response_reader.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_minimap.dart';
import 'package:gamestream_flutter/library.dart';


mixin IsometricComponent {
  late final Engine engine;
  late final Isometric isometric;
  late final IsometricAnimation animation;
  late final IsometricNetwork network;
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
  late final IsometricEditor editor;
  late final IsometricDebug debug;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricUI ui;
  late final IsometricRender render;
  late final IsometricActions action;
  late final IsometricEvents events;
  late final IsometricOptions options;
  late final IsometricResponseReader responseReader;
  late final WebsiteGame website;
  late final MmoGame amulet;
  late final CaptureTheFlagGame gameCaptureTheFlag;
  late final IsometricIO io;
  late final IsometricImages images;

  void onComponentReady() {

  }

  void onImagesLoaded(){

  }

  late final T Function<T>() findComponent;
}