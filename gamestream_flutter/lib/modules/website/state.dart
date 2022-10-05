
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class WebsiteState {
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
}