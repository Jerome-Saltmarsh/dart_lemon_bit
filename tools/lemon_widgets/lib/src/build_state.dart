import 'package:flutter/material.dart';
import 'typedefs/plain_builder.dart';


Widget buildState(Widget Function(Function rebuild) rebuild) =>
    StatefulBuilder(builder: (context, setState) =>
        rebuild(
          () {
            setState(() {});
          }),
    );