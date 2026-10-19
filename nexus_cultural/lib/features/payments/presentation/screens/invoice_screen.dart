import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';

class InvoiceScreen extends ConsumerWidget {
  static const routeName = '/invoice';

  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeOrderProvider);

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Comprobante Oficial',
        subtitle: 'Factura Electrónica DIAN',
        voiceExplanation:
            'Comprobante oficial de pago de Nexus Cultural. Desglose detallado del valor pagado y los aportes destinados directamente a los artesanos colombianos sin deducciones abusivas.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner DIAN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: NexusColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.receipt, size: 20, color: NexusColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '[COMPROBANTE OFICIAL DIAN] Factura electrónica con desglose ético de aporte a maestros artesanos.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: NexusColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Official Invoice Document Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nexus Cultural S.A.S.',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                            ),
                            Text('NIT 901.842.119-4', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                            Text('Régimen Común DIAN', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NexusColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code_2, size: 48, color: NexusColors.primary),
                        ),
                      ],
                    ),

                    const Divider(height: 28),
                    Text(
                      'Factura Electrónica N°: ${order.orderNumber}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.primary),
                    ),
                    Text('Fecha de expedición: ${order.orderDate}'),
                    Text('Adquiriente: ${order.shippingAddress.fullName}'),
                    Text('Destino: ${order.shippingAddress.address}, ${order.shippingAddress.city}'),

                    const Divider(height: 28),
                    const Text(
                      'Detalle de Obras Adquiridas:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '\$${item.subtotal.toInt()} COP',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),

                    const Divider(height: 28),
                    // Transparent breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pago Neto Directo al Artesano (90%):', style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.greenDark)),
                        Text('\$${order.artisanDirectPayout.toInt()} COP', style: const TextStyle(fontWeight: FontWeight.bold, color: NexusColors.greenDark)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fondo de Preservación de Talleres (5%):', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                        Text('\$14.500 COP', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Logística y Embalaje Seguro (5%):', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                        Text('\$14.500 COP', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Flete de Transporte Nacional:', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                        Text('\$15.000 COP', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Cancelado:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text('\$${order.totalAmount.toInt()} COP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexusColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comprobante enviado a tu correo electrónico y guardado en PDF.'),
                      backgroundColor: NexusColors.greenProtection,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.download, size: 22),
                label: const Text('Descargar Comprobante PDF', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
