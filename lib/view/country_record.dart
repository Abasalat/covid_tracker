import 'package:flutter/material.dart';
import 'package:covid_tracker/theme/app_colors.dart';
import 'package:covid_tracker/view/widgets/stat_tile.dart';
import 'package:covid_tracker/view/widgets/progress_stat_row.dart';
import 'package:covid_tracker/view/widgets/pill_chip.dart';

class CountryRecord extends StatefulWidget {
  final String name, image;
  final int totalCases,
      totalDeaths,
      totalRecovered,
      active,
      critical,
      todayRecovered,
      test;

  const CountryRecord({
    super.key,
    required this.name,
    required this.image,
    required this.totalCases,
    required this.totalDeaths,
    required this.totalRecovered,
    required this.active,
    required this.critical,
    required this.todayRecovered,
    required this.test,
  });

  @override
  State<CountryRecord> createState() => _CountryRecordState();
}

class _CountryRecordState extends State<CountryRecord> {
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

  double _safePct(num part, num total) {
    if (total <= 0) return 0;
    final v = part / total;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 1).toDouble();
  }

  String _pctStr(num part, num total, {int dp = 1}) {
    final v = _safePct(part, total) * 100;
    return '${v.toStringAsFixed(dp)}%';
  }

  @override
  Widget build(BuildContext context) {
    final cases = widget.totalCases;
    final deaths = widget.totalDeaths;
    final recov = widget.totalRecovered;
    final active = widget.active;
    final critical = widget.critical;
    final todayRec = widget.todayRecovered;
    final tests = widget.test;

    final closed = (recov + deaths);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            elevation: 0,
            backgroundColor: kPrimary,
            centerTitle: true,
            leading: const BackButton(color: Colors.white),
            title: Text(
              widget.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.flag, size: 48)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          alpha(Colors.black, 0.15),
                          alpha(Colors.black, 0.40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Detailed Summary (single card, green border + shade)
                  Card(
                    elevation: 0,
                    color: alpha(kPrimary, 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: alpha(kPrimary, 0.40),
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 12.0;
                          final tileWidth = (constraints.maxWidth - gap) / 2;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              SizedBox(
                                width: tileWidth,
                                child: StatTile(
                                  label: 'Cases',
                                  value: _fmt(cases),
                                  icon: Icons.coronavirus,
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
                                  value: _fmt(recov),
                                  icon: Icons.trending_up,
                                  color: kPrimary,
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: StatTile(
                                  label: 'Active',
                                  value: _fmt(active),
                                  icon: Icons.local_hospital_outlined,
                                  color: const Color(0xfff4b400),
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: StatTile(
                                  label: 'Critical',
                                  value: _fmt(critical),
                                  icon: Icons.warning_amber_rounded,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: StatTile(
                                  label: 'Tests',
                                  value: _fmt(tests),
                                  icon: Icons.biotech_outlined,
                                  color: Colors.indigo,
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: StatTile(
                                  label: 'Today Recovered',
                                  value: _fmt(todayRec),
                                  icon: Icons.today,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Insights & Ratios
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.insights_outlined, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Insights & Ratios',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ProgressStatRow(
                            label: 'Recovery rate',
                            valueText: _pctStr(recov, cases),
                            value: _safePct(recov, cases),
                            color: kPrimary,
                          ),
                          const SizedBox(height: 10),
                          ProgressStatRow(
                            label: 'Fatality rate',
                            valueText: _pctStr(deaths, cases),
                            value: _safePct(deaths, cases),
                            color: kRed,
                          ),
                          const SizedBox(height: 10),
                          ProgressStatRow(
                            label: 'Active rate',
                            valueText: _pctStr(active, cases),
                            value: _safePct(active, cases),
                            color: const Color(0xfff4b400),
                          ),
                          const SizedBox(height: 10),
                          ProgressStatRow(
                            label: 'Critical share of active',
                            valueText: _pctStr(critical, active),
                            value: _safePct(critical, active),
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PillChip(
                                label: 'Closed',
                                value: _fmt(recov + deaths),
                                color: Colors.blueGrey,
                              ),
                              PillChip(
                                label: 'Closed recovery',
                                value: _pctStr(recov, recov + deaths),
                                color: kPrimary,
                              ),
                              PillChip(
                                label: 'Closed fatality',
                                value: _pctStr(deaths, recov + deaths),
                                color: kRed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Testing Overview
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.biotech_outlined, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Testing Overview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PillChip(
                                label: 'Tests',
                                value: _fmt(tests),
                                color: Colors.indigo,
                              ),
                              PillChip(
                                label: 'Tests / Case',
                                value: (cases > 0)
                                    ? (tests / cases).toStringAsFixed(1)
                                    : '—',
                                color: Colors.indigo,
                              ),
                              PillChip(
                                label: 'Positivity',
                                value: (tests > 0)
                                    ? _pctStr(cases, tests)
                                    : '—',
                                color: Colors.indigo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ProgressStatRow(
                            label: 'Positivity (cases ÷ tests)',
                            valueText: (tests > 0)
                                ? _pctStr(cases, tests)
                                : '—',
                            value: (tests > 0) ? _safePct(cases, tests) : 0,
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
