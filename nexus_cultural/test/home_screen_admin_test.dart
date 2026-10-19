import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexus_cultural/features/authentication/controllers/auth_controller.dart';
import 'package:nexus_cultural/features/discovery/presentation/screens/home_screen_admin.dart';
import 'package:nexus_cultural/shared/widgets/nexus_admin_bottom_nav.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('NexusAdminBottomNav renders 5 nav items without plus FAB', (WidgetTester tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NexusAdminBottomNav(
            currentIndex: selectedIndex,
            onTabSelected: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Moderación'), findsOneWidget);
    expect(find.text('Soporte'), findsOneWidget);
    expect(find.text('Gestor'), findsOneWidget);
    expect(find.text('Equipo'), findsOneWidget);
    // Verifies no "+" button (which artisan has)
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('HomeScreenAdmin renders dashboard and handles role permissions', (WidgetTester tester) async {
    final authController = AuthController();

    await tester.pumpWidget(
      ProviderScope(
        child: p.ChangeNotifierProvider<AuthController>.value(
          value: authController,
          child: const MaterialApp(
            home: HomeScreenAdmin(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifies header elements
    expect(find.textContaining('Consola Administrativa'), findsOneWidget);
    expect(find.text('Métricas del Ecosistema'), findsOneWidget);
    expect(find.text('SUPER_ADMIN'), findsWidgets);

    // Switch to Moderación tab
    await tester.tap(find.text('Moderación'));
    await tester.pumpAndSettle();
    expect(find.text('Bandeja de Moderación'), findsOneWidget);

    // Switch to Soporte tab
    await tester.tap(find.text('Soporte'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Doña María Pushaina'), findsWidgets);

    // Switch to Gestor tab
    await tester.tap(find.text('Gestor'));
    await tester.pumpAndSettle();
    expect(find.text('Curaduría y Patrimonio Cultural'), findsOneWidget);

    // Switch to Equipo tab (Administradores)
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
    expect(find.text('Gestión de Administradores'), findsOneWidget);
    expect(find.text('Añadir Nuevo Administrador'), findsOneWidget);
    expect(find.text('Añadir Administrador'), findsOneWidget);

    // Scroll to check registered administrators list
    await tester.scrollUntilVisible(
      find.text('Administradores Registrados'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Administradores Registrados'), findsOneWidget);
    expect(find.text('Carlos Manuel Mendoza'), findsOneWidget);
  });
}
