import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/platform/platform_controller.dart';
import '../shared/app_strings.dart';
import 'c_children_page.dart';
import 'c_schedule_page.dart';
import 'c_settings_page.dart';

class CTabsShell extends StatefulWidget {
  const CTabsShell({super.key});

  @override
  State<CTabsShell> createState() => _CTabsShellState();
}

class _CTabsShellState extends State<CTabsShell> {
  late final CupertinoTabController _tabController = CupertinoTabController(
    initialIndex: platformController.tabIndex.value,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        onTap: (index) {
          HapticFeedback.selectionClick();
          platformController.setTabIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            activeIcon: Icon(CupertinoIcons.person_2_fill),
            label: AppStrings.tabChildren,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            activeIcon: Icon(CupertinoIcons.clock_fill),
            label: AppStrings.tabSchedule,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => switch (index) {
            0 => const CChildrenPage(),
            1 => const CSchedulePage(),
            _ => const CSettingsPage(),
          },
        );
      },
    );
  }
}
