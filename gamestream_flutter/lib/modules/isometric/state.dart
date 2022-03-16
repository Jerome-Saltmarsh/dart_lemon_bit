
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/FloatingText.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/classes/ParticleEmitter.dart';
import 'package:bleed_common/GemSpawn.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';

import 'utilities.dart';

class IsometricState {
  List<ParticleEmitter> particleEmitters = [];
  late ui.Image image;
  final paths = Float32List(10000);
  List<FloatingText> floatingText = [];
  bool eventsRegistered = false;
  List<List<Tile>> tiles = [];
  Float32List tilesDst = Float32List(0);
  Float32List tilesSrc = Float32List(0);
  List<Particle> particles = [];
  final List<GemSpawn> gemSpawns = [];
  final List<EnvironmentObject> environmentObjects = [];
  final List<Int8List> dynamic = [];
  final List<Int8List> bake = [];
  final List<Item> items = [];
  final Watch<int> totalColumns = Watch(0);
  final Watch<int> totalRows = Watch(0);
  final Watch<int> hours = Watch(0);
  final Watch<int> minutes = Watch(0);
  final Watch<int> ambient = Watch(Shade.Bright);
  final Watch<int> maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  int totalColumnsInt = 0;
  int totalRowsInt = 0;
  int minRow = 0;
  int maxRow = 0;
  int minColumn = 0;
  int maxColumn = 0;

  int offScreenTiles = 0;
  int onScreenTiles = 0;

  Particle? next;

  // properties
  int getShade(int row, int column){
    if (row < 0) return Pitch_Black;
    if (column < 0) return Pitch_Black;
    if (row >= totalRowsInt){
      return Pitch_Black;
    }
    if (column >= totalColumnsInt){
      return Pitch_Black;
    }
    return dynamic[row][column];
  }

  int getShadeAtPosition(double x, double y){
    return getShade(getRow(x, y), getColumn(x, y));
  }

  bool inDarkness(double x, double y){
    return getShadeAtPosition(x, y) >= Shade.Very_Dark;
  }
}