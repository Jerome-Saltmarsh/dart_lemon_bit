import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:lemon_engine/functions/load_image.dart';

final _Images images = _Images();

Map<EnvironmentObjectType, List<Image>> typeShades;

class _Images {

  Image human;
  Image tiles;
  Image tilesLight;
  Image tilesMedium;
  Image tilesDark;
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
  Image isoCharacter;
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

  List<Image> flames = [];

  Future<Image> _png(String fileName){
    return loadImage('images/$fileName.png');
  }

  Future load() async {
    longGrass1 = await _png('long-grass1');
    longGrass2 = await _png('long-grass2');
    longGrass3 = await _png('long-grass3');
    longGrass4 = await _png('long-grass4');
    human = await loadImage("images/character.png");
    tiles = await loadImage("images/tiles.png");
    tilesLight = await loadImage("images/tiles-light.png");
    tilesMedium = await loadImage("images/tiles-medium.png");
    tilesDark = await loadImage("images/tiles-dark.png");
    particles = await loadImage('images/particles.png');
    handgun = await loadImage('images/weapon-handgun.png');
    items = await loadImage("images/items.png");
    crate = await loadImage("images/crate.png");
    house = await loadImage("images/house.png");
    houseDay = await loadImage("images/house-day.png");
    house02 = await loadImage("images/house02.png");
    treeA1 = await loadImage("images/treeA1.png");
    treeA2 = await loadImage("images/treeA2.png");
    treeA3 = await loadImage("images/treeA3.png");
    treeA4 = await loadImage("images/treeA4.png");
    treeB1 = await loadImage("images/treeB1.png");
    treeB2 = await loadImage("images/treeB2.png");
    treeB3 = await loadImage("images/treeB3.png");
    treeB4 = await loadImage("images/treeB4.png");
    rock1 = await loadImage("images/rock1.png");
    rock2 = await loadImage("images/rock2.png");
    rock3 = await loadImage("images/rock3.png");
    rock4 = await loadImage("images/rock4.png");
    palisade1 = await loadImage("images/palisade1.png");
    palisade2 = await loadImage("images/palisade2.png");
    palisade3 = await loadImage("images/palisade3.png");
    palisade4 = await loadImage("images/palisade4.png");
    palisadeH1 = await loadImage("images/palisade-h1.png");
    palisadeH2 = await loadImage("images/palisade-h2.png");
    palisadeH3 = await loadImage("images/palisade-h3.png");
    palisadeH4 = await loadImage("images/palisade-h4.png");
    palisadeV1 = await loadImage("images/palisade-v1.png");
    palisadeV2 = await loadImage("images/palisade-v2.png");
    palisadeV3 = await loadImage("images/palisade-v3.png");
    palisadeV4 = await loadImage("images/palisade-v4.png");
    grave1 = await loadImage("images/grave1.png");
    grave2 = await loadImage("images/grave2.png");
    grave3 = await loadImage("images/grave3.png");
    grave4 = await loadImage("images/grave4.png");
    circle64 = await loadImage("images/circle-64.png");
    circle = await _png("circle");
    radial64_50 = await loadImage("images/radial-64-50.png");
    radial64_40 = await loadImage("images/radial-64-40.png");
    radial64_30 = await loadImage("images/radial-64-30.png");
    radial64_20 = await loadImage("images/radial-64-20.png");
    radial64_10 = await loadImage("images/radial-64-10.png");
    radial64_05 = await loadImage("images/radial-64-05.png");
    radial64_02 = await loadImage("images/radial-64-02.png");
    torch_01 = await loadImage("images/torch-01.png");
    torch_02 = await loadImage("images/torch-02.png");
    torch_03 = await loadImage("images/torch-03.png");
    torchOut = await loadImage("images/torch-out.png");
    bridge = await loadImage("images/bridge.png");
    treeStump1 = await loadImage("images/tree-stump1.png");
    treeStump2 = await loadImage("images/tree-stump2.png");
    treeStump3 = await loadImage("images/tree-stump3.png");
    treeStump4 = await loadImage("images/tree-stump4.png");
    rockSmall1 = await loadImage("images/rock-small1.png");
    rockSmall2 = await loadImage("images/rock-small2.png");
    rockSmall3 = await loadImage("images/rock-small3.png");
    rockSmall4 = await loadImage("images/rock-small4.png");
    manUnarmedRunning1 = await loadImage("images/man-unarmed-running-1.png");
    manUnarmedRunning2 = await loadImage("images/man-unarmed-running-2.png");
    manUnarmedRunning3 = await loadImage("images/man-unarmed-running-3.png");
    manFiringHandgun1 = await loadImage("images/man-firing-handgun-1.png");
    manFiringHandgun2 = await loadImage("images/man-firing-handgun-2.png");
    manFiringHandgun3 = await loadImage("images/man-firing-handgun-3.png");
    manFiringShotgun1 = await loadImage("images/man-firing-shotgun-1.png");
    manFiringShotgun2 = await loadImage("images/man-firing-shotgun-2.png");
    manFiringShotgun3 = await loadImage("images/man-firing-shotgun-3.png");
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
    empty = await _png("empty");
    manWalkingHandgun1 = await _png("man-walking-handgun-1");
    manWalkingHandgun2 = await _png("man-walking-handgun-2");
    manWalkingHandgun3 = await _png("man-walking-handgun-3");
    flames.add(torch_01);
    flames.add(torch_02);
    flames.add(torch_03);

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
  }
}


