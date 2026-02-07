import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class OrientationManager {
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> unlockAll() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> hideSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  static Future<void> showSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}

class OrientationAwareWidget extends StatefulWidget {
  final Widget child;
  final bool allowRotation;
  final bool preferLandscape;
  final bool hideSystemUI;

  const OrientationAwareWidget({
    Key? key,
    required this.child,
    this.allowRotation = true,
    this.preferLandscape = false,
    this.hideSystemUI = false,
  }) : super(key: key);

  @override
  State<OrientationAwareWidget> createState() => _OrientationAwareWidgetState();
}

class _OrientationAwareWidgetState extends State<OrientationAwareWidget> {
  @override
  void initState() {
    super.initState();
    _setOrientation();
  }

  @override
  void dispose() {
    OrientationManager.unlockAll();
    if (widget.hideSystemUI) {
      OrientationManager.showSystemUI();
    }
    super.dispose();
  }

  Future<void> _setOrientation() async {
    if (!widget.allowRotation) {
      if (widget.preferLandscape) {
        await OrientationManager.lockLandscape();
      } else {
        await OrientationManager.lockPortrait();
      }
    } else {
      await OrientationManager.unlockAll();
    }

    if (widget.hideSystemUI) {
      await OrientationManager.hideSystemUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class GameScreenWrapper extends StatefulWidget {
  final Widget child;
  final bool preferLandscape;

  const GameScreenWrapper({
    Key? key,
    required this.child,
    this.preferLandscape = true,
  }) : super(key: key);

  @override
  State<GameScreenWrapper> createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends State<GameScreenWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.preferLandscape) {
      OrientationManager.unlockAll();
    }
  }

  @override
  void dispose() {
    OrientationManager.unlockAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
