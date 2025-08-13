import 'package:covid_tracker/Model/world_state_model.dart';
import 'package:covid_tracker/Services/state_servies.dart';
import 'package:covid_tracker/view/countries_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';

class WorldstateScreen extends StatefulWidget {
  const WorldstateScreen({super.key});

  @override
  State<WorldstateScreen> createState() => _WorldstateScreenState();
}

class _WorldstateScreenState extends State<WorldstateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  final StateServies stateServies = StateServies();

  // Brand colors
  static const Color kPrimary = Color(0xff1aa260);
  static const Color kBlue = Color(0xff4285F4);
  static const Color kRed = Color(0xffde5246);

  final List<Color> colorList = const [kBlue, kPrimary, kRed];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => setState(() {});

  String _fmt(num? n) {
    // Simple thousands separator without extra packages
    final s = (n ?? 0).toString();
    if (s.contains('.') || s.length <= 3) return s;
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern AppBar with gradient + rounded bottom
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
              'COVID-19 Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Global overview',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Countries',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CountriesListScreen()),
              );
            },
            icon: const Icon(Icons.flag),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          edgeOffset: 8,
          child: FutureBuilder<WorldStateModel>(
            future: stateServies.fetchWorldStateRecords(),
            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          SpinKitFadingCircle(
                            color: kPrimary,
                            size: 56,
                            controller: _controller,
                          ),
                          const SizedBox(height: 16),
                          const Text('Fetching latest global stats...'),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Error
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.wifi_tethering_error_rounded, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load data.\n${snapshot.error}',
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

              final data = snapshot.data!;
              final total = data.cases ?? 0;
              final recovered = data.recovered ?? 0;
              final deaths = data.deaths ?? 0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // Top KPI tiles
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'Total',
                          value: _fmt(total),
                          icon: Icons.public,
                          bg: const Color(0x112485F4),
                          iconColor: kBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'Active',
                          value: _fmt(data.active ?? 0),
                          icon: Icons.local_hospital_outlined,
                          bg: const Color(0x111AA260),
                          iconColor: kPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'Recovered',
                          value: _fmt(recovered),
                          icon: Icons.trending_up,
                          bg: const Color(0x111AA260),
                          iconColor: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'Deaths',
                          value: _fmt(deaths),
                          icon: Icons.trending_down,
                          bg: const Color(0x11DE5246),
                          iconColor: kRed,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Distribution Ring Chart
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionHeader('Distribution'),
                          const SizedBox(height: 12),
                          PieChart(
                            dataMap: {
                              "Total": total.toDouble(),
                              "Recovered": recovered.toDouble(),
                              "Deaths": deaths.toDouble(),
                            },
                            chartType: ChartType.ring,
                            chartRadius: MediaQuery.of(context).size.width / 3,
                            colorList: colorList,
                            legendOptions: const LegendOptions(
                              legendPosition: LegendPosition.left,
                              showLegendsInRow: false,
                              legendTextStyle: TextStyle(fontSize: 12),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValuesInPercentage: true,
                              showChartValuesOutside: false,
                              decimalPlaces: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.today,
                                label: 'Today Recovered',
                                value: _fmt(data.todayRecovered ?? 0),
                                bg: const Color(0x1A1AA260),
                              ),
                              _InfoChip(
                                icon: Icons.event_busy,
                                label: 'Today Deaths',
                                value: _fmt(data.todayDeaths ?? 0),
                                bg: const Color(0x1ADE5246),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detailed Summary (keeps your ReusabelRow fields)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          const _SectionHeader('Detailed Summary'),
                          const SizedBox(height: 6),
                          ReusabelRow(title: 'Total', value: _fmt(total)),
                          ReusabelRow(title: 'Deaths', value: _fmt(deaths)),
                          ReusabelRow(
                            title: 'Recovered',
                            value: _fmt(recovered),
                          ),
                          ReusabelRow(
                            title: 'Active',
                            value: _fmt(data.active ?? 0),
                          ),
                          ReusabelRow(
                            title: 'Critical',
                            value: _fmt(data.critical ?? 0),
                          ),
                          ReusabelRow(
                            title: 'Today Deaths',
                            value: _fmt(data.todayDeaths ?? 0),
                          ),
                          ReusabelRow(
                            title: 'Today Recovered',
                            value: _fmt(data.todayRecovered ?? 0),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Navigate to countries
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CountriesListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text(
                        'Track Countries',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- Small UI helpers (pure UI, no logic change) ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.assessment_outlined, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bg;
  final Color iconColor;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bg.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}

// Your existing ReusabelRow with nicer spacing (UI only)
class ReusabelRow extends StatelessWidget {
  final String title, value;
  const ReusabelRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final textStyleValue = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textStyleTitle),
              Text(value, style: textStyleValue),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
