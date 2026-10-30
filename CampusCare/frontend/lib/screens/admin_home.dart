import 'package:flutter/material.dart';
import '../api.dart';
import '../main.dart';
import 'login_screen.dart';
import 'report_card.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<List<dynamic>> _reports = Api.reports();
  late Future<Map<String, dynamic>> _stats = Api.stats();
  String _filter = 'all';

  void _refresh() => setState(() {
        _reports = Api.reports();
        _stats = Api.stats();
      });

  Future<void> _logout() async {
    await Session.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  /// Bottom sheet where the admin picks a new status and writes a note.
  void _edit(Map<String, dynamic> report) {
    String status = report['status'];
    final note = TextEditingController(text: report['admin_note']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(report['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(report['description']),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'in_progress', label: Text('In progress')),
                ButtonSegment(value: 'resolved', label: Text('Resolved')),
              ],
              selected: {status},
              onSelectionChanged: (s) => setSheet(() => status = s.first),
            ),
            TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Note to student')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await Api.updateReport(report['id'], status, note.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                _refresh();
              },
              child: const Text('Save'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statBox(String label, dynamic value, Color color) => Expanded(
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Text('$value',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _stats,
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox(height: 70);
            final s = snap.data!;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                _statBox('Total', s['total'], navy),
                _statBox('Pending', s['pending'], orange),
                _statBox('In progress', s['in_progress'], blue),
                _statBox('Resolved', s['resolved'], green),
              ]),
            );
          },
        ),
        Wrap(spacing: 8, children: [
          for (final f in ['all', 'pending', 'in_progress', 'resolved'])
            ChoiceChip(
              label: Text(f == 'all' ? 'All' : statusLabel(f)),
              selected: _filter == f,
              onSelected: (_) => setState(() => _filter = f),
            ),
        ]),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _reports,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return Center(child: Text('${snap.error}'));
              final list = snap.data!
                  .where((r) => _filter == 'all' || r['status'] == _filter)
                  .toList();
              if (list.isEmpty) return const Center(child: Text('Nothing here.'));
              return ListView(children: [
                for (final r in list)
                  ReportCard(report: r, showReporter: true, onTap: () => _edit(r)),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}
