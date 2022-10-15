import 'dart:typed_data';

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/events/on_action_finished_lightning_flash.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_ambient_shade.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_vector_emission.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_watch/watch.dart';

class GameState {
  static final player = Player();

  static final characters = <Character>[];
  static final players = <Character>[];
  static final npcs = <Character>[];
  static final zombies = <Character>[];
  static final particles = <Particle>[];
  static final projectiles = <Projectile>[];
  static final particleEmitters = <ParticleEmitter>[];

  static var totalCharacters = 0;
  static var totalPlayers = 0;
  static var totalNpcs = 0;
  static var totalZombies = 0;
  static var totalParticles = 0;
  static var totalProjectiles = 0;

  static var totalActiveParticles = 0;
  static var ambientColor = colorShades[Shade.Bright];

  static final ambientShade = Watch(Shade.Bright, onChanged: onChangedAmbientShade);
  static const nodesInitialSize = 70 * 70 * 8;
  static var nodesBake = Uint8List(nodesInitialSize);
  static var nodesColor = Int32List(nodesInitialSize);
  static var nodesOrientation = Uint8List(nodesInitialSize);
  static var nodesShade = Uint8List(nodesInitialSize);
  static var nodesTotal = nodesInitialSize;
  static var nodesType = Uint8List(nodesInitialSize);
  static var nodesVariation = List<bool>.generate(nodesInitialSize, (index) => false, growable: false);
  static var nodesVisible = List<bool>.generate(nodesInitialSize, (index) => true, growable: false);
  static var nodesVisibleIndex = Uint16List(nodesInitialSize);
  static var nodesDynamicIndex = Uint16List(nodesInitialSize);
  static var nodesWind = Uint8List(nodesInitialSize);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;


  // QUERIES

  static Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  static Character? getPlayerCharacter(){
    for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != GameState.player.x) continue;
      if (characters[i].y != GameState.player.y) continue;
      return characters[i];
    }
    return null;
  }

  static int getNodeShade(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? ambientShade.value
          : nodesShade[
      getNodeIndexZRC(z, row, column)
      ];

  static bool outOfBounds(int z, int row, int column){
    if (z < 0) return true;
    if (z >= nodesTotalZ) return true;
    if (row < 0) return true;
    if (row >= nodesTotalRows) return true;
    if (column < 0) return true;
    if (column >= nodesTotalColumns) return true;
    return false;
  }

  // ACTIONS

  static void applyEmissionsCharacters() {
    var maxBrightness = ambientShade.value - 1;
    if (maxBrightness < Shade.Bright) {
      maxBrightness = Shade.Bright;
    }
    if (maxBrightness > Shade.Medium) {
      maxBrightness = Shade.Medium;
    }
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;
      applyVector3Emission(character, maxBrightness: maxBrightness);
    }
  }

  static double getVolumeTargetDayAmbience() {
    if (ambientShade.value == Shade.Very_Bright) return 0.2;
    return 0;
  }

  static void actionLightningFlash() {
    audioSingleThunder(1.0);
    if (ambientShade.value == Shade.Very_Bright) return;
    ambientShade.value = Shade.Very_Bright;
    runAction(duration: 8, action: onActionFinishedLightningFlash);
  }

  static void resetGridToAmbient(){
    final shade = ambientShade.value;
    for (var i = 0; i < nodesTotal; i++){
      nodesBake[i] = shade;
      nodesShade[i] = shade;
      dynamicIndex = 0;
    }
  }

  static void rainOff() {
    for (var i = 0; i < nodesTotal; i++) {
      if (!NodeType.isRain(nodesType[i])) continue;
      nodesType[i] = NodeType.Empty;
      nodesOrientation[i] = NodeOrientation.None;
    }
  }
}