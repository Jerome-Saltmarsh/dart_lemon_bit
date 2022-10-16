
import 'game/module.dart';
import 'website/module.dart';

final modules = Modules();
final website = modules.website;

class Modules {
  final website = WebsiteModule();
  final game = GameModule();
}



