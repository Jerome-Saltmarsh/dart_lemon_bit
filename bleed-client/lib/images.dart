import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/game_resources.dart';

_Images images = _Images();

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
  Image radial64;

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
    radial64 = await loadImage("images/radial-64.png");
  }
}


