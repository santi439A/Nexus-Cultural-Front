import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/app_state_providers.dart';
import 'artisan_registration_flow.dart';
import 'buyer_registration_flow.dart';

class RegistrationScreen extends ConsumerWidget {
  static const routeName = '/registration';

  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);

    if (role == UserRole.artisan) {
      return const ArtisanRegistrationFlow();
    } else {
      return const BuyerRegistrationFlow();
    }
  }
}
