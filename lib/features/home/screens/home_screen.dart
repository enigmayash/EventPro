import 'package:flutter/material.dart';
import '../widgets/featured_events.dart';
import 'package:event_pro/features/home/widgets/event_banner.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

