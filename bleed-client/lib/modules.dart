import 'package:bleed_client/modules/core/module.dart';
import 'package:bleed_client/modules/editor/module.dart';
import 'package:bleed_client/modules/website/module.dart';

import 'modules/modules.dart';

final modules = Modules();
CoreModule get core => modules.core;
WebsiteModule get website => modules.website;
EditorModule get editor => modules.editor;
