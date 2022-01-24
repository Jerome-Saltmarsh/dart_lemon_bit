
import 'package:bleed_client/website/actions.dart';
import 'package:bleed_client/website/build.dart';
import 'package:bleed_client/website/state.dart';

class WebsiteModule {
  final build = WebsiteBuild();
  final state = WebsiteState();
  final actions = WebsiteActions();
}