library lemon_engine;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';
import 'package:url_strategy/url_strategy.dart' as us;

import 'render.dart';

/// boilerplate code for game development
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
  /// HOOKS
  /// the following hooks are designed to be easily swapped in and out without inheritance

  /// override safe. run this snippet inside your initialization code.
  /// engine.onTapDown = (TapDownDetails details) => print('tap detected');
  static GestureTapDownCallback? onTapDown;
  /// override safe
  static GestureLongPressCallback? onLongPress;
  /// override safe
  static GestureDragStartCallback? onPanStart;
  /// override safe
  static GestureDragUpdateCallback? onPanUpdate;
  /// override safe
  static GestureDragEndCallback? onPanEnd;
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
  static Function? onKeyPressedSpace;
  /// override safe
  static Function? onLeftClicked;
  /// override safe
  static Function? onLongLeftClicked;
  /// override safe
  static Function(double value)? onMouseScroll;
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

  // SETTERS
  static set buildUI(WidgetBuilder? value) => watchBuildUI.value = value;
  static set title(String value) => watchTitle.value = value;
  static set backgroundColor(Color value) => watchBackgroundColor.value = value;

  // GETTERS
  static WidgetBuilder? get buildUI => watchBuildUI.value;
  static String get title => watchTitle.value;
  static Color get backgroundColor => watchBackgroundColor.value;
  static bool get isLocalHost => Uri.base.host == 'localhost';
  static bool get deviceIsComputer => deviceType.value == DeviceType.Computer;
  static bool get deviceIsPhone => deviceType.value == DeviceType.Phone;
  static int get paintFrame => notifierPaintFrame.value;

  // WATCHES
  static final watchBackgroundColor = Watch(DefaultBackgroundColor);
  static final watchBuildUI = Watch<WidgetBuilder?>(null);
  static final watchTitle = Watch(DefaultTitle);
  static final watchInitialized = Watch(false);
  static final watchDurationPerFrame = Watch(Duration(milliseconds: DefaultMillisecondsPerFrame));
  static final watchMouseLeftDown = Watch(false, onChanged: internalOnChangedMouseLeftDown);
  static final mouseRightDown = Watch(false);

  // CONSTANTS
  static const DefaultMillisecondsPerFrame = 30;
  static const DefaultBackgroundColor = Colors.black;
  static const DefaultTitle = "DEMO";
  static const MillisecondsPerSecond = 1000;
  static const PI2 = pi + pi;
  static const PIHalf = pi * 0.5;
  static const PIQuarter = pi * 0.25;
  static const PIEight = pi * 0.125;

  // VARIABLES
  static late ui.Image atlas;
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

  static Timer? updateTimer;
  static late final sharedPreferences;
  static var scrollSensitivity = 0.0005;
  static var cameraSmoothFollow = true;
  static var zoomSensitivity = 0.175;
  static var targetZoom = 1.0;
  static var zoomOnScroll = true;
  static var keyPressedHandlers = <LogicalKeyboardKey, Function>{};
  static var keyReleasedHandlers = <LogicalKeyboardKey, Function>{};
  static final Map<LogicalKeyboardKey, int> keyboardState = {};
  static var mousePosition = Vector2(0, 0);
  static var previousMousePosition = Vector2(0, 0);
  static var previousUpdateTime = DateTime.now();
  static var mouseLeftDownFrames = 0;
  static final themeData = Watch<ThemeData?>(null);
  static final fullScreen = Watch(false);
  static var drawCanvasAfterUpdate = true;
  static final notifierPaintFrame = ValueNotifier<int>(0);
  static final notifierPaintForeground = ValueNotifier<int>(0);
  static final screen = _Screen();
  static final cursorType = Watch(CursorType.Precise);
  static var panStarted = false;
  static final camera = Vector2(0, 0);
  static var zoom = 1.0;
  static final deviceType = Watch(DeviceType.Computer);
  static late BuildContext buildContext;

  // QUERIES

  static bool keyPressed(LogicalKeyboardKey key) =>
      keyboard.keysPressed.contains(key);

  // INTERNAL FUNCTIONS

  static void internalOnKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      keyPressedHandlers[event.logicalKey]?.call();
      return;
    }
    if (event is RawKeyUpEvent) {
      keyReleasedHandlers[event.logicalKey]?.call();
    }
  }

  static void internalOnChangedMouseLeftDown(bool value){
    if (value) {
      onLeftClicked?.call();
    } else {
      mouseLeftDownFrames = 0;
    }
  }

  static void internalSetScreenSize(double width, double height){
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

  static Future loadAtlas(String filename) async {
    atlas = await loadImageAsset(filename);
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
    String title = DefaultTitle,
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
    Color backgroundColor = DefaultBackgroundColor,
  }){
    WidgetsFlutterBinding.ensureInitialized();
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
    Engine.onKeyPressedSpace = onKeyPressedSpace;
    Engine.onLeftClicked = onLeftClicked;
    Engine.onMouseScroll = onMouseScroll;
    Engine.onRightClicked = onRightClicked;
    Engine.onRightClickReleased = onRightClickReleased;
    Engine.themeData.value = themeData;
    Engine.backgroundColor = backgroundColor;
    Engine.onError = onError;

    if (setPathUrlStrategy){
      us.setPathUrlStrategy();
    }

    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
    keyboard.addListener(internalOnKeyboardEvent);

    mouseRightDown.onChanged((bool value) {
      if (value) {
        onRightClicked?.call();
      }
    });

    document.onFullscreenChange.listen((event) {
      fullScreen.value = fullScreenActive;
    });

    loadAtlas('images/atlas.png');

    runZonedGuarded(Engine._internalInit, internalOnError);
  }

  static void internalOnError(Object error, StackTrace stack) {
      if (onError != null){
        onError!.call(error, stack);
        return;
      }
      print("Warning no Engine.onError handler set");
      print(error);
      print(stack);
  }

  static void internalOnMouseScroll(double amount) {
    if (zoomOnScroll) {
      targetZoom -=  amount * scrollSensitivity;
      targetZoom = targetZoom.clamp(0.2, 6);
    }
    onMouseScroll?.call(amount);
  }

  static void mapColor(Color color) {
    colors[bufferIndex] = color.value;
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

  static void internalOnPointerMove(PointerMoveEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  static void internalOnPointerHover(PointerHoverEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  /// event.buttons is always 0 and does not seem to correspond to the left or right mouse
  /// click like in internalOnPointerDown
  static void internalOnPointerUp(PointerUpEvent event) {
    // if (event.buttons == 0) {
    //   watchMouseLeftDown.value = false;
    // }
    // if (event.buttons == 2) {
    //   mouseRightDown.value = false;
    // }
    watchMouseLeftDown.value = false;
  }

  static void internalOnPointerDown(PointerDownEvent event) {
    if (event.buttons == 1) {
      watchMouseLeftDown.value = true;
    }
    if (event.buttons == 2) {
      mouseRightDown.value = true;
    }
  }

  static void internalOnPointerSignal(PointerSignalEvent pointerSignalEvent) {
    if (pointerSignalEvent is PointerScrollEvent) {
      internalOnMouseScroll(pointerSignalEvent.scrollDelta.dy);
    }
  }

  static void internalOnPanStart(DragStartDetails details){
    panStarted = true;
    onPanStart?.call(details);
  }

  static void internalOnPanEnd(DragEndDetails details){
    panStarted = false;
    onPanEnd?.call(details);
  }

  static void internalPaint(Canvas canvas, Size size) {
    Engine.canvas = canvas;
    canvas.scale(zoom, zoom);
    canvas.translate(-camera.x, -camera.y);
    if (!watchInitialized.value) return;
    if (onDrawCanvas == null) return;
    onDrawCanvas!.call(canvas, size);
    engineRenderFlushBuffer();
  }

  static Duration buildDurationFramesPerSecond(int framesPerSecond) =>
    Duration(milliseconds: convertFramesPerSecondsToMilliseconds(framesPerSecond));

  static int convertFramesPerSecondsToMilliseconds(int framesPerSecond) =>
    MillisecondsPerSecond ~/ framesPerSecond;

  static Future _internalInit() async {
    print("engine.internalInit()");
    runApp(Game());
    disableRightClickContextMenu();
    paint.isAntiAlias = false;
    Engine.sharedPreferences = await SharedPreferences.getInstance();
    print("sharedPreferences set");
    if (onInit != null) {
      await onInit!(sharedPreferences);
    }
    updateTimer = Timer.periodic(
        watchDurationPerFrame.value,
        internalOnUpdate,
    );
    watchInitialized.value = true;
  }

  static void resetUpdateTimer(){
    updateTimer?.cancel();
    updateTimer = Timer.periodic(
      watchDurationPerFrame.value,
      internalOnUpdate,
    );
    onUpdateTimerReset?.call();
  }

  static void internalOnUpdate(Timer timer){
    _screen.left = camera.x;
    _screen.right = camera.x + (_screen.width / zoom);
    _screen.top = camera.y;
    _screen.bottom = camera.y + (_screen.height / zoom);
    if (watchMouseLeftDown.value) {
      mouseLeftDownFrames++;
    }
    deviceType.value =
    screen.width < 800 ? DeviceType.Phone : DeviceType.Computer;
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


  static final _src4 = Float32List(4);
  static final _dst4 = Float32List(4);
  static final _colors1 = Int32List(1);
  static const _cos0 = 1;
  static const _sin0 = 0;

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
    _colors1[0] = color;
    _src4[0] = srcX;
    _src4[1] = srcY;
    _src4[2] = srcX + srcWidth;
    _src4[3] = srcY + srcHeight;
    _dst4[0] = _cos0 * scale;
    _dst4[1] = _sin0 * scale; // scale
    _dst4[2] = dstX - (srcWidth * anchorX * scale);
    _dst4[3] = dstY - (srcHeight * anchorY * scale); // scale
    canvas.drawRawAtlas(image, _dst4, _src4, _colors1, BlendMode.dstATop, null, paint);
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
  }){
    _src4[0] = srcX;
    _src4[1] = srcY;
    _src4[2] = srcX + srcWidth;
    _src4[3] = srcY + srcHeight;
    _dst4[0] = _cos0 * scale;
    _dst4[1] = _sin0 * scale; // scale
    _dst4[2] = dstX - (srcWidth * anchorX * scale);
    _dst4[3] = dstY - (srcHeight * anchorY * scale); // scale
    canvas.drawRawAtlas(image, _dst4, _src4, _colors1, BlendMode.dstATop, null, paint);
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
    Engine.setPaintColor(color);
    Engine.paint.strokeWidth = width;

    for (int i = 0; i <= sides; i++) {
      double a1 = i * r;
      points.add(Offset(cos(a1) * radius, sin(a1) * radius));
    }
    for (int i = 0; i < points.length - 1; i++) {
      Engine.canvas.drawLine(points[i] + z, points[i + 1] + z, Engine.paint);
    }
  }

}

typedef CallbackOnScreenSizeChanged = void Function(
    double previousWidth,
    double previousHeight,
    double newWidth,
    double newHeight,
);

double screenToWorldX(double value) {
  return Engine.camera.x + value / Engine.zoom;
}

double screenToWorldY(double value) {
  return Engine.camera.y + value / Engine.zoom;
}

double worldToScreenX(double x) {
  return Engine.zoom * (x - Engine.camera.x);
}

double worldToScreenY(double y) {
  return Engine.zoom * (y - Engine.camera.y);
}

double distanceFromMouse(double x, double y) {
  return distanceBetween(mouseWorldX, mouseWorldY, x, y);
}

T closestToMouse<T extends Vector2>(List<T> values){
  return findClosest(values, mouseWorldX, mouseWorldY);
}

// global properties
// Offset get mouseWorld => Offset(mouseWorldX, mouseWorldY);
final _mousePosition = Engine.mousePosition;
final _screen = Engine.screen;

double get screenCenterX => _screen.width * 0.5;
double get screenCenterY => _screen.height * 0.5;
double get screenCenterWorldX => screenToWorldX(screenCenterX);
double get screenCenterWorldY => screenToWorldY(screenCenterY);
double get mouseWorldX => screenToWorldX(_mousePosition.x);
double get mouseWorldY => screenToWorldY(_mousePosition.y);
bool get fullScreenActive => document.fullscreenElement != null;

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

