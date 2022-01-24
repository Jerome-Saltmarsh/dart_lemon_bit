import 'core/module.dart';
import 'editor/module.dart';
import 'game/module.dart';
import 'website/module.dart';

class Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final editor = EditorModule();
  final game = GameModule();
}
