import 'dart:ui' as ui;
import 'dart:ui';

import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:golden_ratio/constants.dart';
import 'package:http/http.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_icon_type.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/gamestream/ui/src.dart';
import 'package:amulet_flutter/packages/utils.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


class IsometricUI with IsometricComponent {
  static const Icon_Scale = 1.5;

  final dialog = Watch<Widget?>(null, onChanged: (value){
    print('isometricUI.onChangedDialog()');
  });
  final gameUI = Watch<WidgetBuilder?>(null, onChanged: (value){
    print('isometricUI.onChangedGameUI($value)');
  });
  final error = Watch<String?>(null, onChanged: (value){
    print('isometricUI.onChangedError()');
  });

  @override
  void onComponentReady() {
    gameUI.value = website.buildUI;
    print('isometric_ui.onComponentReady()');
    // engine.fullScreenEnter();
  }

  Widget buildUI(BuildContext context) => GSFullscreen(
      child: Stack(
        children: [
              Positioned(
                top: 0,
                left: 0,
                child: buildWatch(gameUI, (builder) => builder?.call(context) ?? nothing),
              ),
             Positioned(
                 top: 0,
                 left: 0,
                 child: buildWatch(dialog, (dialog) => dialog == null
                     ? nothing : GSFullscreen(
                     alignment: Alignment.center,
                     color: Colors.black45,
                     child: dialog)
                 ),
             ),
             Positioned(
               top: 0,
               child: buildError(),
             ),
        ],
      ),
    );

  Widget buildError() => buildWatch(error, (error) => error == null
                 ? nothing
                 : GSFullscreen(
             alignment: Alignment.center,
            color: Colors.black45,
             child: buildBorder(
               color: style.containerColorDark,
               child: GSContainer(
                   width: 350,
                   height: 350 * goldenRatio_0618,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       buildText(error, color: Colors.red),
                       height16,
                       onPressed(
                         action: () => this.error.value = null,
                         child: GSContainer(
                           color: Colors.white12,
                           width: 80,
                           child: buildText('Okay'),
                         ),
                       )
                     ],
                   )),
             ),
           ));

  void closeDialog() {
    dialog.value = null;
  }

  Widget buildButtonCloseDialog() =>
    onPressed(
      action: closeDialog,
      child: buildText('OKAY'),
    );

  Widget buildMapCircle({required double size}) {
    return IgnorePointer(
      child: Container(
        width: size + 3,
        height: size + 3,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black38, width: 3),
            color: Colors.black38
        ),
        child: ClipOval(
          child: Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              width: size,
              height: size,
              child: buildGeneratedMiniMap(translate: size / 4.0)),
        ),
      ),
    );
  }

  Widget buildWindowMenu({List<Widget>? children, double width = 200}) =>
      GSContainer(
        child: Container(
          width: width,
          alignment: Alignment.center,
          color: style.containerColor,
          padding: style.containerPadding,
          child: IsometricBuilder(
            builder: (context, isometric) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  onPressed(
                    action: audio.toggleMutedSound,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('SOUND', size: 20, color: Colors.white70),
                          buildWatch(audio.enabledSound, buildIconCheckbox),
                        ],
                      ),
                    ),
                  ),
                  height6,
                  onPressed(
                    action: audio.toggleMutedMusic,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('MUSIC', size: 20, color: Colors.white70),
                          buildWatch(audio.mutedMusic, (bool muted) => buildIconCheckbox(!muted)),
                        ],
                      ),
                    ),
                  ),
                  height6,
                  onPressed(
                    action: isometric.engine.fullscreenToggle,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('FULLSCREEN', size: 20, color: Colors.white70),
                          buildWatch(isometric.engine.fullScreen, buildIconCheckbox),
                        ],
                      ),
                    ),
                  ),
                  if (children != null)
                    height6,
                  if (children != null)
                    ...children,
                  height24,
                  onPressed(
                    action: server.disconnect,
                    child: buildText('DISCONNECT', size: 25),
                  ),
                  height24,
                ],
              );
            }
          ),
        ),
    );

  /// old map
  Widget buildGeneratedMiniMap({required double translate}) =>
      buildWatch(scene.nodesChangedNotifier, (_) =>
          engine.buildCanvas(paint: (Canvas canvas, Size size) {
            const scale = 2.0;
            canvas.scale(scale, scale);
            final screenCenterX = size.width * 0.5;
            final screenCenterY = size.height * 0.5;
            const ratio = 2 / 48.0;

            final chaseTarget = camera.target;
            if (chaseTarget != null){
              final targetX = chaseTarget.renderX * ratio;
              final targetY = chaseTarget.renderY * ratio;
              final cameraX = targetX - (screenCenterX / scale) - translate;
              final cameraY = targetY - (screenCenterY / scale) - translate;
              canvas.translate(-cameraX, -cameraY);
            }

            final totalCharacters = scene.totalCharacters;
            final characters = scene.characters;
            for (var i = 0; i < totalCharacters; i++) {
              final character = characters[i];
              final isPlayer = player.isCharacter(character);
              renderCanvas(
                  canvas: canvas,
                  image: images.atlas_gameobjects,
                  srcX: 0,
                  srcY: isPlayer ? 96 : character.allie ? 81 : 72,
                  srcWidth: 8,
                  srcHeight: 8,
                  dstX: character.renderX * ratio,
                  dstY: character.renderY * ratio,
                  scale: 0.25
              );
            }
      }));

  Positioned buildPositionedMessageStatus() => Positioned(
    bottom: 150,
    child: IgnorePointer(
      child: Container(
        width: engine.screen.width,
        alignment: Alignment.center,
        child: buildWatch(options.messageStatus, buildMessageStatus),
      ),
    ),
  );

  Widget buildMessageStatus(String message){
    if (message.isEmpty) return nothing;
    return MouseRegion(
      onEnter: (_){
        actions.messageClear();
      },
      child: onPressed(
        action: actions.messageClear,
        child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black12,
            child: buildText(message),
        ),
      ),
    );
  }

  Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: buildWatch(
          options.rendersSinceUpdate,
              (int frames) =>
              buildText('Warning: No message received from server $frames')));

  Widget buildMainMenu({List<Widget>? children}) {
    final controlTime = buildTime();
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        options.windowOpenMenu.value = true;
      },
      onExit: (PointerExitEvent event) {
        options.windowOpenMenu.value = false;
      },
      child: buildWatch(options.windowOpenMenu, (bool menuVisible){
        return Container(
          color: menuVisible ? style.containerColor : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              height16,
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buildWatch(options.sceneName, (sceneName) => buildText(sceneName, color: Colors.white70, size: 22)),
                    width16,
                    buildWatchBool(options.timeVisible, () => controlTime),
                    width32,
                    menuVisible ? buildIconCogTurned() : buildIconCog(),
                    width16,
                  ]
              ),
              if (menuVisible)
                buildWindowMenu(children: children),
            ],
          ),
        );
      }),
    );
  }

  Widget buildIconAudioSound() =>
      onPressed(
        hint: 'toggle sound',
        action: audio.toggleMutedSound,
        child: Container(
          width: 32,
          child: buildWatch(audio.enabledSound, (bool t) =>
              buildAtlasIconType(t ? IconType.Sound_Enabled : IconType.Sound_Disabled, scale: Icon_Scale)
          ),
        ),
      );

  Widget buildIconAudioMusic() =>
      onPressed(
        hint: 'toggle music',
        action: audio.toggleMutedMusic,
        child: buildWatch(audio.mutedMusic, (bool musicMuted) =>
            Container(
                width: 32,
                child: buildAtlasIconType(musicMuted ? IconType.Music_Disabled : IconType.Music_Enabled))
        ),
      );

  Widget buildIconFullscreen() => WatchBuilder(
      engine.fullScreen,
          (bool fullscreen) => onPressed(
          hint: 'toggle fullscreen',
          action: engine.fullscreenToggle,
          child: Container(
              width: 32,
              child: buildAtlasIconType(IconType.Fullscreen, scale: Icon_Scale))));

  Widget buildIconZoom() => onPressed(
      action: actions.toggleZoom, child: buildAtlasIconType(IconType.Zoom, scale: Icon_Scale));

  Widget buildIconMenu() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Home),
      )
  );

  Widget buildIconCog() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 20,
        child: buildAtlasIconType(IconType.Cog, color: Colors.white54.value),
      )
  );

  Widget buildIconCogTurned() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 20,
        child: buildAtlasIconType(IconType.Cog_Turned),
      )
  );

  Widget buildAtlasIconType(
      IconType iconType,
      {
        double scale = 1,
        int? color,
      }
  ) {

    final src = atlasSrcIconType[iconType] ??
        (throw Exception('atlasSrcIconType[$iconType] is null'));

    if (src.length != 4) {
      throw Exception('atlasSrcIconType[$iconType] invalid src length ${src.length}');
    }

    if (src[2] <= 0){
      throw Exception('atlasSrcIconType[$iconType] width <= 0');
    }

    if (src[3] <= 0){
      throw Exception('atlasSrcIconType[$iconType] height <= 0');
    }

    return FittedBox(
        child: engine.buildAtlasImage(
          image: images.atlas_icons,
          srcX: src[0],
          srcY: src[1],
          srcWidth: src[2],
          srcHeight: src[3],
          scale: scale,
          color: color,
        ),
      );
  }

  Widget buildAtlasNodeType(int nodeType) => engine.buildAtlasImage(
    image: images.atlas_nodes,
    srcX: AtlasNodeX.mapNodeType(nodeType),
    srcY: AtlasNodeY.mapNodeType(nodeType),
    srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
    srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
  );

  Widget buildItemTypeBars(int amount) => Row(
      children: List.generate(5, (i) => Container(
        width: 8,
        height: 15,
        color: i < amount ? Colors.blue : Colors.blue.withOpacity(0.5),
        margin: i < 4 ? const EdgeInsets.only(right: 5) : null,
      )
      )
  );

  Widget buildRowItemTypeLevel(int level){
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 5,
          height: 20,
          color: index < level ? Colors.blue : Colors.blue.withOpacity(0.5),
          margin: const EdgeInsets.only(right: 2),
        );
      }),
    );
  }

  Widget buildTime() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      WatchBuilder(environment.hours, (int hours) =>
          buildText(padZero(hours), size: 22)),
      buildText(':', size: 22),
      WatchBuilder(environment.minutes, (int minutes) =>
          buildText(padZero(minutes), size: 22)),
    ],
  );

  int getItemTypeIconColor(int itemType){
    return const <int, int> {

    }[itemType] ?? 0;
  }

  Widget buildIconCheckbox(bool value) => Container(
    width: 32,
    child: buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
  );

  static Decoration buildDecorationBorder({
    required Color colorBorder,
    required Color colorFill,
    required double width,
    double borderRadius = 0.0,
  }) =>
      BoxDecoration(
          border: Border.all(color: colorBorder, width: width),
          borderRadius: BorderRadius.circular(borderRadius),
          color: colorFill
      );

  Widget buildImageGameObject(int objectType) =>
      buildImageFromSrc(
        images.atlas_gameobjects,
        Atlas.getSrc(ItemType.Object, objectType),
      );

  Widget buildImageFromSrc(ui.Image image, List<double> src) =>
      IsometricBuilder(builder: (context, isometric) =>
          isometric.engine.buildAtlasImage(
            image: image,
            srcX: src[Atlas.SrcX],
            srcY: src[Atlas.SrcY],
            srcWidth: src[Atlas.SrcWidth],
            srcHeight: src[Atlas.SrcHeight],
          ));

  void showDialogGetString({
    required Function(String value) onSelected,
    String? text = '',
  }) {
    final controller = TextEditingController(text: text);
    showDialog(
      onOpen: engine.disableKeyEventHandler,
      onClosed: engine.enableKeyEventHandler,
      child: OnDisposed(
      child: GSContainer(
        width: 300,
        height: 200,
        child: Column(
          children: [
            Container(
              height: 80,
              width: 150,
              child: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white70),
                onChanged: (value) {
                  print('onChanged($value)');
                  controller.text = value;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                onPressed(
                  action: closeDialog,
                  child: buildText('Cancel'),
                ),
                onPressed(
                  action: () {
                    onSelected(controller.text);
                    controller.dispose();
                    closeDialog();
                  },
                  child: buildText('OKAY'),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void showDialogText({
    Function? onClosed,
    required String text,
  }) {
    showDialog(
      onOpen: engine.disableKeyEventHandler,
      onClosed: engine.enableKeyEventHandler,
      child: OnDisposed(
      child: GSContainer(
        width: 300,
        height: 200,
        child: Column(
          children: [
            buildText(text),
            const Expanded(child: SizedBox()),
            alignRight(
              child: onPressed(
                action: onClosed ?? closeDialog,
                child: buildText('OKAY', color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void showDialogGetInt({
    required Function(int value) onSelected,
    String text = '',
  }) {
    final controller = TextEditingController(text: text);
    showDialog(
      onOpen: engine.disableKeyEventHandler,
      onClosed: engine.enableKeyEventHandler,
      child: OnDisposed(
      child: GSContainer(
        width: 300,
        height: 200,
        child: Column(
          children: [
            Container(
              height: 80,
              width: 150,
              child: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white70),
                onChanged: (value) {
                  print('onChanged($value)');
                  controller.text = value;
                },
              ),
            ),
            onPressed(
              action: () {
                onSelected(int.parse(controller.text));
                controller.dispose();
                closeDialog();
              },
              child: buildText('OKAY'),
            ),
          ],
        ),
      ),
    ));
  }

  void showDialogGetBool({
    required Function(bool value) onSelected,
    String text = '',
    String textTrue = 'YES',
    String textFalse = 'NO',
  }) {
    showDialog(
      child: GSContainer(
        width: 300,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildText(text),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 onPressed(
                     action: () {
                       closeDialog();
                       onSelected(true);
                     },
                     child: buildText(textTrue),
                 ),
                 width16,
                 onPressed(
                     action: () {
                       closeDialog();
                       onSelected(false);
                     },
                     child: buildText(textFalse),
                 ),
               ],
            ),
          ],
        ),
      ));
  }

  void showDialogGetHairType({
    required Function(int value) onSelected,
  }){
    this.showDialog(child: GSContainer(
      width: 150,
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: HairType.values
              .map((hairType) {
                return onPressed(
                action: () {
                  onSelected(hairType);
                  closeDialog();
                },
                child: buildText(HairType.getName(hairType)));
              })
              .toList(growable: false),
        ),
      ),
    ));
  }

  void showDialogColorPicker({
    required ValueChanged<Color> onChanged,
    Color? initialColor,
  }) =>
    showDialog(child: GSContainer(
      width: 400,
      height: 600,
      child: Column(
        children: [
          ColorPicker(
            portraitOnly: true,
            pickerColor: initialColor ?? Colors.white,
            onColorChanged: onChanged,
          ),
          buildButtonCloseDialog(),
        ],
      ),
    ));

  void showDialogGetColor({
    required Function(int index) onSelected,
    bool closeOnSelected = true,
  }) => showDialog(
      child: GSContainer(
        width: 682,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('select color', color: Colors.white70),
              onPressed(
                  action: closeDialog,
                  child: buildText('close')
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: colors.shades.map((shade) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: shade.map((color) => onPressed(
                  action: () {
                    onSelected(colors.palette.indexOf(color));
                    if (closeOnSelected) {
                      closeDialog();
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    color: color,
                  ),
                )).toList(growable: false),
              )).toList(growable: false))
        ])
      )
    );

  void showDialogBlendMode({
    required Function(BlendMode value) onSelected,
  }) => showDialog(
      child: GSContainer(
        width: 682,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('select blend mode', color: Colors.white70),
              onPressed(
                  action: closeDialog,
                  child: buildText('close')
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: BlendMode.values
                  .map((blendMode) => onPressed(
                action: () {
                  onSelected(blendMode);
                  closeDialog();
                },
                  child: buildText(blendMode.name)))
                  .toList(growable: false))
        ])
      )
    );

  void showDialogValues<T>({
    required String title,
    required List<T> values,
    required Widget Function(T t) buildItem,
    required Function(T value) onSelected,
    double height = 400,
  }) => showDialog(
      child: GSContainer(
        width: height * goldenRatio_0618,
        height: height,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText(title, color: Colors.white70),
              onPressed(
                  action: closeDialog,
                  child: buildText('close')
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: values
                    .map((value) => onPressed(
                  action: () {
                    onSelected(value);
                    closeDialog();
                  },
                    child: buildItem(value)))
                    .toList(growable: false)),
          )
        ])
      )
    );

  void showDialog({required Widget child, Function? onClosed, Function? onOpen}){
    onOpen?.call();
    dialog.value = OnDisposed(
      action: onClosed,
      child: child,
    );
  }

  Future handleException(Object exception) async {
    if (exception is ClientException){
      error.value = exception.message;
    } else {
      error.value = exception.toString();
    }

  }
}
