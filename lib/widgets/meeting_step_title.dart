import 'package:flutter/material.dart';

class MeetingStepTitle extends StatelessWidget {
  final TextEditingController controller;

  const MeetingStepTitle({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Meeting Title',
        border: OutlineInputBorder(),
        hintText: 'Enter a title for your meeting',
      ),
    );
  }
}
