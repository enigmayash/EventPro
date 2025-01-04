import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:event_pro/core/model/event.dart';
import 'package:event_pro/features/event/screens/event_detail_screen.dart';
import 'package:event_pro/features/event/widgets/event_card.dart';

class FeaturedEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data?.docs ?? [];
        if (events.isEmpty) {
          return Center(child: Text('No upcoming events'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = Event.fromFirestore(
                events[index]); // Use fromFirestore to create Event object
            return EventCard(
              key: ValueKey(event.id),
              title: event.title,
              date: DateFormat('MMMM dd, yyyy')
                  .format(event.date), // Format date for display
              bannerUrl: event.bannerUrl,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(eventId: events[index].id,)
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
