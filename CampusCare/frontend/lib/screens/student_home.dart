import 'package:flutter/material.dart';
import '../api.dart';
import 'login_screen.dart';
import 'new_report_screen.dart';
import 'report_card.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  late Future<List<dynamic>> _reports = Api.reports();

  void _refresh() => setState(() => _reports = Api.reports());

  Future<void> _logout() async {
    await Session.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${Session.name}'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New report'),
        onPressed: () async {
          final created = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => const NewReportScreen()));
          if (created == true) _refresh();
        },
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reports,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load: ${snap.error}'));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('No reports yet. Tap "New report".'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [for (final r in list) ReportCard(report: r)],
            ),
          );
        },
      ),
    );
  }
}
