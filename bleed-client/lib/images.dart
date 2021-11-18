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
  Image manIdle;
  Image manIdleHandgun1;
  Image manIdleHandgun2;
  Image manIdleHandgun3;
  Image manIdleBright;
  Image manWalking;
  Image manWalkingBright;
  Image manUnarmedRunning;
  Image manUnarmedRunning1;
  Image manUnarmedRunning2;
  Image manUnarmedRunning3;
  Image manFiringHandgun1;
  Image manFiringHandgun2;
  Image manFiringHandgun3;
  Image manFiringShotgun1;
  Image manFiringShotgun2;
  Image manFiringShotgun3;
  Image manIdleShotgun01;
  Image manIdleShotgun02;
  Image manIdleShotgun03;
  Image manIdleShotgun04;
  Image manWalkingShotgunShade1;
  Image manWalkingShotgunShade2;
  Image manWalkingShotgunShade3;
  Image manChanging1;
  Image manChanging2;
  Image manChanging3;
  Image manDying1;
  Image manDying2;
  Image manDying3;
  Image manStriking;
  Image manWalkingHandgun1;
  Image manWalkingHandgun2;
  Image manWalkingHandgun3;
  Image zombieWalkingBright;
  Image zombieWalkingMedium;
  Image zombieWalkingDark;
  Image zombieDyingBright;
  Image zombieDyingMedium;
  Image zombieDyingDark;
  Image zombieStriking1;
  Image zombieStriking2;
  Image zombieStriking3;
  Image zombieIdleBright;
  Image zombieIdleMedium;
  Image zombieIdleDark;
  Image empty;
  Image fireball;
  Image torches;

  Future<Image> _png(String fileName) async {
    Image image = await loadImage('images/$fileName.png');
    _imagesLoaded.value++;
    return image;
  }

  Future load() async {
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
    manUnarmedRunning = await _png("man-unarmed-running");
    manUnarmedRunning1 = await _png("man-unarmed-running-1");
    manUnarmedRunning2 = await _png("man-unarmed-running-2");
    manUnarmedRunning3 = await _png("man-unarmed-running-3");
    manFiringHandgun1 = await _png("man-firing-handgun-1");
    manFiringHandgun2 = await _png("man-firing-handgun-2");
    manFiringHandgun3 = await _png("man-firing-handgun-3");
    manFiringShotgun1 = await _png("man-firing-shotgun-1");
    manFiringShotgun2 = await _png("man-firing-shotgun-2");
    manFiringShotgun3 = await _png("man-firing-shotgun-3");
    manIdleShotgun01 = await _png("man-idle-shotgun-1");
    manIdleShotgun02 = await _png("man-idle-shotgun-2");
    manIdleShotgun03 = await _png("man-idle-shotgun-3");
    manIdleShotgun04 = await _png("man-idle-shotgun-4");
    manWalkingShotgunShade1 = await _png("man-walking-shotgun-shade01");
    manWalkingShotgunShade2 = await _png("man-walking-shotgun-shade02");
    manWalkingShotgunShade3 = await _png("man-walking-shotgun-shade03");
    manChanging1 = await _png("man-changing-1");
    manChanging2 = await _png("man-changing-2");
    manChanging3 = await _png("man-changing-3");
    manDying1 = await _png("man-dying-1");
    manDying2 = await _png("man-dying-2");
    manDying3 = await _png("man-dying-3");
    manStriking = await _png("man-striking");
    manWalking = await _png("man-walking");
    manWalkingBright = await _png("man-walking-bright");
    manIdle = await _png("man-idle");
    manIdleHandgun1 = await _png("man-idle-handgun-1");
    manIdleHandgun2 = await _png("man-idle-handgun-2");
    manIdleHandgun3 = await _png("man-idle-handgun-3");
    manIdleBright = await _png("man-idle-bright");
    zombieWalkingBright = await _png("zombie-walking-1");
    zombieWalkingMedium = await _png("zombie-walking-2");
    zombieWalkingDark = await _png("zombie-walking-3");
    zombieDyingBright = await _png("zombie-dying-bright");
    zombieDyingMedium = await _png("zombie-dying-medium");
    zombieDyingDark = await _png("zombie-dying-dark");
    zombieStriking1 = await _png("zombie-striking-1");
    zombieStriking2 = await _png("zombie-striking-2");
    zombieStriking3 = await _png("zombie-striking-3");
    zombieIdleBright = await _png("zombie-idle-bright");
    zombieIdleMedium = await _png("zombie-idle-medium");
    zombieIdleDark = await _png("zombie-idle-dark");
    fireball = await _png("fireball");
    empty = await _png("empty");
    manWalkingHandgun1 = await _png("man-walking-handgun-1");
    manWalkingHandgun2 = await _png("man-walking-handgun-2");
    manWalkingHandgun3 = await _png("man-walking-handgun-3");

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


