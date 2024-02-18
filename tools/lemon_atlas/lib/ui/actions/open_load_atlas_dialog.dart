import 'package:flutter/material.dart';
import 'package:lemon_atlas/ui/build/build_load_atlas_dialog.dart';

void showDialogLoadImage(BuildContext context) =>
    showDialog(context: context, builder: (dialogContext) =>
        buildLoadAtlasDialog(context));

