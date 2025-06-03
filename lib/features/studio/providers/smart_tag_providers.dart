import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/smart_tag_service.dart';

final smartTagServiceProvider = Provider((ref) => SmartTagService());
