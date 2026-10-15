import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'features/authentication/controllers/auth_controller.dart';
import 'features/authentication/screens/home_dashboard_screen.dart';
import 'features/authentication/screens/main_nexus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp(
            title: 'Nexus Cultural',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: authController.isAuthenticated
                ? AppRoutes.home
                : AppRoutes.initial,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
