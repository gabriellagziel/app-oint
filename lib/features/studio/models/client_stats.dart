import 'package:cloud_firestore/cloud_firestore.dart';

class ClientStats {
  final String clientId;
  final int totalBookings;
  final DateTime? lastSeen;
  final List<String> tags;
  final String? email;
  final String? phone;

  ClientStats({
    required this.clientId,
    required this.totalBookings,
    this.lastSeen,
    required this.tags,
    this.email,
    this.phone,
  });

  factory ClientStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientStats(
      clientId: doc.id,
      totalBookings: data['totalBookings'] as int? ?? 0,
      lastSeen:
          data['lastSeen'] != null
              ? (data['lastSeen'] as Timestamp).toDate()
              : null,
      tags: List<String>.from(data['tags'] ?? []),
      email: data['email'] as String?,
      phone: data['phone'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalBookings': totalBookings,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'tags': tags,
      'email': email,
      'phone': phone,
    };
  }

  ClientStats copyWith({
    String? clientId,
    int? totalBookings,
    DateTime? lastSeen,
    List<String>? tags,
    String? email,
    String? phone,
  }) {
    return ClientStats(
      clientId: clientId ?? this.clientId,
      totalBookings: totalBookings ?? this.totalBookings,
      lastSeen: lastSeen ?? this.lastSeen,
      tags: tags ?? this.tags,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
