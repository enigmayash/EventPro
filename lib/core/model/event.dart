
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final DateTime date;
  final String location;
  final String type;
  final double price;
  final int capacity;
  final List<String> attendees;
  final String bannerUrl;
  final bool isPublic;
  final List<Map<String, String>> additionalFields;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.date,
    required this.location,
    required this.type,
    required this.price,
    required this.capacity,
    required this.attendees,
    required this.bannerUrl,
    required this.isPublic,
    this.additionalFields = const [],
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 0,
      attendees: List<String>.from(data['attendees'] ?? []),
      bannerUrl: data['bannerUrl'] ?? '',
      isPublic: data['isPublic'] ?? true,
      additionalFields: List<Map<String, String>>.from(data['additionalFields'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'date': Timestamp.fromDate(date),
      'location': location,
      'type': type,
      'price': price,
      'capacity': capacity,
      'attendees': attendees,
      'bannerUrl': bannerUrl,
      'isPublic': isPublic,
      'additionalFields': additionalFields,
    };
  }
}