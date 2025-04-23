import 'package:flutter/material.dart';
import '../views/admin/dashboard/widgets/manage_carousel_items/manage_carousel_items.dart';
import '../views/admin/dashboard/widgets/manage_movies/manage_movies.dart';
import '../views/admin/dashboard/widgets/manage_schedule/add_schedule.dart';
import '../views/admin/dashboard/widgets/manage_schedule/edit_schedule.dart';
import '../views/admin/dashboard/widgets/manage_schedule/manage_schedule.dart';
import '../views/admin/dashboard/widgets/manage_users/add_user.dart';
import '../views/admin/dashboard/widgets/manage_users/edit_user.dart';
import '../views/admin/dashboard/widgets/manage_users/manage_users.dart';

class AdminRoutes {
  // Main routes
  static const String auth = '/admin/auth';
  static const String dashboard = '/admin/dashboard';

  // Dashboard sections
  static const String carousel = '/admin/carousel';
  static const String editCarousel = '/admin/carousel/edit';

  static const String movies = '/admin/movies';
  static const String editMovie = '/admin/movies/edit';

  static const String schedule = '/admin/schedule';
  static const String addSchedule = '/admin/schedule/add';
  static const String editSchedule = '/admin/schedule/edit';

  static const String users = '/admin/users';
  static const String addUser = '/admin/users/add';
  static const String editUser = '/admin/users/edit';

  static const String offers = '/admin/offers';
  static const String promos = '/admin/promos';
  static const String payments = '/admin/payments';
}

// Route generator for admin routes
Route<dynamic>? generateAdminRoute(RouteSettings settings, ThemeData theme) {
  // Extract route name and arguments
  final Uri uri = Uri.parse(settings.name ?? '');
  final pathSegments = uri.pathSegments;
  final args = settings.arguments as Map<String, dynamic>? ?? {};

  // Only handle admin routes
  if (pathSegments.isEmpty || pathSegments[0] != 'admin') {
    return null;
  }

  // Handle different admin routes
  switch (settings.name) {
    // Carousel routes
    case AdminRoutes.carousel:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ManageCarouselItems(),
      );

    // Movie routes
    case AdminRoutes.movies:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ManageMovies(),
      );

    // Schedule routes
    case AdminRoutes.schedule:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ManageSchedule(),
      );
    case AdminRoutes.addSchedule:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AddSchedule(),
      );
    case AdminRoutes.editSchedule:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => EditSchedule(id: args['id'] ?? ''),
      );

    // User routes
    case AdminRoutes.users:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ManageUsers(),
      );
    case AdminRoutes.addUser:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AddUser(),
      );
    case AdminRoutes.editUser:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => EditUser(id: args['id'] ?? ''),
      );

    // Other management routes
    case AdminRoutes.offers:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Placeholder(),
      );
    case AdminRoutes.promos:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Placeholder(),
      );
    case AdminRoutes.payments:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Placeholder(),
      );

    default:
      return null;
  }
}
