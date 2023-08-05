import 'package:flutter/material.dart';
import 'package:lemon_sprites/sprites/sprite.dart';
import 'package:lemon_sprites/sprites/style.dart';
import 'package:lemon_sprites/ui/sprite_app.dart';

void main() {
  runApp(
      SpriteApp(
      sprite: Sprite(),
      style: Style(),
    )
  );
}



