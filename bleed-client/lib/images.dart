import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/engine/functions/loadImage.dart';

final _Images images = _Images();

class _Images {
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
  Image tree01Bright;
  Image tree01Medium;
  Image tree01Dark;
  Image tree02Bright;
  Image tree02Medium;
  Image tree02Dark;
  Image rockBright;
  Image rockMedium;
  Image rockDark;
  Image palisadeBright;
  Image palisadeMedium;
  Image palisadeDark;
  Image palisadeHBright;
  Image palisadeHMedium;
  Image palisadeHDark;
  Image palisadeVBright;
  Image palisadeVMedium;
  Image palisadeVDark;
  Image graveBright;
  Image graveMedium;
  Image graveDark;
  Image circle64;
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
  Image treeStumpBright;
  Image treeStumpMedium;
  Image treeStumpDark;
  Image rockSmallBright;
  Image rockSmallMedium;
  Image rockSmallDark;
  Image isoCharacter;
  Image manIdle;
  Image manIdleBright;
  Image manWalking;
  Image manWalkingBright;
  Image manRunning;
  Image manFiringHandgun;
  Image manFiringShotgun;
  Image manChanging;
  Image manDying;
  Image manStriking;
  Image zombieWalkingBright;
  Image zombieWalkingMedium;
  Image zombieWalkingDark;
  Image zombieDyingBright;
  Image zombieDyingMedium;
  Image zombieDyingDark;
  Image zombieStriking;
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
    tree01Bright = await loadImage("images/tree-bright.png");
    tree01Medium = await loadImage("images/tree-medium.png");
    tree01Dark = await loadImage("images/tree-dark.png");
    tree02Bright = await loadImage("images/tree2-bright.png");
    tree02Medium = await loadImage("images/tree2-medium.png");
    tree02Dark = await loadImage("images/tree2-dark.png");
    rockBright = await loadImage("images/rock-bright.png");
    rockMedium = await loadImage("images/rock-medium.png");
    rockDark = await loadImage("images/rock-dark.png");
    palisadeBright = await loadImage("images/palisade-bright.png");
    palisadeMedium = await loadImage("images/palisade-medium.png");
    palisadeDark = await loadImage("images/palisade-dark.png");
    palisadeHBright = await loadImage("images/palisade-h-bright.png");
    palisadeHMedium = await loadImage("images/palisade-h-medium.png");
    palisadeHDark = await loadImage("images/palisade-h-dark.png");
    palisadeVBright = await loadImage("images/palisade-v-bright.png");
    palisadeVMedium = await loadImage("images/palisade-v-medium.png");
    palisadeVDark = await loadImage("images/palisade-v-dark.png");
    graveBright = await loadImage("images/grave-bright.png");
    graveMedium = await loadImage("images/grave-medium.png");
    graveDark = await loadImage("images/grave-dark.png");
    circle64 = await loadImage("images/circle-64.png");
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
    treeStumpBright = await loadImage("images/tree-stump-bright.png");
    treeStumpMedium = await loadImage("images/tree-stump-medium.png");
    treeStumpDark = await loadImage("images/tree-stump-dark.png");
    rockSmallBright = await loadImage("images/rock-small-bright.png");
    rockSmallMedium = await loadImage("images/rock-small-medium.png");
    rockSmallDark = await loadImage("images/rock-small-dark.png");
    manRunning = await loadImage("images/man-running.png");
    manFiringHandgun = await loadImage("images/man-firing-handgun.png");
    manFiringShotgun = await loadImage("images/man-firing-shotgun.png");
    manChanging = await _png("man-changing");
    manDying = await _png("man-dying");
    manStriking = await _png("man-striking");
    manWalking = await _png("man-walking");
    manWalkingBright = await _png("man-walking-bright");
    manIdle = await _png("man-idle");
    manIdleBright = await _png("man-idle-bright");
    zombieWalkingBright = await _png("zombie-walking-bright");
    zombieWalkingMedium = await _png("zombie-walking-medium");
    zombieWalkingDark = await _png("zombie-walking-dark");
    zombieDyingBright = await _png("zombie-dying-bright");
    zombieDyingMedium = await _png("zombie-dying-medium");
    zombieDyingDark = await _png("zombie-dying-dark");
    zombieStriking = await _png("zombie-striking");
    zombieIdleBright = await _png("zombie-idle-bright");
    zombieIdleMedium = await _png("zombie-idle-medium");
    zombieIdleDark = await _png("zombie-idle-dark");
    empty = await _png("empty");
    flames.add(torch_01);
    flames.add(torch_02);
    flames.add(torch_03);

    torch = torch_01;
  }
}


