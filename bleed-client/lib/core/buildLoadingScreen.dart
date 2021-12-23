import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

Watch<double> download = Watch(0);
const double _width = 300;
const double _height = 50;

Widget buildLoadingScreen(BuildContext context) {
  return WatchBuilder(download, (double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: axis.main.center,
          children: [
            text("DOWNLOADING ${(value * 100).toInt()}%", color: Colors.black),
            Container(
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                color: Colors.black,
                width: _width * value,
                height: _height,
              ),
            )
          ],
        ),
      ],
    );
  });
}
