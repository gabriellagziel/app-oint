import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

/// Model class representing a user in the application.
class AppUser {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String displayName;

  /// User's profile photo URL
  final String? photoUrl;

  /// User's role in the application
  final UserRole role;

  /// Timestamp when the user was created
  final DateTime createdAt;

  /// Timestamp when the user was last updated
  final DateTime updatedAt;

  /// Whether the user's email is verified
  final bool isEmailVerified;

  /// Whether the user is active
  final bool isActive;

  /// Creates a new instance of [AppUser]
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isActive = true,
  });

  /// Creates an [AppUser] from a Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.fromString(data['role'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Converts the [AppUser] to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
    };
  }

  /// Creates a copy of this [AppUser] with the given fields replaced
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          role == other.role &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isEmailVerified == other.isEmailVerified &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      role.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isEmailVerified.hashCode ^
      isActive.hashCode;
}
