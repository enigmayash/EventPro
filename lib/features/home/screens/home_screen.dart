import 'package:flutter/material.dart';
import '../widgets/featured_events.dart';
import 'package:event_pro/features/home/widgets/event_banner.dart';
import 'package:event_pro/features/event/screens/create_event_screen.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventPro'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrolling Banner (20% of screen height)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: EventBanner(),
            ),
            
            // Rest of the content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Implement refresh logic
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Featured Events',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      FeaturedEvents(),
                      
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Upcoming Events',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      UpcomingEvents(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event screen when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(isPublic: true,),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create New Event',
      ),
    );
  }
}
