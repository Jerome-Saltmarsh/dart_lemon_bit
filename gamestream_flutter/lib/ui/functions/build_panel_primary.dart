import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_health_bar.dart';

import 'build_panel_tech.dart';
import 'build_resource_panel.dart';
import 'build_time.dart';

Widget buildPanelPrimary() {
  return Positioned(
      top: 200,
      right: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTime(),
          height6,
          buildHealthBar(),
          height6,
          buildResourcePanel(),
          height6,
          buildPanelTech()
        ],
      ));
}
