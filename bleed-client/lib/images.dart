import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/core/buildLoadingScreen.dart';
import 'package:lemon_engine/functions/load_image.dart';
import 'package:lemon_watch/watch.dart';

final _Images images = _Images();
const int _totalImages = 68;

Watch<int> _imagesLoaded = Watch(0, onChanged: (int value){
  download.value =  value / _totalImages;
});

Map<EnvironmentObjectType, Image> environmentObjectImage;
Map<Image, double> imageSpriteWidth = {};
Map<Image, double> imageSpriteHeight = {};

Map<EnvironmentObjectType, int> environmentObjectIndex = {
  EnvironmentObjectType.Rock: 1,
  EnvironmentObjectType.Grave: 2,
  EnvironmentObjectType.Tree_Stump: 3,
  EnvironmentObjectType.Rock_Small: 4,
  EnvironmentObjectType.LongGrass: 5,
  EnvironmentObjectType.Torch: 1,
  EnvironmentObjectType.Tree01: 1,
  EnvironmentObjectType.Tree02: 2,
  EnvironmentObjectType.House01: 1,
  EnvironmentObjectType.House02: 2,
  EnvironmentObjectType.Palisade: 1,
  EnvironmentObjectType.Palisade_H: 2,
  EnvironmentObjectType.Palisade_V: 3,
};

class _Images {
  Image objects48;
  Image objects96;
  Image objects150;
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
  Image manIdleUnarmed;
  Image manIdleHandgun;
  Image manWalkingUnarmed;
  Image manRunningUnarmed;
  Image manFiringHandgun;
  Image manFiringShotgun;
  Image manIdleShotgun;
  Image manChanging;
  Image manDying;
  Image manStriking;
  Image manWalkingHandgun;
  Image manWalkingShotgun;
  Image zombieIdle;
  Image zombieWalking;
  Image zombieStriking;
  Image zombieDying;
  Image empty;
  Image fireball;
  Image torches;
  Image human;

  Future<Image> _png(String fileName) async {
    Image image = await loadImage('images/$fileName.png');
    _imagesLoaded.value++;
    return image;
  }

  Future load() async {
    human = await _png("human");
    torches = await _png("torches");
    objects48 = await _png("objects-48");
    objects96 = await _png("objects-96");
    objects150 = await _png("objects-150");
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
    manChanging = await _png("man-changing");
    manDying = await _png("man-dying");
    manStriking = await _png("man-striking");
    manRunningUnarmed = await _png("man-running-unarmed");
    manFiringHandgun = await _png("man-firing-handgun");
    manFiringShotgun = await _png("man-firing-shotgun");
    manWalkingUnarmed = await _png("man-walking-unarmed");
    manWalkingHandgun = await _png("man-walking-handgun");
    manWalkingShotgun = await _png("man-walking-shotgun");
    manIdleUnarmed = await _png("man-idle-unarmed");
    manIdleHandgun = await _png("man-idle-handgun");
    manIdleShotgun = await _png("man-idle-shotgun");
    zombieIdle = manIdleUnarmed;
    zombieWalking = await _png("zombie-walking");
    zombieDying = manDying;
    zombieStriking = await _png("zombie-striking");

    fireball = await _png("fireball");
    empty = await _png("empty");

    environmentObjectImage = {
      EnvironmentObjectType.Rock: objects48,
      EnvironmentObjectType.Grave: objects48,
      EnvironmentObjectType.Tree_Stump: objects48,
      EnvironmentObjectType.Rock_Small: objects48,
      EnvironmentObjectType.LongGrass: objects48,
      EnvironmentObjectType.Torch: torches,
      EnvironmentObjectType.Tree01: objects96,
      EnvironmentObjectType.Tree02: objects96,
      EnvironmentObjectType.House01: objects150,
      EnvironmentObjectType.House02: objects150,
      EnvironmentObjectType.Palisade: palisades,
      EnvironmentObjectType.Palisade_H: palisades,
      EnvironmentObjectType.Palisade_V: palisades,
    };

    imageSpriteWidth = {
      images.objects48: 48.0,
      images.objects96: 96.0,
      images.objects150: 150.0,
      images.palisades: 48,
      images.torches: 25,
    };

    imageSpriteHeight = {
      images.objects48: 48.0,
      images.objects96: 96.0,
      images.objects150: 150.0,
      images.palisades: 100,
      images.torches: 70,
    };
  }
}


