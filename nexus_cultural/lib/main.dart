import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import 'core/theme/nexus_theme.dart';
import 'core/routes/app_router.dart';
import 'features/authentication/controllers/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: p.MultiProvider(
        providers: [
          p.ChangeNotifierProvider(create: (_) => AuthController()),
        ],
        child: MaterialApp.router(
          title: 'Nexus Cultural',
          debugShowCheckedModeBanner: false,
          theme: NexusTheme.lightTheme,
          routerConfig: appRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'CO'),
          ],
        ),
      ),
    );
  }
}
