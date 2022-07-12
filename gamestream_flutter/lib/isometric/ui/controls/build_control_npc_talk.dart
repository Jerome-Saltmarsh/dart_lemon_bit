
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/utils/string_utils.dart';

import '../widgets/nothing.dart';

Widget buildControlNpcTalk(String? value) =>
    isNullOrEmpty(value) ? nothing : text(value);

Widget buildControlNpcTopics(List<String> topics) =>
  Column(
    children: topics.map(text).toList(),
  );