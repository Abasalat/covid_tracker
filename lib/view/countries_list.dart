import 'dart:async';
import 'package:covid_tracker/Services/state_servies.dart';
import 'package:covid_tracker/view/country_record.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ✅ new imports
import 'package:covid_tracker/theme/app_colors.dart';
import 'package:covid_tracker/view/widgets/mini_stat_chip.dart';

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  final TextEditingController searchController = TextEditingController();
  final StateServies stateServies = StateServies();

  Timer? _debounce;

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

              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: stateServies.fetchCountriesList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                    final query = searchController.text.trim().toLowerCase();
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
