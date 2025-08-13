import 'dart:async';
import 'package:covid_tracker/Services/state_servies.dart';
import 'package:covid_tracker/view/country_record.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  final TextEditingController searchController = TextEditingController();
  final StateServies stateServies = StateServies();

  static const Color kPrimary = Color(0xff1aa260);
  static const Color kBlue = Color(0xff4285F4);
  static const Color kRed = Color(0xffde5246);

  Timer? _debounce;

  // ---- helpers (replace deprecated withOpacity) ----
  int _a(double opacity) => (opacity * 255).round().clamp(0, 255);
  Color _alpha(Color c, double opacity) => c.withAlpha(_a(opacity));
  // --------------------------------------------------

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

  Future<void> _refresh() async {
    setState(() {}); // re-run FutureBuilder
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Better AppBar with gradient + rounded bottom
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
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

              // Results list
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
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 74,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
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
                    final query = searchController.text.trim().toLowerCase();

                    // Filter
                    final filtered = query.isEmpty
                        ? list
                        : list.where((item) {
                            final name = (item['country'] ?? '')
                                .toString()
                                .toLowerCase();
                            return name.contains(query);
                          }).toList();

                    if (filtered.isEmpty) {
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
                        // Results count chip
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Chip(
                              label: Text(
                                '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                              ),
                              avatar: const Icon(Icons.list_alt, size: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
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
                                                _MiniStatChip(
                                                  icon: Icons.coronavirus,
                                                  label: 'Cases',
                                                  value: cases,
                                                  color: kBlue,
                                                  alpha: _alpha,
                                                ),
                                                _MiniStatChip(
                                                  icon: Icons.trending_up,
                                                  label: 'Recovered',
                                                  value: recov,
                                                  color: kPrimary,
                                                  alpha: _alpha,
                                                ),
                                                _MiniStatChip(
                                                  icon: Icons.trending_down,
                                                  label: 'Deaths',
                                                  value: death,
                                                  color: kRed,
                                                  alpha: _alpha,
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

// Small UI chip for quick stats in the list
class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color Function(Color, double) alpha;

  const _MiniStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: alpha(color, 0.08), // <- no withOpacity
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: alpha(color, 0.20)), // <- no withOpacity
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
