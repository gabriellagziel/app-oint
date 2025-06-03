enum ChatStepType { prompt, input, options, dateTime, confirm }

class MeetingChatStep {
  final String id; // e.g. "step_what_to_do"
  final ChatStepType type;
  final String promptKey; // e.g. "chat.what_do_you_want"
  final List<String>? options; // translation keys
  final bool optional;
  final String?
  visibleIfStepEquals; // e.g. "step_what_to_do=chat.option_reminder"

  const MeetingChatStep({
    required this.id,
    required this.type,
    required this.promptKey,
    this.options,
    this.optional = false,
    this.visibleIfStepEquals,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingChatStep &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          promptKey == other.promptKey &&
          options == other.options &&
          optional == other.optional &&
          visibleIfStepEquals == other.visibleIfStepEquals;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      promptKey.hashCode ^
      options.hashCode ^
      optional.hashCode ^
      visibleIfStepEquals.hashCode;
}
