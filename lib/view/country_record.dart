import 'package:flutter/material.dart';

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
    required this.name,
    required this.image,
    required this.totalCases,
    required this.totalDeaths,
    required this.totalRecovered,
    required this.active,
    required this.critical,
    required this.todayRecovered,
    required this.test,
    super.key,
  });

  @override
  State<CountryRecord> createState() => _CountryRecordState();
}

class _CountryRecordState extends State<CountryRecord> {
  // Brand colors (aligned across the app)
  static const Color kPrimary = Color(0xff1aa260);
  static const Color kBlue = Color(0xff4285F4);
  static const Color kRed = Color(0xffde5246);
  static const Color kAmber = Color(0xfff4b400);

  // ---- helpers (no withOpacity) ----
  int _a(double o) => (o * 255).round().clamp(0, 255);
  Color _alpha(Color c, double o) => c.withAlpha(_a(o));

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
  // -----------------------------------

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
          // Collapsing header with flag
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
                  // subtle dark gradient for contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _alpha(Colors.black, 0.15),
                          _alpha(Colors.black, 0.40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Detailed Summary (single card, green border + green shade, no overflow) ---
                  Card(
                    elevation: 0,
                    color: _alpha(kPrimary, 0.06), // soft green background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _alpha(kPrimary, 0.40),
                        width: 1.2,
                      ), // green border
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.assessment_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Detailed Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Wrap + LayoutBuilder prevents overflow on small screens
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const gap = 12.0;
                              final tileWidth =
                                  (constraints.maxWidth - gap) / 2;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Cases',
                                      value: _fmt(cases),
                                      icon: Icons.coronavirus,
                                      color: kBlue,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Deaths',
                                      value: _fmt(deaths),
                                      icon: Icons.trending_down,
                                      color: kRed,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Recovered',
                                      value: _fmt(recov),
                                      icon: Icons.trending_up,
                                      color: kPrimary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Active',
                                      value: _fmt(active),
                                      icon: Icons.local_hospital_outlined,
                                      color: kAmber,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Critical',
                                      value: _fmt(critical),
                                      icon: Icons.warning_amber_rounded,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
                                      label: 'Tests',
                                      value: _fmt(tests),
                                      icon: Icons.biotech_outlined,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  SizedBox(
                                    width: tileWidth,
                                    child: _StatTile(
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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Insights & Ratios (derived from existing fields) ---
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

                          _ProgressStatRow(
                            label: 'Recovery rate',
                            valueText: _pctStr(recov, cases),
                            value: _safePct(recov, cases),
                            color: kPrimary,
                            alpha: _alpha,
                          ),
                          const SizedBox(height: 10),

                          _ProgressStatRow(
                            label: 'Fatality rate',
                            valueText: _pctStr(deaths, cases),
                            value: _safePct(deaths, cases),
                            color: kRed,
                            alpha: _alpha,
                          ),
                          const SizedBox(height: 10),

                          _ProgressStatRow(
                            label: 'Active rate',
                            valueText: _pctStr(active, cases),
                            value: _safePct(active, cases),
                            color: kAmber,
                            alpha: _alpha,
                          ),
                          const SizedBox(height: 10),

                          _ProgressStatRow(
                            label: 'Critical share of active',
                            valueText: _pctStr(critical, active),
                            value: _safePct(critical, active),
                            color: Colors.deepOrange,
                            alpha: _alpha,
                          ),

                          const SizedBox(height: 12),

                          // quick ratio pills
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PillChip(
                                label: 'Closed',
                                value: _fmt(closed),
                                color: Colors.blueGrey,
                                alpha: _alpha,
                              ),
                              _PillChip(
                                label: 'Closed recovery',
                                value: _pctStr(recov, closed),
                                color: kPrimary,
                                alpha: _alpha,
                              ),
                              _PillChip(
                                label: 'Closed fatality',
                                value: _pctStr(deaths, closed),
                                color: kRed,
                                alpha: _alpha,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Testing Overview ---
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
                              _PillChip(
                                label: 'Tests',
                                value: _fmt(tests),
                                color: Colors.indigo,
                                alpha: _alpha,
                              ),
                              _PillChip(
                                label: 'Tests / Case',
                                value: (cases > 0)
                                    ? (tests / cases).toStringAsFixed(1)
                                    : '—',
                                color: Colors.indigo,
                                alpha: _alpha,
                              ),
                              _PillChip(
                                label: 'Positivity',
                                value: (tests > 0)
                                    ? _pctStr(cases, tests)
                                    : '—',
                                color: Colors.indigo,
                                alpha: _alpha,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          _ProgressStatRow(
                            label: 'Positivity (cases ÷ tests)',
                            valueText: (tests > 0)
                                ? _pctStr(cases, tests)
                                : '—',
                            value: (tests > 0) ? _safePct(cases, tests) : 0,
                            color: Colors.indigo,
                            alpha: _alpha,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // breathing room at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Reusable UI helpers (pure UI, no logic change) ----------

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  int _a(double o) => (o * 255).round().clamp(0, 255);
  Color _alpha(Color c, double o) => c.withAlpha(_a(o));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _alpha(color, 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _alpha(color, 0.20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _alpha(color, 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
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

class _ProgressStatRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double value; // 0..1
  final Color color;
  final Color Function(Color, double) alpha;

  const _ProgressStatRow({
    required this.label,
    required this.valueText,
    required this.value,
    required this.color,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    final bg = alpha(color, 0.15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(valueText, style: const TextStyle(fontFeatures: [])),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value.isNaN ? 0 : value.clamp(0, 1),
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color Function(Color, double) alpha;

  const _PillChip({
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
        color: alpha(color, 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: alpha(color, 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
