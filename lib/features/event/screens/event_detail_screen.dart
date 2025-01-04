// lib/features/event/screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_pro/core/model/event.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  Future<Event> _fetchEventData() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final data = eventDoc.data()!;
      return Event.fromMap({
        'id': eventDoc.id,
        'title': data['title'],
        'description': data['description'],
        'date': data['date'],
        'location': data['location'],
        'bannerUrl': data['bannerUrl'],
        'price': data['price'],
        'additionalFields': data['additionalFields'],
      });
    } catch (e) {
      print('Error fetching event data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: _fetchEventData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final event = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(event.title)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(event.bannerUrl),
                SizedBox(height: 8),
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 8),
                Text('Date: ${event.date}', style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 8),
                Text('Location: ${event.location}', style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 16),
                Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
