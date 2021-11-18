import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/core/buildLoadingScreen.dart';
import 'package:lemon_engine/functions/load_image.dart';

final _Images images = _Images();

Map<EnvironmentObjectType, List<Image>> typeShades;
Map<EnvironmentObjectType, Image> environmentObjectImage;
Map<Image, double> imageSpriteWidth = {};
Map<Image, double> imageSpriteHeight = {};

Map<EnvironmentObjectType, int> environmentObjectIndex = {
  EnvironmentObjectType.Rock: 1,
  EnvironmentObjectType.Grave: 2,
  EnvironmentObjectType.Tree_Stump: 3,
  EnvironmentObjectType.Rock_Small: 4,
  EnvironmentObjectType.LongGrass: 5,
  EnvironmentObjectType.Torch: 6,
  EnvironmentObjectType.Tree01: 1,
  EnvironmentObjectType.Tree02: 2,
  EnvironmentObjectType.House01: 1,
  EnvironmentObjectType.House02: 2,
  EnvironmentObjectType.Palisade: 1,
  EnvironmentObjectType.Palisade_V: 2,
  EnvironmentObjectType.Palisade_H: 3,
};

const double _totalImages = 111;
double _imagesLoaded = 0;

void _imageLoaded(){
  _imagesLoaded++;
  download.value =  _imagesLoaded / _totalImages;
}


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
  Image house;
  Image houseDay;
  Image house02;
  Image treeA1;
  Image treeA2;
  Image treeA3;
  Image treeA4;
  Image treeB1;
  Image treeB2;
  Image treeB3;
  Image treeB4;
  Image rock1;
  Image rock2;
  Image rock3;
  Image rock4;
  Image palisade1;
  Image palisade2;
  Image palisade3;
  Image palisade4;
  Image palisadeH1;
  Image palisadeH2;
  Image palisadeH3;
  Image palisadeH4;
  Image palisadeV1;
  Image palisadeV2;
  Image palisadeV3;
  Image palisadeV4;
  Image grave1;
  Image grave2;
  Image grave3;
  Image grave4;
  Image circle64;
  Image circle;
  Image radial64_50;
  Image radial64_40;
  Image radial64_30;
  Image radial64_20;
  Image radial64_10;
  Image radial64_05;
  Image radial64_02;
  Image torch;
  Image torch_01;
  Image torch_02;
  Image torch_03;
  Image torch_04;
  Image torchOut;
  Image bridge;
  Image treeStump1;
  Image treeStump2;
  Image treeStump3;
  Image treeStump4;
  Image rockSmall1;
  Image rockSmall2;
  Image rockSmall3;
  Image rockSmall4;
  Image manIdle;
  Image manIdleHandgun1;
  Image manIdleHandgun2;
  Image manIdleHandgun3;
  Image manIdleBright;
  Image manWalking;
  Image manWalkingBright;
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
  Image longGrass1;
  Image longGrass2;
  Image longGrass3;
  Image longGrass4;
  Image fireball;

  List<Image> flames = [];

  Future<Image> _png(String fileName){
    return loadImage('images/$fileName.png');
  }

  Future load() async {
    objects48 = await _png("objects-48");
    _imageLoaded();
    objects96 = await _png("objects-96");
    _imageLoaded();
    objects150 = await _png("objects-150");
    _imageLoaded();
    palisades = await _png("palisades");
    _imageLoaded();
    longGrass1 = await _png('long-grass1');
    _imageLoaded();
    longGrass2 = await _png('long-grass2');
    _imageLoaded();
    longGrass3 = await _png('long-grass3');
    _imageLoaded();
    longGrass4 = await _png('long-grass4');
    _imageLoaded();
    tiles = await loadImage("images/tiles.png");
    _imageLoaded();
    particles = await loadImage('images/particles.png');
    _imageLoaded();
    handgun = await loadImage('images/weapon-handgun.png');
    _imageLoaded();
    items = await loadImage("images/items.png");
    _imageLoaded();
    crate = await loadImage("images/crate.png");
    _imageLoaded();
    house = await loadImage("images/house.png");
    _imageLoaded();
    houseDay = await loadImage("images/house-day.png");
    _imageLoaded();
    house02 = await loadImage("images/house02.png");
    _imageLoaded();
    treeA1 = await loadImage("images/treeA1.png");
    _imageLoaded();
    treeA2 = await loadImage("images/treeA2.png");
    _imageLoaded();
    treeA3 = await loadImage("images/treeA3.png");
    _imageLoaded();
    treeA4 = await loadImage("images/treeA4.png");
    _imageLoaded();
    treeB1 = await loadImage("images/treeB1.png");
    _imageLoaded();
    treeB2 = await loadImage("images/treeB2.png");
    _imageLoaded();
    treeB3 = await loadImage("images/treeB3.png");
    _imageLoaded();
    treeB4 = await loadImage("images/treeB4.png");
    _imageLoaded();
    rock1 = await loadImage("images/rock1.png");
    _imageLoaded();
    rock2 = await loadImage("images/rock2.png");
    _imageLoaded();
    rock3 = await loadImage("images/rock3.png");
    _imageLoaded();
    rock4 = await loadImage("images/rock4.png");
    _imageLoaded();
    palisade1 = await loadImage("images/palisade1.png");
    _imageLoaded();
    palisade2 = await loadImage("images/palisade2.png");
    _imageLoaded();
    palisade3 = await loadImage("images/palisade3.png");
    _imageLoaded();
    palisade4 = await loadImage("images/palisade4.png");
    _imageLoaded();
    palisadeH1 = await loadImage("images/palisade-h1.png");
    _imageLoaded();
    palisadeH2 = await loadImage("images/palisade-h2.png");
    _imageLoaded();
    palisadeH3 = await loadImage("images/palisade-h3.png");
    _imageLoaded();
    palisadeH4 = await loadImage("images/palisade-h4.png");
    _imageLoaded();
    palisadeV1 = await loadImage("images/palisade-v1.png");
    _imageLoaded();
    palisadeV2 = await loadImage("images/palisade-v2.png");
    _imageLoaded();
    palisadeV3 = await loadImage("images/palisade-v3.png");
    _imageLoaded();
    palisadeV4 = await loadImage("images/palisade-v4.png");
    _imageLoaded();
    grave1 = await loadImage("images/grave1.png");
    _imageLoaded();
    grave2 = await loadImage("images/grave2.png");
    _imageLoaded();
    grave3 = await loadImage("images/grave3.png");
    _imageLoaded();
    grave4 = await loadImage("images/grave4.png");
    _imageLoaded();
    circle64 = await loadImage("images/circle-64.png");
    _imageLoaded();
    circle = await _png("circle");
    _imageLoaded();
    radial64_50 = await loadImage("images/radial-64-50.png");
    _imageLoaded();
    radial64_40 = await loadImage("images/radial-64-40.png");
    _imageLoaded();
    radial64_30 = await loadImage("images/radial-64-30.png");
    _imageLoaded();
    radial64_20 = await loadImage("images/radial-64-20.png");
    _imageLoaded();
    radial64_10 = await loadImage("images/radial-64-10.png");
    _imageLoaded();
    radial64_05 = await loadImage("images/radial-64-05.png");
    _imageLoaded();
    radial64_02 = await loadImage("images/radial-64-02.png");
    _imageLoaded();
    torch_01 = await loadImage("images/torch-01.png");
    _imageLoaded();
    torch_02 = await loadImage("images/torch-02.png");
    _imageLoaded();
    torch_03 = await loadImage("images/torch-03.png");
    _imageLoaded();
    torch_04 = await loadImage("images/torch-04.png");
    _imageLoaded();
    torchOut = await loadImage("images/torch-out.png");
    _imageLoaded();
    bridge = await loadImage("images/bridge.png");
    _imageLoaded();
    treeStump1 = await loadImage("images/tree-stump1.png");
    _imageLoaded();
    treeStump2 = await loadImage("images/tree-stump2.png");
    _imageLoaded();
    treeStump3 = await loadImage("images/tree-stump3.png");
    _imageLoaded();
    treeStump4 = await loadImage("images/tree-stump4.png");
    _imageLoaded();
    rockSmall1 = await loadImage("images/rock-small1.png");
    _imageLoaded();
    rockSmall2 = await loadImage("images/rock-small2.png");
    _imageLoaded();
    rockSmall3 = await loadImage("images/rock-small3.png");
    _imageLoaded();
    rockSmall4 = await loadImage("images/rock-small4.png");
    _imageLoaded();
    manUnarmedRunning1 = await loadImage("images/man-unarmed-running-1.png");
    _imageLoaded();
    manUnarmedRunning2 = await loadImage("images/man-unarmed-running-2.png");
    _imageLoaded();
    manUnarmedRunning3 = await loadImage("images/man-unarmed-running-3.png");
    _imageLoaded();
    manFiringHandgun1 = await loadImage("images/man-firing-handgun-1.png");
    _imageLoaded();
    manFiringHandgun2 = await loadImage("images/man-firing-handgun-2.png");
    _imageLoaded();
    manFiringHandgun3 = await loadImage("images/man-firing-handgun-3.png");
    _imageLoaded();
    manFiringShotgun1 = await loadImage("images/man-firing-shotgun-1.png");
    _imageLoaded();
    manFiringShotgun2 = await loadImage("images/man-firing-shotgun-2.png");
    _imageLoaded();
    manFiringShotgun3 = await loadImage("images/man-firing-shotgun-3.png");
    _imageLoaded();
    manIdleShotgun01 = await _png("man-idle-shotgun-1");
    _imageLoaded();
    manIdleShotgun02 = await _png("man-idle-shotgun-2");
    _imageLoaded();
    manIdleShotgun03 = await _png("man-idle-shotgun-3");
    _imageLoaded();
    manIdleShotgun04 = await _png("man-idle-shotgun-4");
    _imageLoaded();
    manWalkingShotgunShade1 = await _png("man-walking-shotgun-shade01");
    _imageLoaded();
    manWalkingShotgunShade2 = await _png("man-walking-shotgun-shade02");
    _imageLoaded();
    manWalkingShotgunShade3 = await _png("man-walking-shotgun-shade03");
    _imageLoaded();
    manChanging1 = await _png("man-changing-1");
    _imageLoaded();
    manChanging2 = await _png("man-changing-2");
    _imageLoaded();
    manChanging3 = await _png("man-changing-3");
    _imageLoaded();
    manDying1 = await _png("man-dying-1");
    _imageLoaded();
    manDying2 = await _png("man-dying-2");
    _imageLoaded();
    manDying3 = await _png("man-dying-3");
    _imageLoaded();
    manStriking = await _png("man-striking");
    _imageLoaded();
    manWalking = await _png("man-walking");
    _imageLoaded();
    manWalkingBright = await _png("man-walking-bright");
    _imageLoaded();
    manIdle = await _png("man-idle");
    _imageLoaded();
    manIdleHandgun1 = await _png("man-idle-handgun-1");
    _imageLoaded();
    manIdleHandgun2 = await _png("man-idle-handgun-2");
    _imageLoaded();
    manIdleHandgun3 = await _png("man-idle-handgun-3");
    _imageLoaded();
    manIdleBright = await _png("man-idle-bright");
    _imageLoaded();
    zombieWalkingBright = await _png("zombie-walking-1");
    _imageLoaded();
    zombieWalkingMedium = await _png("zombie-walking-2");
    _imageLoaded();
    zombieWalkingDark = await _png("zombie-walking-3");
    _imageLoaded();
    zombieDyingBright = await _png("zombie-dying-bright");
    _imageLoaded();
    zombieDyingMedium = await _png("zombie-dying-medium");
    _imageLoaded();
    zombieDyingDark = await _png("zombie-dying-dark");
    _imageLoaded();
    zombieStriking1 = await _png("zombie-striking-1");
    _imageLoaded();
    zombieStriking2 = await _png("zombie-striking-2");
    _imageLoaded();
    zombieStriking3 = await _png("zombie-striking-3");
    _imageLoaded();
    zombieIdleBright = await _png("zombie-idle-bright");
    _imageLoaded();
    zombieIdleMedium = await _png("zombie-idle-medium");
    _imageLoaded();
    zombieIdleDark = await _png("zombie-idle-dark");
    _imageLoaded();
    fireball = await _png("fireball");
    _imageLoaded();
    empty = await _png("empty");
    _imageLoaded();
    manWalkingHandgun1 = await _png("man-walking-handgun-1");
    _imageLoaded();
    manWalkingHandgun2 = await _png("man-walking-handgun-2");
    _imageLoaded();
    manWalkingHandgun3 = await _png("man-walking-handgun-3");
    _imageLoaded();

    flames = [
      torch_01,
      torch_02,
      torch_03,
      torch_04,

    ];
    torch = torch_01;

    typeShades = {
      EnvironmentObjectType.Rock: [
        rock1,
        rock2,
        rock3,
        rock4,
      ],
      EnvironmentObjectType.Tree01: [
        treeA1,
        treeA2,
        treeA3,
        treeA4,
      ],
      EnvironmentObjectType.Tree02: [
        treeB1,
        treeB2,
        treeB3,
        treeB4,
      ],
      EnvironmentObjectType.Tree_Stump: [
        treeStump1,
        treeStump2,
        treeStump3,
        treeStump4,
      ],
      EnvironmentObjectType.Grave: [
        grave1,
        grave2,
        grave3,
        grave4,
      ],
      EnvironmentObjectType.LongGrass: [
        longGrass1,
        longGrass2,
        longGrass3,
        longGrass4,
      ],
      EnvironmentObjectType.Palisade: [
        palisade1,
        palisade2,
        palisade3,
        palisade4,
      ],
      EnvironmentObjectType.Palisade_H: [
        palisadeH1,
        palisadeH2,
        palisadeH3,
        palisadeH4,
      ],
      EnvironmentObjectType.Palisade_V: [
        palisadeV1,
        palisadeV2,
        palisadeV3,
        palisadeV4,
      ],
      EnvironmentObjectType.Rock_Small: [
        rockSmall1,
        rockSmall2,
        rockSmall3,
        rockSmall4,
      ]
    };

    environmentObjectImage = {
      EnvironmentObjectType.Rock: objects48,
      EnvironmentObjectType.Grave: objects48,
      EnvironmentObjectType.Tree_Stump: objects48,
      EnvironmentObjectType.Rock_Small: objects48,
      EnvironmentObjectType.LongGrass: objects48,
      EnvironmentObjectType.Torch: objects48,
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
      images.objects150: 96.0,
      images.palisades: 48
    };

    imageSpriteHeight = {
      images.objects48: 48.0,
      images.objects96: 96.0,
      images.objects150: 96.0,
      images.palisades: 72
    };
  }
}


