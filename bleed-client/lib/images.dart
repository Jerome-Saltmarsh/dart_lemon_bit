import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/game_resources.dart';

_Images images = _Images();

class _Images {
  Image character;
  Image zombie;
  Image tiles;
  Image particles;
  Image handgun;
  Image handgunAmmo;
  Image collectables;
  Image shotgunAmmo;
  Image items;
  Image crate;
  Image house;
  Image house02;
  Image tree;
  Image rock;

  Future load() async {
    character = await loadImage("images/character.png");
    zombie = await loadImage("images/zombie.png");
    tiles = await loadImage("images/tiles-02.png");
    particles = await loadImage('images/particles.png');
    handgun = await loadImage('images/weapon-handgun.png');
    handgunAmmo = await loadImage('images/handgun-ammo.png');
    shotgunAmmo = await loadImage('images/shotgun-ammo.png');
    collectables = await loadImage("images/collectables.png");
    items = await loadImage("images/items.png");
    crate = await loadImage("images/crate.png");
    house = await loadImage("images/house.png");
    house02 = await loadImage("images/house02.png");
    tree = await loadImage("images/tree.png");
    rock = await loadImage("images/rock.png");
  }
}


