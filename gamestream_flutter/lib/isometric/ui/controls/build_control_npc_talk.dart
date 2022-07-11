
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

import '../widgets/nothing.dart';

Widget buildControlNpcTalk(String? value) =>
    value == null ? nothing : text(value);