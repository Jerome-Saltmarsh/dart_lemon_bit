import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';

Widget buildColumnGameObjects() => Refresh(() => SingleChildScrollView(
      child: Column(
        children: List.generate(totalGameObjects, (index) => gameObjects[index])
            .map((e) => text(e.type))
            .toList(),
      ),
    ));
