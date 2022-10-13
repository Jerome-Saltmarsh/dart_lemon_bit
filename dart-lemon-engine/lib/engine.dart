library lemon_engine;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/device_type.dart';
import 'package:lemon_engine/draw.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_engine/events.dart';
import 'package:lemon_engine/state/atlas.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';

import 'actions.dart';
import 'canvas.dart';
import 'load_image.dart';
import 'render.dart';
import 'state/paint.dart';

final engine = _Engine();

class _Engine {
  late final sharedPreferences;
  final draw = LemonEngineDraw();
  late final LemonEngineEvents events;
  var scrollSensitivity = 0.0005;
  var cameraSmoothFollow = true;
  var zoomSensitivity = 0.175;
  var targetZoom = 1.0;
  var zoomOnScroll = true;


  final Map<LogicalKeyboardKey, int> keyboardState = {};
  var mousePosition = Vector2(0, 0);
  var previousMousePosition = Vector2(0, 0);
  var previousUpdateTime = DateTime.now();
  final mouseLeftDown = Watch(false, onChanged: (bool value) {
    if (value) {
        engine.onLeftClicked?.call();
    }
  });
  final mouseRightDown = Watch(false, onChanged: (bool value) {

  });
  var mouseLeftDownFrames = 0;
  final fps = Watch(0);
  final backgroundColor = Watch(Colors.white);
  final themeData = Watch<ThemeData?>(null);
  final fullScreen = Watch(false);
  var millisecondsSinceLastFrame = 50;
  var drawCanvasAfterUpdate = true;
  final notifierPaintFrame = ValueNotifier<int>(0);
  final notifierPaintForeground = ValueNotifier<int>(0);
  final screen = _Screen();
  final initialized = Watch(false, onChanged: (bool value){
  });
  final cursorType = Watch(CursorType.Precise);
  var panStarted = false;
  final camera = Vector2(0, 0);
  var zoom = 1.0;
  final deviceType = Watch(DeviceType.Computer);
  late BuildContext buildContext;
  Function? update;



  bool get deviceIsComputer => deviceType.value == DeviceType.Computer;

  bool get deviceIsPhone => deviceType.value == DeviceType.Phone;

  BuildContext? context;

  bool get isLocalHost => Uri.base.host == 'localhost';

  void internalSetScreenSize(double width, double height){
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

  void toggleDeviceType() =>
      deviceType.value =
      deviceIsComputer ? DeviceType.Phone : DeviceType.Computer;

  var textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
  );

  final Map<String, TextSpan> textSpans = {
  };

  Future loadAtlas(String filename) async {
    atlas = await loadImage(filename);
  }

  void updateEngine() {
    _screen.left = camera.x;
    _screen.right = camera.x + (_screen.width / zoom);
    _screen.top = camera.y;
    _screen.bottom = camera.y + (_screen.height / zoom);
    if (mouseLeftDown.value) {
      mouseLeftDownFrames++;
    }
    deviceType.value =
    screen.width < 800 ? DeviceType.Phone : DeviceType.Computer;
    update?.call();
    final sX = screenCenterWorldX;
    final sY = screenCenterWorldY;
    final zoomDiff = targetZoom - zoom;
    zoom += zoomDiff * zoomSensitivity;
    cameraCenter(sX, sY);


    if (drawCanvasAfterUpdate) {
      redrawCanvas();
    }
  }

  TextSpan getTextSpan(String text) {
    var value = textSpans[text];
    if (value != null) return value;
    value = TextSpan(style: TextStyle(color: Colors.white), text: text);
    textSpans[text] = value;
    return value;
  }

  void writeText(String text, double x, double y) {
    textPainter.text = getTextSpan(text);
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  var keyPressedHandlers = <LogicalKeyboardKey, Function>{};
  var keyReleasedHandlers = <LogicalKeyboardKey, Function>{};

  int get frame => notifierPaintFrame.value;

  _Engine() {
    WidgetsFlutterBinding.ensureInitialized();
    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
    events = LemonEngineEvents();
    RawKeyboard.instance.addListener(events.onKeyboardEvent);

    mouseLeftDown.onChanged((bool leftDown) {
      if (!leftDown) mouseLeftDownFrames = 0;
    });

    mouseRightDown.onChanged((bool value) {
      if (value) {
        onRightClicked?.call();
      }
    });

    document.onFullscreenChange.listen((event) {
      fullScreen.value = fullScreenActive;
    });

    loadAtlas('images/atlas.png');
  }

  void internalOnMouseScroll(double amount) {
    if (zoomOnScroll) {
      targetZoom -=  amount * scrollSensitivity;
      targetZoom = targetZoom.clamp(0.2, 6);
    }
    onMouseScroll?.call(amount);
  }

  void mapColor(Color color) {
    colors[bufferIndex] = color.value;
  }

  void renderText(String text, double x, double y,
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

  void cameraFollow(double x, double y, double speed) {
    final diffX = screenCenterWorldX - x;
    final diffY = screenCenterWorldY - y;
    camera.x -= (diffX * 75) * speed;
    camera.y -= (diffY * 75) * speed;
  }

  void cameraCenter(double x, double y) {
    camera.x = x - (screenCenterX / zoom);
    camera.y = y - (screenCenterY / zoom);
  }

  void redrawCanvas() {
    notifierPaintFrame.value++;
  }

  void fullscreenToggle() {
    fullScreenActive ? fullScreenExit() : fullScreenEnter();
  }

  void fullScreenExit() {
    document.exitFullscreen();
  }

  void panCamera() {
    final positionX = screenToWorldX(mousePosition.x);
    final positionY = screenToWorldY(mousePosition.y);
    final previousX = screenToWorldX(previousMousePosition.x);
    final previousY = screenToWorldY(previousMousePosition.y);
    final diffX = previousX - positionX;
    final diffY = previousY - positionY;
    // camera.x += diffX * zoom;
    // camera.y += diffY * zoom;
    camera.x += diffX;
    camera.y += diffY;
  }

  void disableRightClickContextMenu() {
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  void clearCallbacks() {
    print("lemon-engine.clearCallbacks()");
    onMouseScroll = null;
    onLeftClicked = null;
    onLongLeftClicked = null;
    // onKeyReleased = null;
    // onKeyPressed = null;
    // onKeyHeld = null;
  }

  void setPaintColorWhite() {
    paint.color = Colors.white;
  }

  void setPaintStrokeWidth(double value) {
    paint.strokeWidth = value;
  }

  void setPaintColor(Color value) {
    if (paint.color == value) return;
    paint.color = value;
  }

  void internalOnPointerMove(PointerMoveEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  void internalOnPointerHover(PointerHoverEvent event) {
    previousMousePosition.x = mousePosition.x;
    previousMousePosition.y = mousePosition.y;
    mousePosition.x = event.position.dx;
    mousePosition.y = event.position.dy;
  }

  void internalOnPointerUp(PointerUpEvent event) {
    if (mouseLeftDown.value) {
      mouseLeftDown.value = false;
      return;
    }
    if (mouseRightDown.value) {
      mouseRightDown.value = false;
      return;
    }
  }

  void internalOnPointerDown(PointerDownEvent event) {
    if (event.buttons == 1) {
      mouseLeftDown.value = true;
      return;
    }
    if (event.buttons == 2) {
      mouseRightDown.value = true;
      return;
    }
  }

  void internalOnPointerSignal(PointerSignalEvent pointerSignalEvent) {
    if (pointerSignalEvent is PointerScrollEvent) {
      internalOnMouseScroll(pointerSignalEvent.scrollDelta.dy);
    }
  }

  /// override safe. run this snippet inside your initialization code.
  /// engine.onTapDown = (TapDownDetails details) => print('tap detected');
  GestureTapDownCallback? onTapDown;
  /// override safe
  GestureLongPressCallback? onLongPress;
  /// override safe
  GestureDragStartCallback? onPanStart;
  /// override safe
  GestureDragUpdateCallback? onPanUpdate;
  /// override safe
  GestureDragEndCallback? onPanEnd;
  /// override safe
  CallbackOnScreenSizeChanged? onScreenSizeChanged;
  /// override safe
  Function? onDispose;
  /// override safe
  DrawCanvas? onDrawCanvas;
  /// override safe
  DrawCanvas? onDrawForeground;
  /// override safe
  Function? onKeyPressedSpace;
  /// override safe
  Function? onLeftClicked;
  /// override safe
  Function? onLongLeftClicked;
  /// override safe
  Function(double value)? onMouseScroll;
  /// override safe
  Function? onRightClicked;
  /// override safe
  Function? onRightClickReleased;
  /// override safe
  Function(SharedPreferences sharedPreferences)? onInit;

  void internalOnPanStart(DragStartDetails details){
    panStarted = true;
    onPanStart?.call(details);
  }

  void internalOnPanEnd(DragEndDetails details){
    panStarted = false;
    onPanEnd?.call(details);
  }

  void internalPaint(Canvas _canvas, Size size) {
    canvas = _canvas;
    canvas.scale(zoom, zoom);
    canvas.translate(-camera.x, -camera.y);
    if (!initialized.value) return;
    if (onDrawCanvas == null) return;
    onDrawCanvas!.call(canvas, size);
    engineRenderFlushBuffer();
  }

  void internalInit() async {
    print("engine.internalInit()");
    disableRightClickContextMenu();
    paint.isAntiAlias = false;
    sharedPreferences = await SharedPreferences.getInstance();
    print("sharedPreferences ready");
    if (onInit != null) {
      await onInit!(sharedPreferences);
    }
    initialized.value = true;
  }
}

typedef CallbackOnScreenSizeChanged = void Function(
  double previousWidth,
    double previousHeight,
    double newWidth,
    double newHeight,
);

final keyboardInstance = RawKeyboard.instance;

void onKeyPressed(LogicalKeyboardKey key, Function action){
    if (keyPressed(key)) action.call();
}

// global utilities
bool keyPressed(LogicalKeyboardKey key) {
  return keyboardInstance.keysPressed.contains(key);
}

double screenToWorldX(double value) {
  return engine.camera.x + value / engine.zoom;
}

double screenToWorldY(double value) {
  return engine.camera.y + value / engine.zoom;
}

double worldToScreenX(double x) {
  return engine.zoom * (x - engine.camera.x);
}

double worldToScreenY(double y) {
  return engine.zoom * (y - engine.camera.y);
}

double distanceFromMouse(double x, double y) {
  return distanceBetween(mouseWorldX, mouseWorldY, x, y);
}

T closestToMouse<T extends Vector2>(List<T> values){
  return findClosest(values, mouseWorldX, mouseWorldY);
}

// global constants
const int millisecondsPerSecond = 1000;

// global properties
// Offset get mouseWorld => Offset(mouseWorldX, mouseWorldY);
final _mousePosition = engine.mousePosition;
final _screen = engine.screen;

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

  bool contains(double x, double y) {
    return
      x > left
          &&
      x < right
          &&
      y > top
          &&
      y < bottom
    ;
  }

}