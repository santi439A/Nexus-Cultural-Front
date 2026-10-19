import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class CartScreen extends ConsumerWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final subtotal = cartNotifier.subtotal;
    final shipping = cartNotifier.shippingCost;
    final total = cartNotifier.total;
    final artisanDirectPayout = cartNotifier.artisanDirectPayout;

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Mi Carrito',
        subtitle: 'Compras Protegidas y Comercio Justo',
        voiceExplanation:
            'Tu carrito de compras de Nexus Cultural. Tienes las piezas seleccionadas con entrega protegida. Puedes cambiar la cantidad, escribir un mensaje de cariño para el artesano y continuar a los datos de entrega.',
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: NexusColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a Pagar:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                  ),
                  Text(
                    '\$${total.toInt()} COP',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NexusColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        context.push('/shipping');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.local_shipping, size: 24),
                label: const Text(
                  'Continuar a Datos de Entrega',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 80, color: NexusColors.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu carrito está vacío',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Descubre piezas artesanales únicas creadas por maestros colombianos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: NexusColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Explorar Obras'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(18.0),
                children: [
                  // Banner M14

                  const VoiceAssistCard(
                    title: 'Resumen de tu compra',
                    subtitle: 'Escuchar el total de tu pedido',
                    textToRead:
                        'En tu carrito tienes piezas artesanales seleccionadas. El noventa por ciento del valor de las obras va directamente al maestro artesano en su taller familiar.',
                  ),

                  const SizedBox(height: 16),
                  // Cart Items List
                  ...cartItems.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                          border: Border.all(color: NexusColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.images[0],
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 76,
                                      height: 76,
                                      color: NexusColors.surfaceContainer,
                                      child: const Icon(Icons.image, color: NexusColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: NexusColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Por ${item.product.artisan.name}',
                                        style: const TextStyle(fontSize: 14, color: NexusColors.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.product.price.toInt()} COP',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: NexusColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Quantity Stepper (min 56px touch target)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: NexusColors.primary, size: 28),
                                      onPressed: () {
                                        cartNotifier.updateQuantity(item.product.id, item.quantity - 1);
                                      },
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: NexusColors.primary, size: 28),
                                      onPressed: () {
                                        cartNotifier.updateQuantity(item.product.id, item.quantity + 1);
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: NexusColors.error, size: 26),
                                  tooltip: 'Eliminar esta obra del carrito',
                                  onPressed: () {
                                    cartNotifier.removeItem(item.product.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 16),
                  // Dedication Message to Artisan Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NexusColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                      border: Border.all(color: NexusColors.borderLight),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: NexusColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Mensaje de Agradecimiento al Artesano',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tu dedicatoria se imprimirá en papel ecológico dentro del empaque artesanal.',
                          style: TextStyle(fontSize: 14, color: NexusColors.textSecondary),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje de cariño o aprecio para los maestros...',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                      border: Border.all(color: NexusColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal piezas:', style: TextStyle(fontSize: 16, color: NexusColors.textSecondary)),
                            Text('\$${subtotal.toInt()} COP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Envío asegurado a domicilio:', style: TextStyle(fontSize: 16, color: NexusColors.textSecondary)),
                            Text('\$${shipping.toInt()} COP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Aporte directo a talleres (90%):',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                            ),
                            Text(
                              '\$${artisanDirectPayout.toInt()} COP',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
