
import 'package:flutter/material.dart';
import 'package:lemon_engine/src.dart';

Widget buildPage({required List<Widget> children}) =>
    Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        child: Stack(children: children)
    );