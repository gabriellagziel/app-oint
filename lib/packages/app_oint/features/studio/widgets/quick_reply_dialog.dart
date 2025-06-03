import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quick_reply_providers.dart';
import '../models/quick_reply_template.dart';

class QuickReplyDialog extends ConsumerStatefulWidget {
  final QuickReplyTemplate? template;

  const QuickReplyDialog({super.key, this.template});

  @override
  ConsumerState<QuickReplyDialog> createState() => _QuickReplyDialogState();
}

class _QuickReplyDialogState extends ConsumerState<QuickReplyDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template?.title);
    _contentController = TextEditingController(text: widget.template?.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Template' : 'New Template'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter template title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter template content',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final service = ref.read(quickReplyServiceProvider);

    try {
      if (widget.template != null) {
        final updatedTemplate = widget.template!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        );
        await service.updateTemplate(updatedTemplate);
      } else {
        await service.createTemplate(
          title: _titleController.text,
          content: _contentController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
