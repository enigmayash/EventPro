
class Ticket {
  final String id;              // Unique identifier for the ticket
  final String eventId;         // Event ID this ticket is linked to
  final String userId;          // User ID who purchased the ticket
  final DateTime purchaseDate;  // Date and time of purchase
  final double price;           // Price of the ticket

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.purchaseDate,
    required this.price,
  });

  // Convert a Ticket object to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'price': price,
    };
  }

  // Create a Ticket object from a map (e.g., from Firebase)
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      purchaseDate: DateTime.parse(map['purchaseDate'] ?? DateTime.now().toIso8601String()),
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}
