
class User {
  final String id;              // Unique identifier for the user
  final String name;            // User's full name
  final String email;           // User's email address
  final String? profilePicture; // URL to the user's profile picture (optional)
  final String phoneNumber;     // User's phone number

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.phoneNumber,
  });

  // Convert a User object to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
    };
  }

  // Create a User object from a map (e.g., from Firebase)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
