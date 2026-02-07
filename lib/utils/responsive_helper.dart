import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  static bool isWeb() => kIsWeb;

  static bool isMobile() => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool isAndroid() => !kIsWeb && Platform.isAndroid;

  static bool isIOS() => !kIsWeb && Platform.isIOS;

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1024;
  }

  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 1024;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = screenWidth(context);

    if (kIsWeb) {
      if (width >= 1024) return DeviceType.desktop;
      if (width >= 600) return DeviceType.tablet;
      return DeviceType.mobile;
    }

    if (width >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile * 1.2;
      case DeviceType.desktop:
        return desktop ?? mobile * 1.4;
    }
  }

  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile * 1.5;
      case DeviceType.desktop:
        return desktop ?? mobile * 2;
    }
  }

  static int getCrossAxisCount(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  static double getMaxWidth(BuildContext context, {
    double? maxWidth,
  }) {
    if (maxWidth != null && screenWidth(context) > maxWidth) {
      return maxWidth;
    }
    return screenWidth(context);
  }

  static bool shouldUseSideMenu(BuildContext context) {
    return getDeviceType(context) != DeviceType.mobile;
  }

  static double getGameGridAspectRatio(BuildContext context) {
    if (isLandscape(context)) {
      return isMobile() ? 1.5 : 2.0;
    } else {
      return 1.0;
    }
  }

  static int getQuestionGridColumns(BuildContext context) {
    if (isLandscape(context)) {
      return isMobile() ? 5 : 6;
    } else {
      final deviceType = getDeviceType(context);
      switch (deviceType) {
        case DeviceType.mobile:
          return 3;
        case DeviceType.tablet:
          return 4;
        case DeviceType.desktop:
          return 5;
      }
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final safePadding = MediaQuery.of(context).padding;

    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.only(
          left: 16.0 + safePadding.left,
          right: 16.0 + safePadding.right,
          top: 16.0 + safePadding.top,
          bottom: 16.0 + safePadding.bottom,
        );
      case DeviceType.tablet:
        return EdgeInsets.only(
          left: 24.0 + safePadding.left,
          right: 24.0 + safePadding.right,
          top: 24.0 + safePadding.top,
          bottom: 24.0 + safePadding.bottom,
        );
      case DeviceType.desktop:
        return EdgeInsets.only(
          left: 32.0 + safePadding.left,
          right: 32.0 + safePadding.right,
          top: 32.0 + safePadding.top,
          bottom: 32.0 + safePadding.bottom,
        );
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

class OrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;

  const OrientationLayout({
    Key? key,
    required this.portrait,
    required this.landscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return landscape;
        }
        return portrait;
      },
    );
  }
}

class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveConstrainedBox({
    Key? key,
    required this.child,
    this.maxWidth = 1200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}
