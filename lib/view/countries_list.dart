import 'dart:async';
import 'package:covid_tracker/Services/state_servies.dart';
import 'package:covid_tracker/view/country_record.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// NEW (shared theme + widgets)
import 'package:covid_tracker/theme/app_colors.dart';
import 'package:covid_tracker/view/widgets/mini_stat_chip.dart';

enum SortBy { none, cases, deaths, recovered, active, critical, tests }

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  final TextEditingController searchController = TextEditingController();
  final StateServies stateServies = StateServies();

  // Debounce for search
  Timer? _debounce;

  // --------- FILTER STATE ----------
  // Quick filter: Active thresholds (null = no filter)
  final List<int> _activeOptions = const [100, 1000, 10000, 100000];
  int? _activeMin;

  // Advanced filters
  int? _minCases;
  int? _minActive;
  int? _minDeaths;
  int? _minRecovered;
  int? _minTests;

  SortBy _sortBy = SortBy.none;
  bool _sortDesc = true;

  // Shortcut toggle
  bool _topByCases = false;

  // ---------------------------------

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() {});
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {});
  }

  Future<void> _refresh() async => setState(() {});

  // ---------- helpers (format & parse) ----------
  String _fmt(num? n) {
    final s = (n ?? 0).toString();
    if (s.contains('.') || s.length <= 3) return s;
    final b = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      b.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write(',');
        c = 0;
      }
    }
    return b.toString().split('').reversed.join();
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  // Apply filters + sort + search
  List<dynamic> _applyFilters(List<dynamic> list) {
    // 1) Filter
    final filtered = list.where((item) {
      final cases = _toInt(item['cases']);
      final active = _toInt(item['active']);
      final deaths = _toInt(item['deaths']);
      final recovered = _toInt(item['recovered']);
      final tests = _toInt(item['tests']);

      // quick active threshold
      if (_activeMin != null && active < _activeMin!) return false;

      // advanced minimums
      if (_minCases != null && cases < _minCases!) return false;
      if (_minActive != null && active < _minActive!) return false;
      if (_minDeaths != null && deaths < _minDeaths!) return false;
      if (_minRecovered != null && recovered < _minRecovered!) return false;
      if (_minTests != null && tests < _minTests!) return false;

      return true;
    }).toList();

    // 2) Sort
    SortBy effectiveSort = _sortBy;
    bool effectiveDesc = _sortDesc;

    if (_topByCases) {
      effectiveSort = SortBy.cases;
      effectiveDesc = true;
    }

    int getByKey(Map m, SortBy s) {
      switch (s) {
        case SortBy.cases:
          return _toInt(m['cases']);
        case SortBy.deaths:
          return _toInt(m['deaths']);
        case SortBy.recovered:
          return _toInt(m['recovered']);
        case SortBy.active:
          return _toInt(m['active']);
        case SortBy.critical:
          return _toInt(m['critical']);
        case SortBy.tests:
          return _toInt(m['tests']);
        case SortBy.none:
          return 0;
      }
    }

    if (effectiveSort != SortBy.none) {
      filtered.sort((a, b) {
        final av = getByKey(a as Map, effectiveSort);
        final bv = getByKey(b as Map, effectiveSort);
        final cmp = av.compareTo(bv);
        return effectiveDesc ? -cmp : cmp;
      });
    }

    // 3) Search (after filter/sort)
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return filtered;

    return filtered.where((item) {
      final name = (item['country'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  // Reset all filters
  void _clearFilters() {
    setState(() {
      _activeMin = null;
      _minCases = _minActive = _minDeaths = _minRecovered = _minTests = null;
      _sortBy = SortBy.none;
      _sortDesc = true;
      _topByCases = false;
    });
  }

  // ---- Bottom sheet for advanced filters ----
  void _openAdvancedFilters() {
    final minCasesCtrl = TextEditingController(
      text: _minCases?.toString() ?? "",
    );
    final minActiveCtrl = TextEditingController(
      text: _minActive?.toString() ?? "",
    );
    final minDeathsCtrl = TextEditingController(
      text: _minDeaths?.toString() ?? "",
    );
    final minRecoveredCtrl = TextEditingController(
      text: _minRecovered?.toString() ?? "",
    );
    final minTestsCtrl = TextEditingController(
      text: _minTests?.toString() ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Widget numField(String label, TextEditingController c) {
                return TextField(
                  controller: c,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: 'e.g. 1000',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                );
              }

              Widget sortChip(SortBy v, String label) {
                final selected = _sortBy == v;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  selectedColor: alpha(kPrimary, 0.18),
                  onSelected: (_) => setSheetState(() {
                    _sortBy = v;
                  }),
                  side: BorderSide(
                    color: selected ? kPrimary : alpha(Colors.black, 0.1),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: alpha(Colors.black, 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),

                  // Minimums grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width:
                            (MediaQuery.of(ctx).size.width - 16 * 2 - 12) / 2,
                        child: numField('Min Cases', minCasesCtrl),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(ctx).size.width - 16 * 2 - 12) / 2,
                        child: numField('Min Active', minActiveCtrl),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(ctx).size.width - 16 * 2 - 12) / 2,
                        child: numField('Min Deaths', minDeathsCtrl),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(ctx).size.width - 16 * 2 - 12) / 2,
                        child: numField('Min Recovered', minRecoveredCtrl),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(ctx).size.width - 16 * 2 - 12) / 2,
                        child: numField('Min Tests', minTestsCtrl),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sort By',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: [
                      sortChip(SortBy.none, 'None'),
                      sortChip(SortBy.cases, 'Cases'),
                      sortChip(SortBy.deaths, 'Deaths'),
                      sortChip(SortBy.recovered, 'Recovered'),
                      sortChip(SortBy.active, 'Active'),
                      sortChip(SortBy.critical, 'Critical'),
                      sortChip(SortBy.tests, 'Tests'),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Descending'),
                      const SizedBox(width: 8),
                      Switch(
                        value: _sortDesc,
                        activeColor: kPrimary,
                        onChanged: (v) => setSheetState(() {
                          _sortDesc = v;
                        }),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _clearFilters();
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _minCases = minCasesCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(minCasesCtrl.text.trim());
                            _minActive = minActiveCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(minActiveCtrl.text.trim());
                            _minDeaths = minDeathsCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(minDeathsCtrl.text.trim());
                            _minRecovered = minRecoveredCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(minRecoveredCtrl.text.trim());
                            _minTests = minTestsCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(minTestsCtrl.text.trim());
                            // If user sets explicit sort here, override "Top by Cases" toggle
                            if (_sortBy != SortBy.none) _topByCases = false;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ---- Quick filters bar (UI) ----
  Widget _buildQuickFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: alpha(kPrimary, 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alpha(kPrimary, 0.25)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Quick Filters',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          // Active threshold chips
          for (final v in _activeOptions)
            ChoiceChip(
              label: Text('Active ≥ ${_fmt(v)}'),
              selected: _activeMin == v,
              selectedColor: alpha(kPrimary, 0.18),
              onSelected: (_) => setState(() {
                _activeMin = (_activeMin == v) ? null : v;
              }),
              side: BorderSide(
                color: _activeMin == v ? kPrimary : alpha(Colors.black, 0.12),
              ),
            ),

          // Top by cases toggle
          FilterChip(
            label: const Text('Top by Cases'),
            selected: _topByCases,
            selectedColor: alpha(kPrimary, 0.18),
            onSelected: (sel) => setState(() {
              _topByCases = sel;
              if (sel) {
                _sortBy = SortBy.none;
              } // let this control sorting
            }),
            side: BorderSide(
              color: _topByCases ? kPrimary : alpha(Colors.black, 0.12),
            ),
          ),

          // Advanced button
          ActionChip(
            avatar: const Icon(Icons.tune, size: 18),
            label: const Text('Advanced'),
            onPressed: _openAdvancedFilters,
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(color: alpha(Colors.black, 0.12)),
            ),
          ),

          // Clear all
          if (_activeMin != null ||
              _topByCases ||
              _sortBy != SortBy.none ||
              _minCases != null ||
              _minActive != null ||
              _minDeaths != null ||
              _minRecovered != null ||
              _minTests != null)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  // ---- Optional applied-filters summary ----
  Widget _buildFiltersSummary(int count) {
    final parts = <String>[];
    if (_activeMin != null) parts.add('Active ≥ ${_fmt(_activeMin)}');
    if (_minCases != null) parts.add('Cases ≥ ${_fmt(_minCases)}');
    if (_minActive != null) parts.add('Active ≥ ${_fmt(_minActive)}');
    if (_minDeaths != null) parts.add('Deaths ≥ ${_fmt(_minDeaths)}');
    if (_minRecovered != null) parts.add('Recovered ≥ ${_fmt(_minRecovered)}');
    if (_minTests != null) parts.add('Tests ≥ ${_fmt(_minTests)}');

    if (_topByCases) {
      parts.add('Sort: Cases ↓');
    } else if (_sortBy != SortBy.none) {
      final name = _sortBy.name[0].toUpperCase() + _sortBy.name.substring(1);
      parts.add('Sort: $name ${_sortDesc ? '↓' : '↑'}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: alpha(Colors.black, 0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(parts.join(' · '))),
            const SizedBox(width: 8),
            Chip(
              label: Text('$count shown'),
              avatar: const Icon(Icons.list_alt, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------ UI ------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar (unchanged look)
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, Color(0xFF34C786)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Countries',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          edgeOffset: 8,
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search for a country',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear',
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Quick filters bar
              _buildQuickFilters(),

              // Results
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: stateServies.fetchCountriesList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Shimmer skeletons
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: 8,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 74,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const SizedBox(height: 40),
                          const Icon(
                            Icons.wifi_tethering_error_rounded,
                            size: 56,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load countries.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ),
                        ],
                      );
                    }

                    final list = snapshot.data ?? [];
                    final result = _applyFilters(list);
                    final shownCount = result.length;

                    if (shownCount == 0) {
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        children: const [
                          SizedBox(height: 24),
                          Icon(Icons.search_off, size: 56),
                          SizedBox(height: 12),
                          Text('No results found', textAlign: TextAlign.center),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildFiltersSummary(shownCount),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: result.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item =
                                  result[index] as Map<String, dynamic>;
                              final name = (item['country'] ?? '').toString();
                              final flag = (item['countryInfo']?['flag'] ?? '')
                                  .toString();

                              final cases = _fmt(item['cases']);
                              final recov = _fmt(item['recovered']);
                              final death = _fmt(item['deaths']);

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountryRecord(
                                        image: item['countryInfo']['flag'],
                                        name: item['country'],
                                        totalCases: item['cases'],
                                        totalRecovered: item['recovered'],
                                        totalDeaths: item['deaths'],
                                        active: item['active'],
                                        test: item['tests'],
                                        todayRecovered: item['todayRecovered'],
                                        critical: item['critical'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x11000000),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0F000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      // Flag
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          flag,
                                          height: 44,
                                          width: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 44,
                                                width: 44,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.flag),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Name + quick stats
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                MiniStatChip(
                                                  icon: Icons.coronavirus,
                                                  label: 'Cases',
                                                  value: cases,
                                                  color: kBlue,
                                                ),
                                                MiniStatChip(
                                                  icon: Icons.trending_up,
                                                  label: 'Recovered',
                                                  value: recov,
                                                  color: kPrimary,
                                                ),
                                                MiniStatChip(
                                                  icon: Icons.trending_down,
                                                  label: 'Deaths',
                                                  value: death,
                                                  color: kRed,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
