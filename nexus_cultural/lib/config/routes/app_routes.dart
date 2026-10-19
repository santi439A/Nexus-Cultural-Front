import 'package:flutter/material.dart';
import '../../features/authentication/screens/main_nexus.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/home_dashboard_screen.dart';

import '../../features/discovery/presentation/screens/home_screen_admin.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String homeAdmin = '/home-admin';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const MainNexusScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeDashboardScreen(),
        homeAdmin: (context) => const HomeScreenAdmin(),
      };
}

