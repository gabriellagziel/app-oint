import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/utils/localizations_helper.dart';

/// Widget for selecting meeting type
class MeetingStepType extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MeetingStepType({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<MeetingStepType> createState() => _MeetingStepTypeState();
}

class _MeetingStepTypeState extends ConsumerState<MeetingStepType> {
  String? _selectedType;

  final List<Map<String, dynamic>> _meetingTypes = [
    {
      'id': 'one_on_one',
      'icon': Icons.person,
      'titleKey': 'meeting_type_one_on_one',
      'descriptionKey': 'meeting_type_one_on_one_desc',
    },
    {
      'id': 'group',
      'icon': Icons.group,
      'titleKey': 'meeting_type_group',
      'descriptionKey': 'meeting_type_group_desc',
    },
    {
      'id': 'interview',
      'icon': Icons.work,
      'titleKey': 'meeting_type_interview',
      'descriptionKey': 'meeting_type_interview_desc',
    },
    {
      'id': 'presentation',
      'icon': Icons.slideshow,
      'titleKey': 'meeting_type_presentation',
      'descriptionKey': 'meeting_type_presentation_desc',
    },
  ];

  void _submitType() {
    if (_selectedType != null) {
      ref
          .read(meetingCreationProvider.notifier)
          .updateMeetingType(_selectedType!);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationsHelper.getString(context, 'meeting_type_title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ..._meetingTypes.map((type) {
          final isSelected = _selectedType == type['id'];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = type['id'] as String;
                });
                _submitType();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationsHelper.getString(
                                context, type['titleKey'] as String),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            LocalizationsHelper.getString(
                                context, type['descriptionKey'] as String),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
