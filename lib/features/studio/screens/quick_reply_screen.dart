import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/quick_reply_list.dart';
import '../widgets/quick_reply_dialog.dart';

class QuickReplyScreen extends ConsumerWidget {
  const QuickReplyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Replies')),
      body: QuickReplyList(
        onTemplateSelected: (content) {
          Navigator.of(context).pop(content);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const QuickReplyDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
