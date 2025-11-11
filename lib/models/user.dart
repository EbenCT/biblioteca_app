// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String email;
  final String role; // USER, ADMIN, LIBRARIAN, etc.

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  // Métodos de utilidad
  bool get isAdmin => role == 'ADMIN';
  bool get isLibrarian => role == 'LIBRARIAN';
  bool get isUser => role == 'USER';

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}