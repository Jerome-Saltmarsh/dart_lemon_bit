

import 'package:amulet/enums/src.dart';
import 'package:amulet_client/ui/builders/build_watch.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class GSButtonRegion extends StatelessWidget {

  final Watch<ConnectionRegion> region;
  final Function action;

  const GSButtonRegion({
    super.key,
    required this.region,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return buildWatch(region, (region) =>
        onPressed(
          hint: 'REGION',
          action: action,
          child: Container(
            height: 30,
            width: 100,
            alignment: Alignment.center,
            color: Colors.white12,
            child: buildText(region.name.clean),
          ),
        ));
  }
}