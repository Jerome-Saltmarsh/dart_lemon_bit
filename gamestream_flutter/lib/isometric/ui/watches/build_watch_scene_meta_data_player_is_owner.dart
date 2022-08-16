import 'package:bleed_common/library.dart';
import 'package:bleed_common/spawn_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_show_game_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stacks_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/screen.dart';

import '../widgets/build_container.dart';

Widget buildPlayMode(Mode mode) {
  return mode == Mode.Play ? buildStackPlay() : buildStackEdit();
}

Stack buildStackEdit() {
  return Stack(
    children: [
      Positioned(
        left: 0,
        bottom: 6,
        child: Column(
          children: [
            buildColumnObjects(),
            buildColumnSelected(),
            buildControlPaint(),
            buildWatchEditorTab(),
          ],
        ),
      ),
      Positioned(
          bottom: 6,
          left: 0,
          child: buildControlsEnvironment()
      ),
      Positioned(
        left: 0,
        top: 0,
        child: buildTopLeftMenu(),
      ),
      Positioned(
        right: 8,
        top: 100,
        child: visibleBuilder(edit.gameObjectSelected,
            Container(
              color: brownLight,
              padding: const EdgeInsets.all(6),
              child: watch(edit.gameObjectSelectedType, (int type){
                return Column(
                    children: [
                      text(GameObjectType.getName(type)),
                      if (type == GameObjectType.Spawn)
                        watch(edit.gameObjectSelectedSpawnType, (int spawnType){
                           return container(
                               child: "Spawns: ${SpawnType.getName(spawnType)}",
                               action: sendGameObjectRequestSpawnTypeIncrement,
                           );
                        }),
                    ],
                );
              }),
            )
        ),
      )
    ],
  );
}

Column buildColumnObjects() {
  return Column(
            children: [
              text("Objects"),
              Container(
                height: 150,
                child: Refresh((){
                  return SingleChildScrollView(
                    child: Column(
                      children: gameObjects.map((gameObject){
                        return container(
                            child: GameObjectType.getName(gameObject.type),
                            // action: () => edit.selectGameObject(gameObject)
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ],
          );
}

Column buildColumnSelected() {
  return Column(
            children: [
              container(child: "Selected", color: brownLight),
              container(
                 child: Row(
                   children: [
                     container(child: "-", width: 50, action: ()=> edit.z.value--, toolTip: "Shift + Down Arrow"),
                     watch(edit.z, (t) {
                       return container(child: 'Z: $t', width: 92);
                     }),
                     container(child: "+", width: 50, action: ()=> edit.z.value++, toolTip: "Shift + Up Arrow"),
                   ],
                 )
              ),
            ],
          );
}

Column buildControlPaint() {
  return Column(
            children: [
              container(child: "Paint", color: brownLight, toolTip: "Press F to paint. Press R to copy selected type"),
              watch(edit.paintType, buildPaintType),
            ],
          );
}

Widget buildPaintType(int type) =>
  container(child: GridNodeType.getName(type));

Row buildTopLeftMenu() {
  return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            onMouseOver(
                builder: (context, over) {
                  if (over){
                    return Column(
                      children: [
                        container(child: "File", color: brownLight),
                        container(child: "New", color: brownLight, action: (){
                          core.actions.exitGame();
                          connectToGameEditor();
                        }, hoverColor: brownDark),
                        container(child: "Save", color: brownLight, action: actionGameDialogShowSceneSave, hoverColor: brownDark),
                        container(child: "Load", color: brownLight, action: actionGameDialogShowSceneLoad, hoverColor: brownDark),
                        container(child: "Exit", color: brownLight, action: core.actions.exitGame, hoverColor: brownDark),
                      ],
                    );
                  }
                  return container(child: "File", color: brownLight);
                }
            ),
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "Edit", color: brownLight),
                      container(child: "Canvas Size", color: brownLight, hoverColor: brownDark, action: actionGameDialogEditCanvasSizeShow),
                      container(child: "Floor Bricks", color: brownLight, hoverColor: brownDark, action: edit.paintFloorBricks),
                    ],
                  );
                }

                return container(child: "Edit", color: brownLight);
              }
            ),
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "View", color: brownLight),
                      container(child: "Weather", color: brownLight, hoverColor: brownDark, action: edit.actionToggleControlsVisibleWeather),
                      container(child: "Grid", color: brownLight, hoverColor: brownDark),
                    ],
                  );
                }
                return container(child: "View", color: brownLight);
              }
            ),
            buildMenu(
                text: "Insert",
                children: GameObjectType.staticValues
                    .map(buildButtonAddGameObject)
                    .toList(),
            )
          ],
        );
}

Widget buildButtonAddGameObject(int type) {
  return container(
      child: GameObjectType.getName(type),
      color: brownLight,
      action: (){
        sendClientRequestAddGameObject(
          x: edit.posX,
          y: edit.posY,
          z: edit.posZ,
          type: type,
        );
      });
}

Widget buildMenu({required String text, required List<Widget> children}){
  final child = container(child: text, color: brownLight);
  return onMouseOver(
      builder: (context, over) {
        if (over){
          return Column(
            children: [
              child,
              Container(
                height: screen.height - 100,
                child: SingleChildScrollView(
                  child: Column(
                     children: children,
                  ),
                ),
              )
            ],
          );
        }
        return child;
      }
  );
}

