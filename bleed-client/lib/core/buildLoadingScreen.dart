import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

Watch<double> download = Watch(0);
const double _width = 300;
const double _height = 50;

Widget buildLoadingScreen(BuildContext context) {
  print(colours.black.value.toRadixString(16));

  return fullScreen(
    color: colours.black,
    child: WatchBuilder(download, (double value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: axis.main.center,
            children: [
              text("GAMESTREAM ${(value * 100).toInt()}%", color: Colors.white),
              height8,
              Container(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
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
    }),
  );
}
