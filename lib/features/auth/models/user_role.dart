/// Enum representing the different user roles in the application.
enum UserRole {
  /// Personal user with basic features
  personal,

  /// Studio/Business user with advanced features
  studio,

  /// Admin user with full system access
  admin;

  /// Returns a human-readable string representation of the role
  String get displayName {
    switch (this) {
      case UserRole.personal:
        return 'Personal';
      case UserRole.studio:
        return 'Studio';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Returns the role's permission level (higher number = more permissions)
  int get permissionLevel {
    switch (this) {
      case UserRole.personal:
        return 1;
      case UserRole.studio:
        return 2;
      case UserRole.admin:
        return 3;
    }
  }

  /// Creates a UserRole from a string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.personal,
    );
  }
}
