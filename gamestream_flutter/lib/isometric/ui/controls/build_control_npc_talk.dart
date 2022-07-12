
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/utils/string_utils.dart';

import '../widgets/nothing.dart';

Widget buildControlNpcTalk(String? value) =>
    isNullOrEmpty(value) ? nothing : text(value);

Widget buildControlNpcTopics(List<String> topics) =>
  Column(
    children: topics.map((String value) {
      return container(
          child: value,
          action: () {
            sendClientRequestNpcSelectTopic(topics.indexOf(value));
          }
      );
    }).toList(),
  );