

import 'actions.dart';
import 'build.dart';
import 'state.dart';

class WebsiteModule {
  final build = WebsiteBuild();
  final state = WebsiteState();
  final actions = WebsiteActions();
}