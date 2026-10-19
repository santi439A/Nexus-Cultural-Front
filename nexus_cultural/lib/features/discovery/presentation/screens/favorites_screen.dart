import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';

class FavoritesScreen extends ConsumerWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Mis Favoritos',
        subtitle: 'Piezas Artesanales en Seguimiento',
        voiceExplanation:
            'Tu colección de piezas favoritas guardadas. Puedes revisar las historias de los artesanos o agregarlas a tu carrito de compras.',
      ),
      body: SafeArea(
        child: favorites.isEmpty
            ? const Center(
                child: Text(
                  'No tienes piezas guardadas en favoritos.',
                  style: TextStyle(fontSize: 18, color: NexusColors.textSecondary),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(18.0),
                children: [

                  ...favorites.map((prod) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                          border: Border.all(color: NexusColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                prod.images[0],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('Por ${prod.artisan.name}', style: const TextStyle(color: NexusColors.textSecondary)),
                                  Text('\$${prod.price.toInt()} COP', style: const TextStyle(fontWeight: FontWeight.bold, color: NexusColors.primary)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).addItem(prod);
                                context.push('/cart');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NexusColors.primary,
                                minimumSize: const Size(60, 48),
                              ),
                              child: const Icon(Icons.add_shopping_cart, size: 20),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
