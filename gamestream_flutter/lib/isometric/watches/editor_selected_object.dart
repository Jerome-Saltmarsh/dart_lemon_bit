import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_editor_selected_object.dart';
import 'package:lemon_watch/watch.dart';

final editorSelectedObject = Watch<Vector3?>(null, onChanged: onChangedEditorSelectedObject);