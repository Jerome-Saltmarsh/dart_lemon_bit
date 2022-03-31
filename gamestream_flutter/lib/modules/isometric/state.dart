
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
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
  late ui.Image image;

  final particleEmitters = <ParticleEmitter>[];
  final paths = Float32List(10000);
  final particles = <Particle>[];
  final gemSpawns = <GemSpawn>[];
  final environmentObjects = <EnvironmentObject>[];
  final dynamic = <Int8List>[];
  final bake = <Int8List>[];
  final items = <Item>[];
  final totalColumns = Watch(0);
  final totalRows = Watch(0);
  final hours = Watch(0);
  final minutes = Watch(0);
  final ambient = Watch(Shade.Bright);
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var eventsRegistered = false;
  var tiles = <List<Tile>>[];
  var tilesDst = Float32List(0);
  var tilesSrc = Float32List(0);
  var totalColumnsInt = 0;
  var totalRowsInt = 0;
  var minRow = 0;
  var maxRow = 0;
  var minColumn = 0;
  var maxColumn = 0;

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