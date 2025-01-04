
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_pro/features/event/screens/event_detail_screen.dart';
import '../widgets/event_card.dart';  
import 'package:firebase_auth/firebase_auth.dart';

class MyEventsScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchUserEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }
      
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('creatorId', isEqualTo: user.uid)
          .get();

      return eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'date': data['date'].toDate(),
          'location': data['location'],
          'bannerUrl': data['bannerUrl'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _fetchUserEvents(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(child: Text('No events created yet.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (ctx, index) {
              final event = events[index];
              return EventCard(
                title: event['title']!,
                date: '${event['date'].day}/${event['date'].month}/${event['date'].year}',
                bannerUrl: event['bannerUrl'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                        eventId: event['id']!,  // Pass eventId to EventDetailsScreen
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
