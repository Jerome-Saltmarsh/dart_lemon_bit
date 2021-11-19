import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/core/buildLoadingScreen.dart';
import 'package:lemon_engine/functions/load_image.dart';
import 'package:lemon_watch/watch.dart';

final _Images images = _Images();
const int _totalImages = 68;

Watch<int> _imagesLoaded = Watch(0, onChanged: (int value){
  download.value =  value / _totalImages;
});

Map<ObjectType, int> environmentObjectIndex = {
  ObjectType.Rock: 1,
  ObjectType.Grave: 2,
  ObjectType.Tree_Stump: 3,
  ObjectType.Rock_Small: 4,
  ObjectType.LongGrass: 5,
  ObjectType.Torch: 1,
  ObjectType.Tree01: 1,
  ObjectType.Tree02: 2,
  ObjectType.House01: 1,
  ObjectType.House02: 2,
  ObjectType.Palisade: 1,
  ObjectType.Palisade_H: 2,
  ObjectType.Palisade_V: 3,
};

class _Images {
  Image palisades;
  Image tiles;
  Image particles;
  Image handgun;
  Image items;
  Image crate;
  Image circle64;
  Image circle;
  Image radial64_50;
  Image radial64_40;
  Image radial64_30;
  Image radial64_20;
  Image radial64_10;
  Image radial64_05;
  Image radial64_02;
  Image torchOut;
  Image bridge;
  Image zombieIdle;
  Image zombieWalking;
  Image zombieStriking;
  Image zombieDying;
  Image empty;
  Image fireball;
  Image torches;
  Image atlas;

  Future<Image> _png(String fileName) async {
    Image image = await loadImage('images/$fileName.png');
    _imagesLoaded.value++;
    return image;
  }

  Future load() async {
    atlas = await _png("atlas");
    torches = await _png("torches");
    palisades = await _png("palisades");
    tiles = await _png("tiles");
    particles = await _png('particles');
    handgun = await _png('weapon-handgun');
    items = await _png("items");
    crate = await _png("crate");
    circle64 = await _png("circle-64");
    circle = await _png("circle");
    radial64_50 = await _png("radial-64-50");
    radial64_40 = await _png("radial-64-40");
    radial64_30 = await _png("radial-64-30");
    radial64_20 = await _png("radial-64-20");
    radial64_10 = await _png("radial-64-10");
    radial64_05 = await _png("radial-64-05");
    radial64_02 = await _png("radial-64-02");
    torchOut = await _png("torch-out");
    bridge = await _png("bridge");
    zombieIdle = radial64_50;
    zombieWalking = await _png("zombie-walking");
    zombieDying = radial64_50;
    zombieStriking = await _png("zombie-striking");
    fireball = await _png("fireball");
    empty = await _png("empty");
  }
}


