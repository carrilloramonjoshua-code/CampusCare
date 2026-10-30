import 'package:flutter/material.dart';
import '../main.dart';

Color statusColor(String s) =>
    s == 'resolved' ? green : (s == 'in_progress' ? blue : orange);

String statusLabel(String s) =>
    s == 'resolved' ? 'Resolved' : (s == 'in_progress' ? 'In progress' : 'Pending');

/// One report shown as a card. Used by both student and admin screens.
class ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final bool showReporter;
  final VoidCallback? onTap;
  const ReportCard(
      {super.key, required this.report, this.showReporter = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = report['status'] as String;
    final note = report['admin_note'] as String;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(report['title'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${report['category']} • ${report['location']}'),
          if (showReporter) Text('By ${report['reporter_name']}'),
          Text(report['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
          if (note.isNotEmpty)
            Text('Admin: $note',
                style: const TextStyle(fontStyle: FontStyle.italic)),
        ]),
        trailing: Chip(
          label: Text(statusLabel(status),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: statusColor(status),
        ),
      ),
    );
  }
}
