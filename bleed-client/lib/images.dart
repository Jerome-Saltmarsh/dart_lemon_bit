import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:lemon_engine/functions/load_image.dart';

final _Images images = _Images();

Map<EnvironmentObjectType, List<Image>> typeShades;

class Shades {
  Image shade1;
  Image shade2;
  Image shade3;
  Image shade4;
  Shades(this.shade1, this.shade2, this.shade3, this.shade4);
}

Future<Shades> load4(String name) async {
  Image shade1 = await loadImage(name + "-1.png");
  Image shade2 = await loadImage(name + "-2.png");
  Image shade3 = await loadImage(name + "-3.png");
  Image shade4 = await loadImage(name + "-3.png");
  return Shades(shade1, shade2, shade3, shade4);
}

class _Images {

  Shades rockShades;

  Image human;
  Image zombie;
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
  Image palisadeBright;
  Image palisadeMedium;
  Image palisadeDark;
  Image palisadeDarkDark;
  Image palisadeHBright;
  Image palisadeHMedium;
  Image palisadeHDark;
  Image palisadeHDarkDark;
  Image palisadeVBright;
  Image palisadeVMedium;
  Image palisadeVDark;
  Image palisadeVDarkDark;
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
  Image rockSmallBright;
  Image rockSmallMedium;
  Image rockSmallDark;
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
  Image longGrassBright;
  Image longGrassNormal;
  Image longGrassDark;

  List<Image> flames = [];

  Future<Image> _png(String fileName){
    return loadImage('images/$fileName.png');
  }

  Future load() async {
    longGrassBright = await _png('long-grass-bright');
    longGrassNormal = await _png('long-grass-normal');
    longGrassDark = await _png('long-grass-dark');
    human = await loadImage("images/character.png");
    tiles = await loadImage("images/tiles.png");
    zombie = await loadImage("images/zombie.png");
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
    treeA1 = await loadImage("images/tree-bright.png");
    treeA2 = await loadImage("images/tree-medium.png");
    treeA3 = await loadImage("images/tree-dark.png");
    treeA4 = await loadImage("images/tree-dark-dark.png");
    treeB1 = await loadImage("images/tree2-bright.png");
    treeB2 = await loadImage("images/tree2-medium.png");
    treeB3 = await loadImage("images/tree2-dark.png");
    treeB4 = await loadImage("images/tree2-dark-dark.png");
    rock1 = await loadImage("images/rock-bright.png");
    rock2 = await loadImage("images/rock-medium.png");
    rock3 = await loadImage("images/rock-dark.png");
    palisadeBright = await loadImage("images/palisade-bright.png");
    palisadeMedium = await loadImage("images/palisade-medium.png");
    palisadeDark = await loadImage("images/palisade-dark.png");
    palisadeDarkDark = await loadImage("images/palisade-dark-dark.png");
    palisadeHBright = await loadImage("images/palisade-h-bright.png");
    palisadeHMedium = await loadImage("images/palisade-h-medium.png");
    palisadeHDark = await loadImage("images/palisade-h-dark.png");
    palisadeHDarkDark = await loadImage("images/palisade-h-dark-dark.png");
    palisadeVBright = await loadImage("images/palisade-v-bright.png");
    palisadeVMedium = await loadImage("images/palisade-v-medium.png");
    palisadeVDark = await loadImage("images/palisade-v-dark.png");
    palisadeVDarkDark = await loadImage("images/palisade-v-dark-dark.png");
    grave1 = await loadImage("images/grave-bright.png");
    grave2 = await loadImage("images/grave-medium.png");
    grave3 = await loadImage("images/grave-dark.png");
    grave4 = await loadImage("images/grave-dark-dark.png");
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
    treeStump1 = await loadImage("images/tree-stump-bright.png");
    treeStump2 = await loadImage("images/tree-stump-medium.png");
    treeStump3 = await loadImage("images/tree-stump-dark.png");
    treeStump4 = await loadImage("images/tree-stump-dark-dark.png");
    rockSmallBright = await loadImage("images/rock-small-bright.png");
    rockSmallMedium = await loadImage("images/rock-small-medium.png");
    rockSmallDark = await loadImage("images/rock-small-dark.png");
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
        rock3,
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
      ]
    };
  }
}


