import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  final colorList = <Color>[
    Color(0xff4285F4),
    Color(0xff1aa260),
    Color(0xffde5246),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .01),
              PieChart(
                dataMap: {"Total": 20, "Recovered": 15, "Deaths": 5},
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                legendOptions: LegendOptions(
                  legendPosition: LegendPosition.left,
                ),
                chartType: ChartType.ring,
                colorList: colorList,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * .06,
                ),
                child: Card(
                  child: Column(
                    children: [
                      ReusabelRow(title: 'Total', value: '230'),
                      ReusabelRow(title: 'deaths', value: '20'),
                      ReusabelRow(title: 'Total', value: '230'),
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xff1aa260),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('Track Countries')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReusabelRow extends StatelessWidget {
  String title, value;
  ReusabelRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(value)],
          ),
          SizedBox(height: 5),
          Divider(),
        ],
      ),
    );
  }
}
