import 'package:flutter/material.dart';
import '../api.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});
  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String _category = 'facilities';
  bool _busy = false;

  static const categories = ['facilities', 'safety', 'cleanliness', 'academic', 'other'];

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await Api.createReport({
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'location': _location.text.trim(),
        'category': _category,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''))));
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'What is the problem?')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            for (final c in categories) DropdownMenuItem(value: c, child: Text(c))
          ],
          onChanged: (v) => setState(() => _category = v!),
        ),
        const SizedBox(height: 12),
        TextField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Where? (e.g. Room 301)')),
        const SizedBox(height: 12),
        TextField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Describe it', alignLabelWithHint: true)),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: _busy ? null : _submit, child: const Text('Submit report')),
      ]),
    );
  }
}
