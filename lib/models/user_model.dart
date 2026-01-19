class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Convert User object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Create User object from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      // Use the document ID from Firestore if the field is missing inside data
      id: documentId, 
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'worker',
    );
  }
}