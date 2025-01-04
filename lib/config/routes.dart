
import 'package:flutter/material.dart';
import 'package:event_pro/features/auth/screens/login_screen.dart';
import 'package:event_pro/features/auth/screens/signup_screen.dart';
import 'package:event_pro/features/home/screens/home_screen.dart';
import 'package:event_pro/features/event/screens/create_event_screen.dart';
import 'package:event_pro/features/event/screens/event_detail_screen.dart';
import 'package:event_pro/features/event/screens/my_event_screen.dart';
import 'package:event_pro/features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String createEvent = '/create-event';
  static const String eventDetails = '/event-details';
  static const String myEvents = '/my-events';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case createEvent:
        final args = settings.arguments as bool;
        return MaterialPageRoute(builder: (_) => CreateEventScreen(isPublic: args));
      case eventDetails:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => EventDetailsScreen(eventId: eventId));
      case myEvents:
        return MaterialPageRoute(builder: (_) => MyEventsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}
