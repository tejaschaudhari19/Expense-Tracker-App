import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Widgets/info_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalCredits = 0;
  int totalDebits = 0;
  List<BarChartGroupData> weeklyData = [];
  List<BarChartGroupData> monthlyData = [];
  List<BarChartGroupData> yearlyData = [];
  List<String> weeklyLabels = [];
  List<String> monthlyLabels = [];
  List<String> yearlyLabels = [];

  @override
  void initState() {
    super.initState();
    fetchTransactionData();
  }

  Future<void> fetchTransactionData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is logged in',
        );
      }

      final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref('transactions/${user.uid}');
      final DatabaseEvent event = await dbRef.once();

      if (event.snapshot.value != null) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(event.snapshot.value as Map);

        int credits = 0;
        int debits = 0;

        final Map<String, Map<String, int>> weeklyMap = {};
        final Map<String, Map<String, int>> monthlyMap = {};
        final Map<String, Map<String, int>> yearlyMap = {};

        data.forEach((key, value) {
          final transaction = Map<String, dynamic>.from(value);
          final int amount = transaction['amount'] ?? 0;
          final String type = transaction['type'] ?? '';
          final String dateStr = transaction['date'] ?? '';
          final DateTime date = DateTime.parse(dateStr);

          if (type == 'Credit') {
            credits += amount;
          } else if (type == 'Debit') {
            debits += amount;
          }

          final String weekKey = "${date.year}-${date.month}-${date.day}";
          final String monthKey = "${date.year}-${date.month}";
          final String yearKey = "${date.year}";

          if (DateTime.now().difference(date).inDays <= 7) {
            weeklyMap.update(weekKey, (value) {
              value.update(type, (v) => v + amount, ifAbsent: () => amount);
              return value;
            }, ifAbsent: () => {type: amount});
          }

          if (DateTime.now().difference(date).inDays <= 30) {
            monthlyMap.update(monthKey, (value) {
              value.update(type, (v) => v + amount, ifAbsent: () => amount);
              return value;
            }, ifAbsent: () => {type: amount});
          }

          if (DateTime.now().difference(date).inDays <= 365) {
            yearlyMap.update(yearKey, (value) {
              value.update(type, (v) => v + amount, ifAbsent: () => amount);
              return value;
            }, ifAbsent: () => {type: amount});
          }
        });

        final week = _prepareChartData(weeklyMap);
        final month = _prepareChartData(monthlyMap);
        final year = _prepareChartData(yearlyMap);

        setState(() {
          totalCredits = credits;
          totalDebits = debits;
          weeklyData = week.data;
          weeklyLabels = week.labels;
          monthlyData = month.data;
          monthlyLabels = month.labels;
          yearlyData = year.data;
          yearlyLabels = year.labels;
        });
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  _ChartData _prepareChartData(Map<String, Map<String, int>> dataMap) {
    List<BarChartGroupData> data = [];
    List<String> labels = [];
    int index = 0;

    dataMap.forEach((key, value) {
      data.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (value['Credit'] ?? 0).toDouble(),
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: (value['Debit'] ?? 0).toDouble(),
            color: Colors.red,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 8,
      ));
      labels.add(key);
      index++;
    });

    return _ChartData(data, labels);
  }

  BarChartData buildBarChartData(List<BarChartGroupData> data, List<String> labels) {
    return BarChartData(
      barGroups: data,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < labels.length) {
                return Text(
                  labels[index],
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                );
              }
              return const Text("");
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 500, //
            getTitlesWidget: (value, meta) {
              return Text(
                "₹${value.toInt()}",
                style: const TextStyle(color: Colors.black, fontSize: 10),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 500,
      ),
      borderData: FlBorderData(show: true),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipMargin: 5,
          tooltipPadding: const EdgeInsets.all(5),
          fitInsideVertically: true,
          fitInsideHorizontally: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              "₹${rod.toY.toInt()}",
              const TextStyle(color: Colors.black, fontSize: 12),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InfoCard(title: "Total Credits", amount: "₹$totalCredits"),
                InfoCard(title: "Total Debits", amount: "₹$totalDebits"),
              ],
            ),
            const SizedBox(height: 20),
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabBar(
                      indicatorColor: Colors.black,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: "Week"),
                        Tab(text: "Month"),
                        Tab(text: "Year"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          buildChartSection(weeklyData, weeklyLabels, "No Weekly Data Available"),
                          buildChartSection(monthlyData, monthlyLabels, "No Monthly Data Available"),
                          buildChartSection(yearlyData, yearlyLabels, "No Yearly Data Available"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChartSection(List<BarChartGroupData> data, List<String> labels, String emptyMessage) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: data.isNotEmpty
          ? BarChart(buildBarChartData(data, labels))
          : Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _ChartData {
  final List<BarChartGroupData> data;
  final List<String> labels;

  _ChartData(this.data, this.labels);
}