import 'package:covid_tracker/Model/world_state_model.dart';
import 'package:covid_tracker/Services/state_servies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';
import 'root_shell.dart';

// ✅ new imports
import 'package:covid_tracker/theme/app_colors.dart';
import 'package:covid_tracker/view/widgets/kpi_tile.dart';
import 'package:covid_tracker/view/widgets/section_header.dart';
import 'package:covid_tracker/view/widgets/info_chip.dart';
import 'widgets/stat_tile.dart';

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

  // use shared colors
  final List<Color> colorList = const [kBlue, kPrimary, kRed];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => setState(() {});

  String _fmt(num? n) {
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
          ],
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          edgeOffset: 8,
          child: FutureBuilder<WorldStateModel>(
            future: stateServies.fetchWorldStateRecords(),
            builder: (context, snapshot) {
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
                  Row(
                    children: [
                      Expanded(
                        child: KpiTile(
                          label: 'Total',
                          value: _fmt(total),
                          icon: Icons.public,
                          bg: const Color(0x112485F4),
                          iconColor: kBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiTile(
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
                        child: KpiTile(
                          label: 'Recovered',
                          value: _fmt(recovered),
                          icon: Icons.trending_up,
                          bg: const Color(0x111AA260),
                          iconColor: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiTile(
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
                          const SectionHeader('Distribution'),
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
                              InfoChip(
                                icon: Icons.today,
                                label: 'Today Recovered',
                                value: _fmt(data.todayRecovered ?? 0),
                                bg: const Color(0x1A1AA260),
                              ),
                              InfoChip(
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

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionHeader('Detailed Summary'),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final gap = 12.0;
                              final tileWidth =
                                  (constraints.maxWidth - gap) / 2;
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Total',
                                      value: _fmt(total),
                                      icon: Icons.public,
                                      color: kBlue,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Deaths',
                                      value: _fmt(deaths),
                                      icon: Icons.trending_down,
                                      color: kRed,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Recovered',
                                      value: _fmt(recovered),
                                      icon: Icons.trending_up,
                                      color: kPrimary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Active',
                                      value: _fmt(data.active ?? 0),
                                      icon: Icons.local_hospital_outlined,
                                      color: const Color(0xfff4b400),
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Critical',
                                      value: _fmt(data.critical ?? 0),
                                      icon: Icons.warning_amber_rounded,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Today Deaths',
                                      value: _fmt(data.todayDeaths ?? 0),
                                      icon: Icons.event_busy,
                                      color: kRed,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: StatTile(
                                      label: 'Today Recovered',
                                      value: _fmt(data.todayRecovered ?? 0),
                                      icon: Icons.today,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => RootShell(initialIndex: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text(
                        'Track Countries',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
