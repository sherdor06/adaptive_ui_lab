import 'package:flutter/foundation.dart';

import 'ui_platform.dart';

class PlatformController {
  PlatformController({
    UiStyleMode initialMode = UiStyleMode.system,
    int initialTabIndex = 0,
  }) : mode = ValueNotifier<UiStyleMode>(initialMode),
       tabIndex = ValueNotifier<int>(initialTabIndex);

  final ValueNotifier<UiStyleMode> mode;
  final ValueNotifier<int> tabIndex;

  UiPlatform get platform => resolve(mode.value);

  UiPlatform resolve(UiStyleMode styleMode) {
    return switch (styleMode) {
      UiStyleMode.forceMaterial => UiPlatform.material,
      UiStyleMode.forceCupertino => UiPlatform.cupertino,
      UiStyleMode.system => switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.macOS => UiPlatform.cupertino,
        _ => UiPlatform.material,
      },
    };
  }

  void setMode(UiStyleMode value) => mode.value = value;

  void setTabIndex(int value) => tabIndex.value = value;

  void reset() {
    mode.value = UiStyleMode.system;
    tabIndex.value = 0;
  }

  void dispose() {
    mode.dispose();
    tabIndex.dispose();
  }
}

final PlatformController platformController = PlatformController();
