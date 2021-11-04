import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../images.dart';
import '../../state/settings.dart';
import '../../utils.dart';

class BleedWidget extends GameWidget {

  @override
  Future init() async {
    await images.load();
    initUI();
    rebuildUI();
  }
}
