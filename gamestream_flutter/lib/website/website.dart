
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';


import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/modules/core/events.dart';
import 'package:lemon_watch/watch.dart';

class Website {
  static final operationStatus = Watch(OperationStatus.None);
  static final error = Watch<String?>(null);
  static final account = Watch<Account?>(null);
  static final region = Watch(Region.LocalHost, onChanged: onChangedRegion);
  static final download = Watch(0.0);
  static final debug = true;

   static void renderCanvas(Canvas canvas, Size size){
      Engine.renderSprite(
          image: Images.characters,
          srcX: 0,
          srcY: 0,
          srcWidth: 64,
          srcHeight: 64,
          dstX: 100,
          dstY: 100,
      );
      Engine.renderSprite(
        image: Images.blocks,
        srcX: 0,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 72,
        dstX: 200,
        dstY: 100,
      );
   }

   static void update(){

   }

   static Widget buildUI(BuildContext context){
     return modules.core.build.buildUI();
   }
}