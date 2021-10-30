import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/engine/functions/loadImage.dart';

final _Images images = _Images();

class _Images {
  Image human;
  Image zombie;
  Image tiles;
  Image particles;
  Image handgun;
  Image items;
  Image crate;
  Image house;
  Image house02;
  Image tree01;
  Image tree02;
  Image rock;
  Image palisade;
  Image palisadeH;
  Image palisadeV;
  Image grave;
  Image circle64;
  Image radial64_50;
  Image radial64_40;
  Image radial64_30;
  Image radial64_20;
  Image radial64_10;
  Image radial64_05;
  Image radial64_02;
  Image torch_01;
  Image torch_02;
  Image torch_03;
  Image bridge;
  Image treeStump;
  Image rockSmall;
  Image isoCharacter;
  Image man;
  Image manRunning;
  Image manFiringHandgun;
  Image manFiringShotgun;
  Image manChanging;
  Image manDying;
  Image manStriking;


  List<Image> flames = [];

  Future<Image> _png(String fileName){
    return loadImage('images/$fileName.png');
  }

  Future load() async {
    human = await loadImage("images/character.png");
    zombie = await loadImage("images/zombie.png");
    tiles = await loadImage("images/tiles-02.png");
    particles = await loadImage('images/particles.png');
    handgun = await loadImage('images/weapon-handgun.png');
    items = await loadImage("images/items.png");
    crate = await loadImage("images/crate.png");
    house = await loadImage("images/house.png");
    house02 = await loadImage("images/house02.png");
    tree01 = await loadImage("images/tree01.png");
    tree02 = await loadImage("images/tree02.png");
    rock = await loadImage("images/rock.png");
    palisade = await loadImage("images/palisade02.png");
    palisadeH = await loadImage("images/palisade-h.png");
    palisadeV = await loadImage("images/palisade-v.png");
    grave = await loadImage("images/grave.png");
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
    bridge = await loadImage("images/bridge.png");
    treeStump = await loadImage("images/tree-stump.png");
    rockSmall = await loadImage("images/rock-small.png");
    man = await loadImage("images/man.png");
    manRunning = await loadImage("images/man-running.png");
    manFiringHandgun = await loadImage("images/man-firing-handgun.png");
    manFiringShotgun = await loadImage("images/man-firing-shotgun.png");
    manChanging = await _png("man-changing");
    manDying = await _png("man-dying");
    manStriking = await _png("man-striking");
    flames.add(torch_01);
    flames.add(torch_02);
    flames.add(torch_03);
  }
}


