import 'package:flutter/material.dart';
import 'package:covid_tracker/view/worldstate_screen.dart';
import 'package:covid_tracker/view/countries_list.dart';
import 'package:covid_tracker/theme/app_colors.dart'; // ✅ new

class RootShell extends StatefulWidget {
  final int initialIndex; // 0 = Global, 1 = Countries
  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _pages = const [
    WorldstateScreen(key: PageStorageKey('global_overview')),
    CountriesListScreen(key: PageStorageKey('countries_list')),
  ];

  @override
  void initState() {
    super.initState();
    _index = (widget.initialIndex >= 0 && widget.initialIndex < _pages.length)
        ? widget.initialIndex
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) setState(() => _index = 0);
      },
      child: Scaffold(
        body: PageStorage(
          bucket: _bucket,
          child: IndexedStack(index: _index, children: _pages),
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: kPrimary,
            backgroundColor: Colors.white,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(color: selected ? Colors.white : kPrimary);
            }),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.public),
                label: 'Global',
                selectedIcon: Icon(Icons.public),
              ),
              NavigationDestination(
                icon: Icon(Icons.flag),
                label: 'Countries',
                selectedIcon: Icon(Icons.flag),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
