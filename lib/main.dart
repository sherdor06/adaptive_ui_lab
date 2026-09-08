import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app/app_restart_controller.dart';
import 'core/platform/platform_controller.dart';
import 'core/platform/ui_platform.dart';
import 'data/fake_repository.dart';
import 'state/children_bloc.dart';
import 'state/schedule_bloc.dart';
import 'state/settings_bloc.dart';
import 'ui/cupertino/cupertino_app_root.dart';
import 'ui/material/material_app_root.dart';

void main() {
  runApp(AdaptiveUiLab(repository: FakeRepository()));
}

class AdaptiveUiLab extends StatelessWidget {
  const AdaptiveUiLab({required this.repository, super.key});

  final FakeRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChildrenBloc>(create: (_) => ChildrenBloc(repository)),
        BlocProvider<ScheduleBloc>(create: (_) => ScheduleBloc(repository)),
        BlocProvider<SettingsBloc>(create: (_) => SettingsBloc(repository)),
      ],
      child: ValueListenableBuilder<int>(
        valueListenable: appRestartController.tick,
        builder: (context, tick, _) => KeyedSubtree(
          key: ValueKey<int>(tick),
          child: ValueListenableBuilder<UiStyleMode>(
            valueListenable: platformController.mode,
            builder: (context, mode, _) {
              return switch (platformController.resolve(mode)) {
                UiPlatform.material => const MaterialAppRoot(),
                UiPlatform.cupertino => const CupertinoAppRoot(),
              };
            },
          ),
        ),
      ),
    );
  }
}
