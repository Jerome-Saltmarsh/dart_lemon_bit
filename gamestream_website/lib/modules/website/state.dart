
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class WebsiteState {
  final Watch<bool> signInSuggestionVisible = Watch(false);
  final Watch<WebsiteDialog> dialog = Watch(WebsiteDialog.Games);
}