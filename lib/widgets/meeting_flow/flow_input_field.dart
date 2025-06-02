import 'package:flutter/material.dart';

class FlowInputField extends StatefulWidget {
  final String hintText;
  final String? Function(String)? validator;
  final void Function(String) onSubmit;
  final TextInputType keyboardType;
  final bool autofocus;
  final Widget? suffix;

  const FlowInputField({
    super.key,
    required this.hintText,
    this.validator,
    required this.onSubmit,
    this.keyboardType = TextInputType.text,
    this.autofocus = true,
    this.suffix,
  });

  @override
  State<FlowInputField> createState() => _FlowInputFieldState();
}

class _FlowInputFieldState extends State<FlowInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.validator != null) {
      final error = widget.validator!(text);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }
    }

    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: widget.suffix,
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
