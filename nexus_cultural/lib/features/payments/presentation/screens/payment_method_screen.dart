import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  static const routeName = '/payment-method';

  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  String _selectedMethod = 'card';
  bool _isProcessing = false;

  Future<void> _processPayment(double total) async {
    setState(() => _isProcessing = true);
    try {
      final cartItems = ref.read(cartProvider);
      try {
        if (cartItems.isNotEmpty) {
          final firstItem = cartItems.first;
          await ApiClient().post('/pedidos', queryParameters: {
            'compradorId': 'c3a8e9e2-51c0-4e5a-8b83-a74586940d91',
            'articuloId': 'd3a8e9e2-51c0-4e5a-8b83-a74586940d92',
            'cantidad': firstItem.quantity,
          });
        }
      } catch (_) {}

      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        context.go('/payment-success');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final total = cartNotifier.total;

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Medio de Pago Seguro',
        subtitle: 'Paso 3 de 3 en Pago',
        voiceExplanation:
            'Selecciona tu medio de pago colombiano preferido: Tarjeta de crédito o débito, transferencia por PSE, o billeteras digitales Nequi y Daviplata.',
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
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _processPayment(total),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.greenProtection,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
              ),
            ),
            icon: const Icon(Icons.lock, size: 24),
            label: Text(
              'Pagar \$${total.toInt()} COP con Seguridad',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner M17

              const VoiceAssistCard(
                title: 'Pagos protegidos por ley',
                subtitle: 'Superintendencia Financiera de Colombia',
                textToRead:
                    'Tu dinero permanece custodiado hasta que recibas y apruebes la pieza artesanal en tus manos.',
              ),

              const SizedBox(height: 16),
              // Option 1: Tarjeta Crédito / Débito
              _PaymentOptionTile(
                id: 'card',
                title: 'Tarjeta Débito o Crédito',
                subtitle: 'Visa, Mastercard, American Express',
                icon: Icons.credit_card,
                selectedId: _selectedMethod,
                onSelected: (id) => setState(() => _selectedMethod = id),
              ),

              const SizedBox(height: 12),
              // Option 2: PSE (Transferencia Bancaria Nacional)
              _PaymentOptionTile(
                id: 'pse',
                title: 'PSE (Transferencia Bancaria)',
                subtitle: 'Bancolombia, Davivienda, Banco de Bogotá, etc.',
                icon: Icons.account_balance,
                selectedId: _selectedMethod,
                onSelected: (id) => setState(() => _selectedMethod = id),
              ),

              const SizedBox(height: 12),
              // Option 3: Billeteras Nequi / Daviplata
              _PaymentOptionTile(
                id: 'wallet',
                title: 'Nequi o Daviplata',
                subtitle: 'Pago rápido desde tu celular sin números de tarjeta',
                icon: Icons.phone_android,
                selectedId: _selectedMethod,
                onSelected: (id) => setState(() => _selectedMethod = id),
              ),

              const SizedBox(height: 24),
              // Card Details Form if card is selected
              if (_selectedMethod == 'card')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    border: Border.all(color: NexusColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos de la Tarjeta',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '4000 1234 5678 9010',
                          labelText: 'Número de Tarjeta',
                          prefixIcon: Icon(Icons.credit_card, color: NexusColors.primary),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'MM/AA',
                                labelText: 'Vence',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: '123',
                                labelText: 'CVV',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _PaymentOptionTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = id == selectedId;
    return InkWell(
      onTap: () => onSelected(id),
      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? NexusColors.surfaceHighlight : Colors.white,
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(
            color: isSelected ? NexusColors.primary : NexusColors.border,
            width: isSelected ? 2.2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: isSelected ? NexusColors.primary : NexusColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? NexusColors.primary : NexusColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: selectedId,
              activeColor: NexusColors.primary,
              onChanged: (val) {
                if (val != null) onSelected(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
