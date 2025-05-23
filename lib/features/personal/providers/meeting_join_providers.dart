import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meeting_join_service.dart';

final meetingJoinServiceProvider = Provider((ref) => MeetingJoinService());
