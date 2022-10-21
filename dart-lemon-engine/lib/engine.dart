library lemon_engine;
import 'dart:convert';

import 'package:universal_html/html.dart';


import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart' as us;

/// boilerplate code for game development
///
///
/// __event-hooks__
///
/// event hooks start with the word 'on'
///
/// event hooks are safe to override
///
/// event hooks can be overridden during runtime
///
/// ```dart
/// Engine.onLeftClicked = () => print("left mouse clicked');
/// ```
///
/// __getting started__
/// ```dart
///void main() {
///   Engine.run(
///     title: "My Game Name",
///     buildUI: (BuildContext context) => Text("Welcome"),
///     backgroundColor: Colors.red,
///   );
/// }
/// ```
class Engine {
  // HOOKS
  /// the following hooks are designed to be easily swapped in and out without inheritance
  /// override safe. run this snippet inside your initialization code.
  /// engine.onTapDown = (TapDownDetails details) => print('tap detected');
  static GestureTapDownCallback? onTapDown;
  /// override safe
  static GestureLongPressCallback? onLongPress;
  /// override safe
  static GestureLongPressDownCallback? onLongPressDown;
  /// override safe
  static GestureDragStartCallback? onPanStart;
  /// override safe
  static GestureDragUpdateCallback? onPanUpdate;
  /// override safe
  static GestureDragEndCallback? onPanEnd;
  /// override safe
  static GestureTapDownCallback? onSecondaryTapDown;
  /// override safe
  static CallbackOnScreenSizeChanged? onScreenSizeChanged;
  /// override safe
  static Function? onDispose;
  /// override safe
  static DrawCanvas? onDrawCanvas;
  /// override safe
  static DrawCanvas? onDrawCanvasForeground;
  /// override safe
  static DrawCanvas? onDrawForeground;
  /// override safe
  static Function? onLeftClicked;
  /// override safe
  static Function? onLongLeftClicked;
  /// override safe
  static Function(PointerScrollEvent value)? onPointerScrolled;
  /// override safe
  static Function? onRightClicked;
  /// override safe
  static Function? onRightClickReleased;
  /// override safe
  static Function(SharedPreferences sharedPreferences)? onInit;
  /// override safe
  static Function? onUpdate;
  /// override safe
  /// gets called when update timer is changed
  static Function? onUpdateTimerReset;
  /// override safe
  static WidgetBuilder? onBuildLoadingScreen;
  /// override safe
  static Function(Object error, StackTrace stack)? onError;

  // VARIABLES
  static final keyState = <LogicalKeyboardKey, bool>{ };
  static final random = Random();
  static var textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
  );
  static final Map<String, TextSpan> textSpans = {
  };
  static late Canvas canvas;
  static final keyboard = RawKeyboard.instance;
  static final paint = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill
    ..isAntiAlias = false
    ..strokeWidth = 1;

  static final spritePaint = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill
    ..isAntiAlias = false
    ..strokeWidth = 1;
  static Timer? updateTimer;
  static var scrollSensitivity = 0.0005;
  static var cameraSmoothFollow = true;
  static var zoomSensitivity = 0.175;
  static var targetZoom = 1.0;
  static var zoomOnScroll = true;
  static var mousePosition = Vector2(0, 0);
  static var previousMousePosition = Vector2(0, 0);
  static var mouseLeftDownFrames = 0;
  static var zoom = 1.0;
  static var drawCanvasAfterUpdate = true;
  static var panStarted = false;
  static late BuildContext buildContext;
  static late final sharedPreferences;
  static final keyboardState = <LogicalKeyboardKey, int>{};
  static final themeData = Watch<ThemeData?>(null);
  static final fullScreen = Watch(false);
  static final deviceType = Watch(DeviceType.Computer);
  static final cursorType = Watch(CursorType.Precise);
  static final notifierPaintFrame = ValueNotifier<int>(0);
  static final notifierPaintForeground = ValueNotifier<int>(0);
  static final screen = _Screen();
  static final camera = Vector2(0, 0);
  static Function(RawKeyDownEvent key)? onKeyDown;
  static Function(RawKeyUpEvent key)? onKeyUp;

  // SETTERS
  static set buildUI(WidgetBuilder? value) => watchBuildUI.value = value;
  static set title(String value) => watchTitle.value = value;
  static set backgroundColor(Color value) => watchBackgroundColor.value = value;

  // GETTERS
  static double get screenDiagonalLength => calculateHypotenuse(screen.width, screen.height);
  static double get screenArea => screen.width * screen.height;
  static WidgetBuilder? get buildUI => watchBuildUI.value;
  static String get title => watchTitle.value;
  static Color get backgroundColor => watchBackgroundColor.value;
  static bool get isLocalHost => Uri.base.host == 'localhost';
  static bool get deviceIsComputer => deviceType.value == DeviceType.Computer;
  static bool get deviceIsPhone => deviceType.value == DeviceType.Phone;
  static int get paintFrame => notifierPaintFrame.value;
  static bool get initialized => watchInitialized.value;

  // WATCHES
  static final watchBackgroundColor = Watch(Default_Background_Color);
  static final watchBuildUI = Watch<WidgetBuilder?>(null);
  static final watchTitle = Watch(Default_Title);
  static final watchInitialized = Watch(false);
  static final watchDurationPerFrame = Watch(Duration(milliseconds: Default_Milliseconds_Per_Frame));
  static final watchMouseLeftDown = Watch(false, onChanged: _internalOnChangedMouseLeftDown);
  static final mouseRightDown = Watch(false);

  // DEFAULTS
  static const Default_Milliseconds_Per_Frame = 30;
  static const Default_Background_Color = Colors.black;
  static const Default_Title = "DEMO";
  // CONSTANTS
  static const Milliseconds_Per_Second = 1000;
  static const PI_2 = pi + pi;
  static const PI_Half = pi * 0.5;
  static const PI_Quarter = pi * 0.25;
  static const PI_Eight = pi * 0.125;
  static const Ratio_Radians_To_Degrees = 57.2958;
  static const Ratio_Degrees_To_Radians = 0.0174533;
  static const GoldenRatio_1_618 = 1.61803398875;
  static const GoldenRatio_1_381 = 1.38196601125;
  static const GoldenRatio_0_618 = 0.61803398875;
  static const GoldenRatio_0_381 = 0.38196601125;


  // QUERIES
  static bool get keyPressedShiftLeft =>
      keyPressed(LogicalKeyboardKey.space);

  static bool get keyPressedSpace =>
      keyPressed(LogicalKeyboardKey.space);

  static bool keyPressed(LogicalKeyboardKey key) =>
      keyState[key] ?? false;

  static void _internalOnKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      keyState[event.logicalKey] = true;
      onKeyDown?.call(event);
      return;
    }
    if (event is RawKeyUpEvent) {
      keyState[event.logicalKey] = false;
      onKeyUp?.call(event);
      return;
    }
  }

  static void _internalOnChangedMouseLeftDown(bool value){
    if (value) {
      onLeftClicked?.call();
    } else {
      mouseLeftDownFrames = 0;
    }
  }

  static void _internalSetScreenSize(double width, double height){
    if (screen.width == width && screen.height == height) return;
    if (!screen.initialized) {
      screen.width = width;
      screen.height = height;
      return;
    }
    final previousScreenWidth = screen.width;
    final previousScreenHeight = screen.height;
    screen.width = width;
    screen.height = height;
    onScreenSizeChanged!.call(
      previousScreenWidth,
      previousScreenHeight,
      screen.width,
      screen.height,
    );
  }

  // ACTIONS

  static void toggleDeviceType() =>
      deviceType.value =
      deviceIsComputer ? DeviceType.Phone : DeviceType.Computer;

  static Future loadBufferImage(String filename) async {
    bufferImage = await loadImageAsset(filename);
  }

  static Future<ui.Image> loadImageAsset(String url) async {
    final byteData = await rootBundle.load(url);
    final bytes = Uint8List.view(byteData.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static TextSpan getTextSpan(String text) {
    var value = textSpans[text];
    if (value != null) return value;
    value = TextSpan(style: TextStyle(color: Colors.white), text: text);
    textSpans[text] = value;
    return value;
  }

  static void writeText(String text, double x, double y) {
    textPainter.text = getTextSpan(text);
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  static void run({
    String title = Default_Title,
    Function(SharedPreferences sharedPreferences)? init,
    Function? update,
    WidgetBuilder? buildUI,
    DrawCanvas? onDrawCanvas,
    ThemeData? themeData,
    GestureTapDownCallback? onTapDown,
    GestureLongPressCallback? onLongPress,
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    CallbackOnScreenSizeChanged? onScreenSizeChanged,
    Function? onDispose,
    DrawCanvas? onDrawForeground,
    Function? onKeyPressedSpace,
    Function? onLeftClicked,
    Function? onLongLeftClicked,
    Function(double value)? onMouseScroll,
    Function? onRightClicked,
    Function? onRightClickReleased,
    Function(SharedPreferences sharedPreferences)? onInit,
    Function(Object error, StackTrace stack)? onError,
    bool setPathUrlStrategy = true,
    Color backgroundColor = Default_Background_Color,
  }){
    Engine.watchTitle.value = title;
    Engine.onInit = init;
    Engine.onUpdate = update;
    Engine.watchBuildUI.value = buildUI;
    Engine.onDrawCanvas = onDrawCanvas;
    Engine.onTapDown = onTapDown;
    Engine.onLongPress = onLongPress;
    Engine.onPanStart = onPanStart;
    Engine.onPanUpdate = onPanUpdate;
    Engine.onPanEnd = onPanEnd;
    Engine.onScreenSizeChanged = onScreenSizeChanged;
    Engine.onDispose = onDispose;
    Engine.onDrawCanvas = onDrawCanvas;
    Engine.onDrawForeground = onDrawForeground;
    Engine.onLeftClicked = onLeftClicked;
    Engine.onPointerScrolled = onPointerScrolled;
    Engine.onRightClicked = onRightClicked;
    Engine.onRightClickReleased = onRightClickReleased;
    Engine.themeData.value = themeData;
    Engine.backgroundColor = backgroundColor;
    Engine.onError = onError;

    if (setPathUrlStrategy){
      us.setPathUrlStrategy();
    }
    WidgetsFlutterBinding.ensureInitialized();
    runZonedGuarded(_internalInit, _internalOnError);
  }

  static void _internalOnError(Object error, StackTrace stack) {
      if (onError != null){
        onError?.call(error, stack);
        return;
      }
      print("Warning no Engine.onError handler set");
      print(error);
      print(stack);
  }

  static void _internalOnPointerScrollEvent(PointerScrollEvent event) {
    if (zoomOnScroll) {
      targetZoom -=  event.scrollDelta.dy * scrollSensitivity;
      targetZoom = targetZoom.clamp(0.2, 6);
    }
    onPointerScrolled?.call(event);
  }

  static void renderText(String text, double x, double y,
      {Canvas? other, TextStyle? style}) {
    textPainter.text = TextSpan(style: style ?? const TextStyle(), text: text);
    textPainter.layout();
    textPainter.paint(other ?? canvas, Offset(x, y));
  }

  // /// If there are draw jobs remaining in the buffer
  // /// it draws them and clears the rest
  // void flushRenderBuffer(){
  //   for (var i = bufferIndex; i < bufferSize; i += 4) {
  //     src[i] = 0;
  //     src[i + 1] = 0;
  //     src[i + 2] = 0;
  //     src[i + 3] = 0;
  //     canvas.drawRawAtlas(atlas, dst, src, colors, renderBlendMode, null, paint);
  //   }
  //   bufferIndex = 0;
  //   renderIndex = 0;
  // }

  static void cameraFollow(double x, double y, double speed) {
    final diffX = screenCenterWorldX - x;
    final diffY = screenCenterWorldY - y;
    camera.x -= (diffX * 75) * speed;
    camera.y -= (diffY * 75) * speed;
  }

  static void cameraCenter(double x, double y) {
    camera.x = x - (screenCenterX / zoom);
    camera.y = y - (screenCenterY / zoom);
  }

  static void redrawCanvas() {
    notifierPaintFrame.value++;
  }

  static void refreshPage(){
    final window = document.window;
    if (window == null) return;
    final domain = document.domain;
    if (domain == null) return;
    window.location.href = domain;
  }

  static void fullscreenToggle()  =>
    fullScreenActive ? fullScreenExit() : fullScreenEnter();

  static void fullScreenExit() => document.exitFullscreen();

  static void fullScreenEnter() {
    final element = document.documentElement;
    if (element == null) {
      return;
    }
    try {
      element.requestFullscreen().catchError((error) {});
    } catch(error) {
      // ignore
    }
  }

  static void panCamera() {
    final positionX = screenToWorldX(mousePosition.x);
    final positionY = screenToWorldY(mousePosition.y);
    final previousX = screenToWorldX(previousMousePosition.x);
    final previousY = screenToWorldY(previousMousePosition.y);
    final diffX = previousX - positionX;
    final diffY = previousY - positionY;
    camera.x += diffX;
    camera.y += diffY;
  }

  static void disableRightClickContextMenu() {
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  static void setPaintColorWhite() {
    paint.color = Colors.white;
  }

  static void setPaintStrokeWidth(double value) {
    paint.strokeWidth = value;
  }

  static void setPaintColor(Color value) {
    if (paint.color == value) return;
    paint.color = value;
  }

  static void _internalOnPointerMove(PointerMoveEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  static void _internalOnPointerHover(PointerHoverEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  /// event.buttons is always 0 and does not seem to correspond to the left or right mouse
  /// click like in internalOnPointerDown
  static void _internalOnPointerUp(PointerUpEvent event) {
    // if (event.buttons == 0) {
    //   watchMouseLeftDown.value = false;
    // }
    // if (event.buttons == 2) {
    //   mouseRightDown.value = false;
    // }
    watchMouseLeftDown.value = false;
  }

  static void _internalOnPointerDown(PointerDownEvent event) {
    if (event.buttons == 1) {
      watchMouseLeftDown.value = true;
    }
    if (event.buttons == 2) {
      mouseRightDown.value = true;
    }
  }

  static void _internalOnPointerSignal(PointerSignalEvent pointerSignalEvent) {
    if (pointerSignalEvent is PointerScrollEvent) {
      _internalOnPointerScrollEvent(pointerSignalEvent);
    }
  }

  static void _internalOnPanStart(DragStartDetails details){
    panStarted = true;
    onPanStart?.call(details);
  }

  static void _internalOnPanUpdate(DragUpdateDetails details){
    onPanUpdate?.call(details);
  }

  static void _internalOnTapDown(TapDownDetails details){
     onTapDown?.call(details);
  }

  static void _internalOnLongPress(){
    onLongPress?.call();
  }

  static void _internalOnLongPressDown(LongPressDownDetails details){
    onLongPressDown?.call(details);
  }

  static void _internalOnPanEnd(DragEndDetails details){
    panStarted = false;
    onPanEnd?.call(details);
  }

  static void _internalOnSecondaryTapDown(TapDownDetails details){
    onSecondaryTapDown?.call(details);
  }

  static void _internalPaint(Canvas canvas, Size size) {
    Engine.canvas = canvas;
    canvas.scale(zoom, zoom);
    canvas.translate(-camera.x, -camera.y);
    if (!initialized) return;
    if (onDrawCanvas == null) return;
    onDrawCanvas!.call(canvas, size);
    flushBuffer();
    assert(bufferIndex == 0);
  }

  static Duration buildDurationFramesPerSecond(int framesPerSecond) =>
    Duration(milliseconds: convertFramesPerSecondsToMilliseconds(framesPerSecond));

  static int convertFramesPerSecondsToMilliseconds(int framesPerSecond) =>
    Milliseconds_Per_Second ~/ framesPerSecond;

  static Future _internalInit() async {
    runApp(_internalBuildApp());

    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
    keyboard.addListener(_internalOnKeyboardEvent);

    mouseRightDown.onChanged((bool value) {
      if (value) {
        onRightClicked?.call();
      }
    });

    document.onFullscreenChange.listen((event) {
      fullScreen.value = fullScreenActive;
    });

    loadBufferImage('images/atlas.png');
    disableRightClickContextMenu();
    paint.isAntiAlias = false;
    Engine.sharedPreferences = await SharedPreferences.getInstance();
    if (onInit != null) {
      await onInit!(sharedPreferences);
    }
    updateTimer = Timer.periodic(
        watchDurationPerFrame.value,
        _internalOnUpdate,
    );
    watchInitialized.value = true;
  }

  static void resetUpdateTimer(){
    updateTimer?.cancel();
    updateTimer = Timer.periodic(
      watchDurationPerFrame.value,
      _internalOnUpdate,
    );
    onUpdateTimerReset?.call();
  }

  static void _internalOnUpdate(Timer timer){
    screen.left = camera.x;
    screen.right = camera.x + (screen.width / zoom);
    screen.top = camera.y;
    screen.bottom = camera.y + (screen.height / zoom);
    if (watchMouseLeftDown.value) {
      mouseLeftDownFrames++;
    }
    deviceType.value =
      screenArea < 400000
        ? DeviceType.Phone
        : DeviceType.Computer;
    onUpdate?.call();
    final sX = screenCenterWorldX;
    final sY = screenCenterWorldY;
    final zoomDiff = targetZoom - zoom;
    zoom += zoomDiff * zoomSensitivity;
    cameraCenter(sX, sY);
    if (drawCanvasAfterUpdate) {
      redrawCanvas();
    }
  }

  void setFramesPerSecond(int framesPerSecond) =>
     watchDurationPerFrame.value = buildDurationFramesPerSecond(framesPerSecond);

  // static final _src4 = Float32List(4);
  // static final _dst4 = Float32List(4);
  // static final _colors1 = Int32List(1);
  static const _cos0 = 1;
  static const _sin0 = 0;
  static late ui.Image bufferImage;

  static var bufferBlendMode = BlendMode.dstATop;
  static var bufferIndex = 0;

  // static const _bufferSize = 100000;
  // static final _bufferSrc = Float32List(_bufferSize * 4);
  // static final _bufferDst = Float32List(_bufferSize * 4);
  // static final _bufferColors = Int32List(_bufferSize);

  static final _bufferSrc1 = Float32List(1 * 4);
  static final _bufferDst1 = Float32List(1 * 4);
  static final _bufferClr1 = Int32List(1);

  static final _bufferSrc2 = Float32List(2 * 4);
  static final _bufferDst2 = Float32List(2 * 4);
  static final _bufferClr2 = Int32List(2);

  static final _bufferSrc3 = Float32List(3 * 4);
  static final _bufferDst3 = Float32List(3 * 4);
  static final _bufferClr3 = Int32List(3);

  static final _bufferSrc4 = Float32List(4 * 4);
  static final _bufferDst4 = Float32List(4 * 4);
  static final _bufferClr4 = Int32List(4);

  static final _bufferSrc8 = Float32List(8 * 4);
  static final _bufferDst8 = Float32List(8 * 4);
  static final _bufferClr8 = Int32List(8);

  static final _bufferSrc16 = Float32List(16 * 4);
  static final _bufferDst16 = Float32List(16 * 4);
  static final _bufferClr16 = Int32List(16);

  static final _bufferSrc32 = Float32List(32 * 4);
  static final _bufferDst32 = Float32List(32 * 4);
  static final _bufferClr32 = Int32List(32);

  static final _bufferSrc64 = Float32List(64 * 4);
  static final _bufferDst64 = Float32List(64 * 4);
  static final _bufferClr64 = Int32List(64);

  static final _bufferSrc = _bufferSrc64;
  static final _bufferDst = _bufferDst64;
  static final _bufferClr = _bufferClr64;

  static void flushBuffer() {
    if (bufferIndex == 0) return;
    var flushIndex = 0;
    while (flushIndex < bufferIndex) {
      final remaining = bufferIndex - flushIndex;

      if (remaining == 0) {
        throw Exception();
      }

      if (remaining == 1) {
        final f = flushIndex * 4;
        _bufferClr1[0] = _bufferClr[flushIndex];
        _bufferDst1[0] = _bufferDst[f];
        _bufferDst1[1] = _bufferDst[f + 1];
        _bufferDst1[2] = _bufferDst[f + 2];
        _bufferDst1[3] = _bufferDst[f + 3];
        _bufferSrc1[0] = _bufferSrc[f];
        _bufferSrc1[1] = _bufferSrc[f + 1];
        _bufferSrc1[2] = _bufferSrc[f + 2];
        _bufferSrc1[3] = _bufferSrc[f + 3];
        canvas.drawRawAtlas(bufferImage, _bufferDst1, _bufferSrc1, _bufferClr1, bufferBlendMode, null, spritePaint);
        bufferIndex = 0;
        return;
      }

      if (remaining < 4) {
        for (var i = 0; i < 2; i++) {
          final j = i * 4;
          final f = flushIndex * 4;
          _bufferClr2[i] = _bufferClr[flushIndex];
          _bufferDst2[j] = _bufferDst[f];
          _bufferDst2[j + 1] = _bufferDst[f + 1];
          _bufferDst2[j + 2] = _bufferDst[f + 2];
          _bufferDst2[j + 3] = _bufferDst[f + 3];
          _bufferSrc2[j] = _bufferSrc[f];
          _bufferSrc2[j + 1] = _bufferSrc[f + 1];
          _bufferSrc2[j + 2] = _bufferSrc[f + 2];
          _bufferSrc2[j + 3] = _bufferSrc[f + 3];
          flushIndex++;
        }
        canvas.drawRawAtlas(bufferImage, _bufferDst2, _bufferSrc2, _bufferClr2, bufferBlendMode, null, spritePaint);
        continue;
      }

      if (remaining < 8) {
        for (var i = 0; i < 4; i++) {
          final j = i * 4;
          final f = flushIndex * 4;
          _bufferClr4[i] = _bufferClr[flushIndex];
          _bufferDst4[j] = _bufferDst[f];
          _bufferDst4[j + 1] = _bufferDst[f + 1];
          _bufferDst4[j + 2] = _bufferDst[f + 2];
          _bufferDst4[j + 3] = _bufferDst[f + 3];
          _bufferSrc4[j] = _bufferSrc[f];
          _bufferSrc4[j + 1] = _bufferSrc[f + 1];
          _bufferSrc4[j + 2] = _bufferSrc[f + 2];
          _bufferSrc4[j + 3] = _bufferSrc[f + 3];
          flushIndex++;
        }
        canvas.drawRawAtlas(bufferImage, _bufferDst4, _bufferSrc4, _bufferClr4, bufferBlendMode, null, spritePaint);
        continue;
      }

      if (remaining < 16) {
        for (var i = 0; i < 8; i++) {
          final j = i * 4;
          final f = flushIndex * 4;
          _bufferClr8[i] = _bufferClr[flushIndex];
          _bufferDst8[j] = _bufferDst[f];
          _bufferDst8[j + 1] = _bufferDst[f + 1];
          _bufferDst8[j + 2] = _bufferDst[f + 2];
          _bufferDst8[j + 3] = _bufferDst[f + 3];
          _bufferSrc8[j] = _bufferSrc[f];
          _bufferSrc8[j + 1] = _bufferSrc[f + 1];
          _bufferSrc8[j + 2] = _bufferSrc[f + 2];
          _bufferSrc8[j + 3] = _bufferSrc[f + 3];
          flushIndex++;
        }
        canvas.drawRawAtlas(bufferImage, _bufferDst8, _bufferSrc8, _bufferClr8, bufferBlendMode, null, spritePaint);
        continue;
      }

      if (remaining < 32) {
        for (var i = 0; i < 16; i++) {
          final j = i * 4;
          final f = flushIndex * 4;
          _bufferClr16[i] = _bufferClr[flushIndex];
          _bufferDst16[j] = _bufferDst[f];
          _bufferDst16[j + 1] = _bufferDst[f + 1];
          _bufferDst16[j + 2] = _bufferDst[f + 2];
          _bufferDst16[j + 3] = _bufferDst[f + 3];
          _bufferSrc16[j] = _bufferSrc[f];
          _bufferSrc16[j + 1] = _bufferSrc[f + 1];
          _bufferSrc16[j + 2] = _bufferSrc[f + 2];
          _bufferSrc16[j + 3] = _bufferSrc[f + 3];
          flushIndex++;
        }
        canvas.drawRawAtlas(bufferImage, _bufferDst16, _bufferSrc16, _bufferClr16, bufferBlendMode, null, spritePaint);
        continue;
      }

      if (remaining < 64) {
        for (var i = 0; i < 32; i++) {
          final j = i * 4;
          final f = flushIndex * 4;
          _bufferClr32[i] = _bufferClr[flushIndex];
          _bufferDst32[j] = _bufferDst[f];
          _bufferDst32[j + 1] = _bufferDst[f + 1];
          _bufferDst32[j + 2] = _bufferDst[f + 2];
          _bufferDst32[j + 3] = _bufferDst[f + 3];
          _bufferSrc32[j] = _bufferSrc[f];
          _bufferSrc32[j + 1] = _bufferSrc[f + 1];
          _bufferSrc32[j + 2] = _bufferSrc[f + 2];
          _bufferSrc32[j + 3] = _bufferSrc[f + 3];
          flushIndex++;
        }
        canvas.drawRawAtlas(bufferImage, _bufferDst32, _bufferSrc32, _bufferClr32, bufferBlendMode, null, spritePaint);
        continue;
      }

      throw Exception();
    }
    bufferIndex = 0;
  }


  static void flushAll(){
    canvas.drawRawAtlas(bufferImage, _bufferDst, _bufferSrc, _bufferClr, bufferBlendMode, null, spritePaint);
    bufferIndex = 0;
  }

  static void renderSprite({
    required ui.Image image,
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    double anchorX = 0.5,
    double anchorY = 0.5,
    double scale = 1.0,
    int color = 1,
  }){
    if (bufferImage != image) {
      flushBuffer();
      bufferImage = image;
    }
    final f = bufferIndex * 4;
    _bufferClr[bufferIndex] = color;
    _bufferSrc[f] = srcX;
    _bufferSrc[f + 1] = srcY;
    _bufferSrc[f + 2] = srcX + srcWidth;
    _bufferSrc[f + 3] = srcY + srcHeight;
    _bufferDst[f] = scale;
    _bufferDst[f + 1] = 0;
    _bufferDst[f + 2] = dstX - (srcWidth * anchorX * scale);
    _bufferDst[f + 3] = dstY - (srcHeight * anchorY * scale);
    bufferIndex++;

    if (bufferIndex == 64) {
      flushAll();
    }
  }

  static void renderSpriteRotated({
    required ui.Image image,
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    required double rotation,
    double anchorX = 0.5,
    double anchorY = 0.5,
    double scale = 1.0,
    int color = 1,
  }){
    // final angle = rotation + piQuarter;
    // final translate = calculateHypotenuse(srcWidth * 0.5, srcHeight * 0.5);
    // _colors1[0] = color;
    // _src4[0] = srcX;
    // _dst4[0] = cos(rotation) * scale;
    // _src4[1] = srcY;
    // _dst4[1] = sin(rotation) * scale;
    // _src4[2] = srcX + srcWidth;
    // _dst4[2] = dstX - getAdjacent(angle, translate);
    // _src4[3] = srcY + srcHeight;
    // _dst4[3] = dstY - getOpposite(angle, translate);
  }

  static void renderExternalCanvas({
    required Canvas canvas,
    required ui.Image image,
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    double anchorX = 0.5,
    double anchorY = 0.5,
    double scale = 1.0,
    int color = 1,
  }){
    // _bufferColors1[0] = color;
    // _bufferSrc1[0] = srcX;
    // _bufferSrc1[1] = srcY;
    // _bufferSrc1[2] = srcX + srcWidth;
    // _bufferSrc1[3] = srcY + srcHeight;
    // _bufferDst1[0] = _cos0 * scale;
    // _bufferDst1[1] = _sin0 * scale; // scale
    // _bufferDst1[2] = dstX - (srcWidth * anchorX * scale);
    // _bufferDst1[3] = dstY - (srcHeight * anchorY * scale); // scale
    // canvas.drawRawAtlas(image, _bufferDst1, _bufferSrc1, _bufferColors1, bufferBlendMode, null, paint);
  }

  static void renderCircle(double x, double y, double radius, Color color) {
    renderCircleOffset(Offset(x, y), radius, color);
  }

  static void renderCircleOffset(Offset offset, double radius, Color color) {
    setPaintColor(color);
    canvas.drawCircle(offset, radius, paint);
  }

  static void renderCircleOutline({
    required double radius,
    required double x,
    required double y,
    required Color color,
    int sides = 6,
    double width = 3,
  }) {
    double r = (pi * 2) / sides;
    List<Offset> points = [];
    Offset z = Offset(x, y);
    setPaintColor(color);
    paint.strokeWidth = width;

    for (int i = 0; i <= sides; i++) {
      double a1 = i * r;
      points.add(Offset(cos(a1) * radius, sin(a1) * radius));
    }
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i] + z, points[i + 1] + z, Engine.paint);
    }
  }

  static Widget _internalBuildApp(){
    return WatchBuilder(themeData, (ThemeData? themeData){
      return MaterialApp(
        title: title,
        // routes: Engine.routes ?? {},
        theme: themeData,
        home: Scaffold(
          body: WatchBuilder(watchInitialized, (bool value) {
            if (!value) {
              return onBuildLoadingScreen != null ? onBuildLoadingScreen!(buildContext) : Text("Loading");
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                _internalSetScreenSize(constraints.maxWidth, constraints.maxHeight);
                buildContext = context;
                return Stack(
                  children: [
                    _internalBuildCanvas(context),
                    WatchBuilder(watchBuildUI, (WidgetBuilder? buildUI)
                    => buildUI != null ? buildUI(context) : const SizedBox()
                    )
                  ],
                );
              },
            );
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }

  static Widget _internalBuildCanvas(BuildContext context) {
    final child = Listener(
      onPointerDown: _internalOnPointerDown,
      onPointerMove: _internalOnPointerMove,
      onPointerUp: _internalOnPointerUp,
      onPointerHover: _internalOnPointerHover,
      onPointerSignal: _internalOnPointerSignal,
      child: GestureDetector(
          onTapDown: _internalOnTapDown,
          onLongPress: _internalOnLongPress,
          onLongPressDown: _internalOnLongPressDown,
          onPanStart: _internalOnPanStart,
          onPanUpdate: _internalOnPanUpdate,
          onPanEnd: _internalOnPanEnd,
          onSecondaryTapDown: _internalOnSecondaryTapDown,
          child: WatchBuilder(watchBackgroundColor, (Color backgroundColor){
            return Container(
                color: backgroundColor,
                width: screen.width,
                height: screen.height,
                child: CustomPaint(
                  painter: _EnginePainter(repaint: notifierPaintFrame),
                  foregroundPainter: _EngineForegroundPainter(
                      repaint: notifierPaintForeground
                  ),
                )
            );
          })),
    );

    return WatchBuilder(Engine.cursorType, (CursorType cursorType) =>
        MouseRegion(
          cursor: _internalMapCursorTypeToSystemMouseCursor(cursorType),
          child: child,
        )
    );
  }

  static double calculateDistance(double x1, double y1, double x2, double y2) =>
      calculateHypotenuse(x1 - x2, y1 - y2);

  static double calculateHypotenuse(num adjacent, num opposite) =>
     sqrt((adjacent * adjacent) + (opposite * opposite));

  static double calculateAngle(double adjacent, double opposite) {
    final angle = atan2(opposite, adjacent);
    return angle < 0 ? PI_2 + angle : angle;
  }

  static double calculateAdjacent(double radians, double magnitude) =>
    cos(radians) * magnitude;

  static double calculateOpposite(double radians, double magnitude) =>
    sin(radians) * magnitude;

  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double randomGiveOrTake(num value) =>
    randomBetween(-value, value);

  static double randomBetween(num a, num b) =>
    (random.nextDouble() * (b - a)) + a;

  static bool randomBool() =>
    random.nextDouble() > 0.5;

  static SystemMouseCursor _internalMapCursorTypeToSystemMouseCursor(CursorType value){
    switch (value) {
      case CursorType.Forbidden:
        return SystemMouseCursors.forbidden;
      case CursorType.Precise:
        return SystemMouseCursors.precise;
      case CursorType.None:
        return SystemMouseCursors.none;
      case CursorType.Click:
        return SystemMouseCursors.click;
      default:
        return SystemMouseCursors.basic;
    }
  }

  static void drawLine(double x1, double y1, double x2, double y2) =>
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

  static bool get fullScreenActive => document.fullscreenElement != null;

  static double screenToWorldX(double value)  =>
    camera.x + value / zoom;

  static double screenToWorldY(double value) =>
    camera.y + value / zoom;

  static double worldToScreenX(double x) =>
    zoom * (x - camera.x);

  static double worldToScreenY(double y) =>
    zoom * (y - camera.y);

  static double get screenCenterX => screen.width * 0.5;
  static double get screenCenterY => screen.height * 0.5;
  static double get screenCenterWorldX => screenToWorldX(screenCenterX);
  static double get screenCenterWorldY => screenToWorldY(screenCenterY);
  static double get mouseWorldX => screenToWorldX(mousePosition.x);
  static double get mouseWorldY => screenToWorldY(mousePosition.y);

  static double distanceFromMouse(double x, double y) =>
     calculateDistance(mouseWorldX, mouseWorldY, x, y);

  static void requestPointerLock() {
    var canvas = document.getElementById('canvas');
    if (canvas != null) {
      canvas.requestPointerLock();
    }
  }

  static  void setDocumentTitle(String value){
    document.title = value;
  }


  static void setFavicon(String filename){
    final link = document.querySelector("link[rel*='icon']");
    if (link == null) return;
    print("setFavicon($filename)");
    link.setAttribute("type", 'image/x-icon');
    link.setAttribute("rel", 'shortcut icon');
    link.setAttribute("href", filename);
    document.getElementsByTagName('head')[0].append(link);
  }

  static void setCursorWait(){
    setCursorByName('wait');
  }

  static void setCursorPointer(){
    setCursorByName('default');
  }

  static void setCursorByName(String name){
    final body = document.body;
    if (body == null) return;
    body.style.cursor = name;
  }

  static void downloadString({
    required String contents,
    required String filename,
  }) =>
      downloadBytes(utf8.encode(contents), downloadName: filename);

  static void downloadBytes(
      List<int> bytes, {
        required String downloadName,
      }) {
    final _base64 = base64Encode(bytes);
    final anchor =
    AnchorElement(href: 'data:application/octet-stream;base64,$_base64')
      ..target = 'blank';
    anchor.download = downloadName;
    document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return;
  }

  static String enumString(dynamic value){
    final text = value.toString();
    final index = text.indexOf(".");
    if (index == -1) return text;
    return text.substring(index + 1, text.length).replaceAll("_", " ");
  }


}

typedef CallbackOnScreenSizeChanged = void Function(
    double previousWidth,
    double previousHeight,
    double newWidth,
    double newHeight,
);

// global typedefs
typedef DrawCanvas(Canvas canvas, Size size);

// classes
abstract class KeyboardEventHandler {
  void onPressed(PhysicalKeyboardKey key);
  void onReleased(PhysicalKeyboardKey key);
  void onHeld(PhysicalKeyboardKey key, int frames);
}

class _Screen {
  var initialized = false;
  var width = 0.0;
  var height = 0.0;
  var top = 0.0;
  var right = 0.0;
  var bottom = 0.0;
  var left = 0.0;

  bool contains(double x, double y) =>
    x > left &&
    x < right &&
    y > top &&
    y < bottom ;
}

class DeviceType {
  static final Phone = 0;
  static final Computer = 1;

  static String getName(int value){
    if (value == Phone){
      return "Phone";
    }
    if (value == Computer){
      return "Computer";
    }
    return "unknown-device-type($value)";
  }
}

enum CursorType {
  None,
  Basic,
  Forbidden,
  Precise,
  Click,
}

class _EnginePainter extends CustomPainter {

  const _EnginePainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size size) {
    Engine._internalPaint(_canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _EngineForegroundPainter extends CustomPainter {

  const _EngineForegroundPainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size _size) {
    Engine.onDrawForeground?.call(Engine.canvas, _size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

