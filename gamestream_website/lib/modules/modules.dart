
import 'core/module.dart';
import 'game/module.dart';
import 'website/module.dart';

final modules = Modules();
final core = modules.core;
final website = modules.website;

class Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final game = GameModule();
}



