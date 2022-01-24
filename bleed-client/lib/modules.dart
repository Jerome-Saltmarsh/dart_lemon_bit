
import 'modules/core/module.dart';
import 'modules/editor/module.dart';
import 'modules/website/module.dart';

final modules = _Modules();

get core => modules.core;
get website => modules.website;
get editor => modules.editor;

class _Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final EditorModule editor = EditorModule();
}
