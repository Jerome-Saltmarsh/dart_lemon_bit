
import 'package:bleed_client/website/actions.dart';
import 'package:bleed_client/website/builder.dart';
import 'package:bleed_client/website/state.dart';

final Website website = Website();

class Website {
  final build = WebsiteBuilder();
  final state = WebsiteState();
  final actions = WebsiteActions();
}