
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/common/GemSpawn.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'utilities.dart';

class IsometricState {
  List<ParticleEmitter> particleEmitters = [];
  late ui.Image image;
  List<List<Vector2>> paths = [];
  List<FloatingText> floatingText = [];
  bool eventsRegistered = false;
  List<List<Tile>> tiles = [];
  Float32List tilesDst = Float32List(0);
  Float32List tilesSrc = Float32List(0);
  List<Particle> particles = [];
  final List<GemSpawn> gemSpawns = [];
  final List<EnvironmentObject> environmentObjects = [];
  final List<List<int>> dynamic = [];
  final List<List<int>> bake = [];
  final List<Item> items = [];
  final Watch<int> totalColumns = Watch(0);
  final Watch<int> totalRows = Watch(0);
  final Watch<int> hour = Watch(0);
  final Watch<int> time = Watch(0);
  final Watch<int> ambient = Watch(Shade.Bright);
  final Watch<int> maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  int totalColumnsInt = 0;
  int totalRowsInt = 0;
  int minRow = 0;
  int maxRow = 0;
  int minColumn = 0;
  int maxColumn = 0;

  Particle? next;

  // properties
  int getShade(int row, int column){
    if (row < 0) return Shade.Pitch_Black;
    if (column < 0) return Shade.Pitch_Black;
    if (row >= totalRowsInt){
      return Shade.Pitch_Black;
    }
    if (column >= totalColumnsInt){
      return Shade.Pitch_Black;
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