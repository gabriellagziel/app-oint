import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/booking_link_service.dart';

final bookingLinkServiceProvider = Provider<BookingLinkService>((ref) {
  return BookingLinkService();
});
