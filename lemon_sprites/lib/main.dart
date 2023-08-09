import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lemon_sprites/sprites/sprite.dart';
import 'package:lemon_sprites/sprites/style.dart';
import 'package:lemon_sprites/ui/sprite_app.dart';


void main() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
      SpriteApp(
      sprite: Sprite(),
      style: Style(),
    )
  );
}



