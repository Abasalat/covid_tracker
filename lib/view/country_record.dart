import 'package:covid_tracker/view/worldstate_screen.dart';
import 'package:flutter/material.dart';

class CountryRecord extends StatefulWidget {
  String name, image;
  int totalCases,
      totalDeaths,
      totalRecovered,
      active,
      critical,
      todayRecovered,
      test;

  CountryRecord({
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.067,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        ReusabelRow(
                          title: 'Cases',
                          value: widget.totalCases.toString(),
                        ),
                        ReusabelRow(
                          title: 'Deaths',
                          value: widget.totalDeaths.toString(),
                        ),
                        ReusabelRow(
                          title: 'Recovered',
                          value: widget.totalRecovered.toString(),
                        ),
                        ReusabelRow(
                          title: 'Active',
                          value: widget.active.toString(),
                        ),
                        ReusabelRow(
                          title: 'Critical',
                          value: widget.critical.toString(),
                        ),
                        ReusabelRow(
                          title: 'Today Recovered',
                          value: widget.todayRecovered.toString(),
                        ),
                        ReusabelRow(
                          title: 'Tests',
                          value: widget.test.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.image),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
