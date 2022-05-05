import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/ui/functions/build_health_bar.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_menu.dart';

import 'build_panel.dart';
import 'build_panel_resources.dart';
import 'build_panel_structures.dart';
import 'build_panel_tech.dart';
import 'build_time.dart';

Widget buildPanelPrimary() {
  return Positioned(
      top: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPanelMenu(),
          height6,
          buildPanel(child: buildTime()),
          height6,
          buildHealthBar(),
          height6,
          buildPanelResources(),
          height6,
          buildPanelTech(),
          height6,
          buildPanelStructures(),
        ],
      ));
}
