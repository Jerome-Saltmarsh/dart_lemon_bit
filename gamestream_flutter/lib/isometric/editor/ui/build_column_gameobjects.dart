import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_widgets.dart';

Widget buildColumnGameObjects() => Refresh(() => SingleChildScrollView(
      child: Column(
        children: List.generate(Game.totalGameObjects, (index) => Game.gameObjects[index])
            .map((e) => text(e.type))
            .toList(),
      ),
    ));
