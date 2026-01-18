class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' or 'worker'

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  // Factory constructor to create a User from Firestore data (Map)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Unknown',
      role: data['role'] ?? 'worker',
    );
  }

  // Method to convert User object back to Map (for uploading to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
}