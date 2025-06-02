class MeetingFlowStep {
  final String message;
  final String? hint;
  final List<String>? options;
  final bool isDatePicker;
  final bool isTimePicker;
  final bool isContactPicker;
  final bool isOptional;
  final String? validationMessage;

  const MeetingFlowStep({
    required this.message,
    this.hint,
    this.options,
    this.isDatePicker = false,
    this.isTimePicker = false,
    this.isContactPicker = false,
    this.isOptional = false,
    this.validationMessage,
  });
}

class MeetingFlowSteps {
  static const List<MeetingFlowStep> steps = [
    MeetingFlowStep(
      message: 'What would you like to name your meeting?',
      hint: 'Enter meeting name',
      validationMessage: 'Please enter a meeting name (max 100 characters)',
    ),
    MeetingFlowStep(
      message: 'When would you like to schedule the meeting?',
      isDatePicker: true,
      validationMessage: 'Please select a future date',
    ),
    MeetingFlowStep(
      message: 'What time would you like to schedule the meeting?',
      isTimePicker: true,
      validationMessage: 'Please select a time',
    ),
    MeetingFlowStep(
      message: 'What type of meeting would you like to create?',
      options: ['Virtual', 'In Person', 'Phone'],
      validationMessage: 'Please select a meeting type',
    ),
    MeetingFlowStep(
      message: 'Who would you like to invite to the meeting?',
      hint: 'Search contacts',
      isContactPicker: true,
      validationMessage: 'Please add at least one participant (max 50)',
    ),
    MeetingFlowStep(
      message: 'Would you like to add a location or notes?',
      hint: 'Enter location or notes (optional)',
      isOptional: true,
      validationMessage: 'Location must be less than 200 characters',
    ),
  ];

  static String getSummaryMessage(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Here\'s a summary of your meeting:');
    buffer.writeln();
    buffer.writeln('Title: ${data['title']}');

    if (data['datetime'] != null) {
      final date = data['datetime'] as DateTime;
      buffer.writeln(
          'Date: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
      buffer.writeln(
          'Time: ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}');
    }

    buffer.writeln('Type: ${data['meetingType']}');

    if (data['participants'] != null) {
      final participants = data['participants'] as List<String>;
      buffer.writeln('Participants: ${participants.join(", ")}');
    }

    if (data['location'] != null && data['location'].toString().isNotEmpty) {
      buffer.writeln('Location: ${data['location']}');
    }

    if (data['notes'] != null && data['notes'].toString().isNotEmpty) {
      buffer.writeln('Notes: ${data['notes']}');
    }

    return buffer.toString();
  }

  static String? getValidationMessage(
      int stepIndex, Map<String, dynamic> data) {
    final step = steps[stepIndex];
    if (step.isOptional) return null;

    switch (stepIndex) {
      case 0:
        final title = data['title'] as String?;
        if (title == null || title.isEmpty) {
          return 'Please enter a meeting name';
        }
        if (title.length > 100) {
          return 'Title must be less than 100 characters';
        }
        break;
      case 1:
      case 2:
        final datetime = data['datetime'] as DateTime?;
        if (datetime == null) {
          return 'Please select a date and time';
        }
        if (datetime.isBefore(DateTime.now())) {
          return 'Meeting time must be in the future';
        }
        break;
      case 3:
        final type = data['meetingType'] as String?;
        if (type == null || type.isEmpty) {
          return 'Please select a meeting type';
        }
        break;
      case 4:
        final participants = data['participants'] as List<String>?;
        if (participants == null || participants.isEmpty) {
          return 'Please add at least one participant';
        }
        if (participants.length > 50) {
          return 'Maximum 50 participants allowed';
        }
        break;
      case 5:
        final location = data['location'] as String?;
        if (location != null && location.length > 200) {
          return 'Location must be less than 200 characters';
        }
        break;
    }
    return null;
  }
}
