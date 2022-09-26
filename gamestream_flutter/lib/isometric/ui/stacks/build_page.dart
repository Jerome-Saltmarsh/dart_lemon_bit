
import 'package:flutter/material.dart';
import 'package:lemon_engine/screen.dart';

Widget buildPage({required List<Widget> children}) =>
    Container(
        width: screen.width,
        height: screen.height,
        child: Stack(children: children)
    );