
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/player.dart';

class GameState {
  static final player = Player();
  static var totalZombies = 0;
  static final zombies = <Character>[];
  static var totalPlayers = 0;
  static final players = <Character>[];
  static final projectiles = <Projectile>[];
  static var totalProjectiles = 0;
  static final npcs = <Character>[];
  static var totalNpcs = 0;
  static final particleEmitters = <ParticleEmitter>[];
  static final particles = <Particle>[];
  static var totalActiveParticles = 0;
  static var totalParticles = 0;
}