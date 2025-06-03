import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quick_reply_providers.dart';
import '../models/quick_reply_template.dart';
import 'quick_reply_dialog.dart';

class QuickReplyList extends ConsumerWidget {
  final Function(String) onTemplateSelected;

  const QuickReplyList({super.key, required this.onTemplateSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(quickReplyTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text('No quick reply templates yet'));
        }

        return ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return _QuickReplyTile(
              template: template,
              onSelected: onTemplateSelected,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _QuickReplyTile extends ConsumerWidget {
  final QuickReplyTemplate template;
  final Function(String) onSelected;

  const _QuickReplyTile({required this.template, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(template.title),
      subtitle: Text(
        template.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAction(value, context, ref),
        itemBuilder:
            (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
      ),
      onTap: () => onSelected(template.content),
    );
  }

  Future<void> _handleAction(
    String action,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(quickReplyServiceProvider);

    switch (action) {
      case 'edit':
        await showDialog(
          context: context,
          builder: (context) => QuickReplyDialog(template: template),
        );
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Template'),
                content: const Text(
                  'Are you sure you want to delete this template?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );

        if (confirmed == true) {
          try {
            await service.deleteTemplate(template.id);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Template deleted')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        }
        break;
    }
  }
}
