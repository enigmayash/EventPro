import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String bannerUrl;
  final double price;  // Add price field
  final List<Map<String, String>> additionalFields;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.bannerUrl,
    required this.price,  // Include price in the constructor
    required this.additionalFields,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id, // Use Firestore document ID
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      location: data['location'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      price: data['price']?.toDouble() ?? 0.0, // Ensure it's a double
      additionalFields: List<Map<String, String>>.from(data['additionalFields'] ?? []),
    );
  }

  // Method to convert Event to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'location': location,
      'bannerUrl': bannerUrl,
      'price': price,
      'additionalFields': additionalFields,
    };
  }
  
  // You can also add a factory constructor to map the data from Firestore or API
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,  // Ensure it's a double
      additionalFields: List<Map<String, String>>.from(map['additionalFields'] ?? []),
    );
  }
}
