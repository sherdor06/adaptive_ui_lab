import 'package:flutter/foundation.dart';

class AppRestartController {
  final ValueNotifier<int> tick = ValueNotifier<int>(0);

  void restart() => tick.value++;

  void reset() => tick.value = 0;

  void dispose() => tick.dispose();
}

final AppRestartController appRestartController = AppRestartController();
