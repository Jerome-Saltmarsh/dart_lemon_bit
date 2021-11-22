import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/core/buildLoadingScreen.dart';
import 'package:lemon_engine/functions/load_image.dart';
import 'package:lemon_watch/watch.dart';

final _Images images = _Images();
const int _totalImages = 17;

Watch<int> _imagesLoaded = Watch(0, onChanged: (int value){
  download.value =  value / _totalImages;
});

Map<ObjectType, int> environmentObjectIndex = {
  ObjectType.Rock: 0,
  ObjectType.Grave: 1,
  ObjectType.Tree_Stump: 2,
  ObjectType.Rock_Small: 3,
  ObjectType.LongGrass: 4,
  ObjectType.Torch: 0,
  ObjectType.Tree01: 0,
  ObjectType.Tree02: 1,
  ObjectType.House01: 0,
  ObjectType.House02: 1,
  ObjectType.Palisade: 0,
  ObjectType.Palisade_H: 1,
  ObjectType.Palisade_V: 2,
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
    torchOut = await _png("torch-out");
    bridge = await _png("bridge");
    zombieWalking = await _png("zombie-walking");
    zombieStriking = await _png("zombie-striking");
    fireball = await _png("fireball");
    empty = await _png("empty");
  }
}


