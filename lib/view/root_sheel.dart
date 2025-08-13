import 'package:flutter/material.dart';
import 'package:covid_tracker/view/worldstate_screen.dart';
import 'package:covid_tracker/view/countries_list.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // Holds small per-page states (like scroll position)
  final PageStorageBucket _bucket = PageStorageBucket();

  // Keep tabs alive; give each a PageStorageKey (no inner PageStorage needed)
  final List<Widget> _pages = const [
    WorldstateScreen(key: PageStorageKey('global_overview')),
    CountriesListScreen(key: PageStorageKey('countries_list')),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow system back only on the first tab
      canPop: _index == 0,
      // New API (replaces deprecated onPopInvoked)
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0); // go to first tab
        }
      },
      child: Scaffold(
        body: PageStorage(
          bucket: _bucket,
          // IndexedStack keeps both tabs alive; keys + PageStorage remember scroll
          child: IndexedStack(index: _index, children: _pages),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Global'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Countries'),
          ],
        ),
      ),
    );
  }
}
