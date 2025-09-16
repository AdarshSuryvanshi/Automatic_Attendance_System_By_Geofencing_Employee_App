// employee_stats_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class EmployeeStatsPage extends StatefulWidget {
  final String phone;
  final FirebaseDatabase rtdb;

  const EmployeeStatsPage({super.key, required this.phone, required this.rtdb});

  @override
  State<EmployeeStatsPage> createState() => _EmployeeStatsPageState();
}

class _EmployeeStatsPageState extends State<EmployeeStatsPage> {
  bool loading = true;
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      loading = true;
      records.clear();
    });

    final snapshot = await widget.rtdb.ref("attendance").get();

    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      data.forEach((date, employees) {
        if (employees is Map && employees.containsKey(widget.phone)) {
          final record = employees[widget.phone];
          records.add({
            "date": date,
            "check_in": record["check_in"],
            "check_out": record["check_out"],
            "hours": record["total_hours"],
            "status": record["status"],
          });
        }
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Stats (${widget.phone})")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? const Center(child: Text("No attendance records found"))
          : ListView.builder(
        itemCount: records.length,
        itemBuilder: (ctx, i) {
          final rec = records[i];
          return Card(
            child: ListTile(
              title: Text("Date: ${rec['date']}"),
              subtitle: Text(
                "In: ${rec['check_in'] ?? '-'}\n"
                    "Out: ${rec['check_out'] ?? '-'}\n"
                    "Hours: ${rec['hours']?.toStringAsFixed(2) ?? '-'}\n"
                    "Status: ${rec['status']}",
              ),
            ),
          );
        },
      ),
    );
  }
}
