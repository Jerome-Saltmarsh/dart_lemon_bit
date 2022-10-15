import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game_state.dart';

Widget buildColumnGameObjects() => Refresh(() => SingleChildScrollView(
      child: Column(
        children: List.generate(GameState.totalGameObjects, (index) => GameState.gameObjects[index])
            .map((e) => text(e.type))
            .toList(),
      ),
    ));
