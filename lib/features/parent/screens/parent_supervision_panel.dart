import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentSupervisionPanel extends StatefulWidget {
  final String childId;
  const ParentSupervisionPanel({super.key, required this.childId});

  @override
  State<ParentSupervisionPanel> createState() => _ParentSupervisionPanelState();
}

class _ParentSupervisionPanelState extends State<ParentSupervisionPanel> {
  int _maxPerDay = 3;
  int _maxPerWeek = 10;
  bool _manualApproval = false;
  String _notes = '';
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.childId)
              .get();

      if (doc.exists) {
        setState(() {
          _maxPerDay = doc['limits.maxPerDay'] ?? 3;
          _maxPerWeek = doc['limits.maxPerWeek'] ?? 10;
          _manualApproval = doc['limits.manualApproval'] ?? false;
          _notes = doc['parentNotes'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.childId)
          .update({
            'limits.maxPerDay': _maxPerDay,
            'limits.maxPerWeek': _maxPerWeek,
            'limits.manualApproval': _manualApproval,
            'parentNotes': _notes,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Supervision Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Meeting Limits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '$_maxPerDay',
              decoration: const InputDecoration(
                labelText: 'Max meetings per day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                if (num == null || num < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (val) => _maxPerDay = int.tryParse(val) ?? 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '$_maxPerWeek',
              decoration: const InputDecoration(
                labelText: 'Max meetings per week',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                if (num == null || num < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (val) => _maxPerWeek = int.tryParse(val) ?? 10,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Require manual approval'),
              subtitle: const Text('Approve each meeting request'),
              value: _manualApproval,
              onChanged: (val) => setState(() => _manualApproval = val),
            ),
            const SizedBox(height: 24),
            Text('Parent Notes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _notes,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional notes or restrictions',
                border: OutlineInputBorder(),
                hintText:
                    'Add any specific rules or notes about this child\'s account',
              ),
              onChanged: (val) => _notes = val,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
