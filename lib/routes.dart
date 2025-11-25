import 'package:flutter/material.dart';
import 'models/appointment.dart';

// --- SCREENS ---
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/appointment_form_screen.dart';
import 'screens/appointment_detail_screen.dart';
import 'screens/calendar_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const form = '/form';
  static const detail = '/detail';
  static const calendar = '/calendar';
  static const profile = '/profile';  // ⭐ IMPORTANTE

  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());

      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      case form:
        final Appointment? ap = settings.arguments as Appointment?;
        return MaterialPageRoute(
          builder: (_) => AppointmentFormScreen(appointment: ap),
        );

      case detail:
        final Appointment ap = settings.arguments as Appointment;
        return MaterialPageRoute(
          builder: (_) => AppointmentDetailScreen(appointment: ap),
        );

      case calendar:
        final List<Appointment> citas =
            settings.arguments as List<Appointment>;
        return MaterialPageRoute(
          builder: (_) => CalendarScreen(citas: citas),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Ruta no encontrada: ${settings.name}"),
            ),
          ),
        );
    }
  }
}
