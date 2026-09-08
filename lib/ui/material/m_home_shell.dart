import 'package:flutter/material.dart';

import '../../core/platform/platform_controller.dart';
import '../shared/app_strings.dart';
import 'm_children_page.dart';
import 'm_schedule_page.dart';
import 'm_settings_page.dart';

class MHomeShell extends StatefulWidget {
  const MHomeShell({super.key});

  @override
  State<MHomeShell> createState() => _MHomeShellState();
}

class _MHomeShellState extends State<MHomeShell> {
  late int _index = platformController.tabIndex.value;
  late final Set<int> _mounted = <int>{_index};

  static const List<Widget> _pages = [
    MChildrenPage(),
    MSchedulePage(),
    MSettingsPage(),
  ];

  void _onDestinationSelected(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _mounted.add(index);
    });
    platformController.setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _pages.length; i++)
            if (_mounted.contains(i)) _pages[i] else const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: AppStrings.tabChildren,
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: AppStrings.tabSchedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }
}
