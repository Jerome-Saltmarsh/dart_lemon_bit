import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

Watch<double> download = Watch(0);

Widget buildLoadingScreen(BuildContext context) {
  return WatchBuilder(download, (double value){
    print("download $value");
    return text("DOWNLOADING ${(value * 100).toInt()}%", color: Colors.black);
  });
}
