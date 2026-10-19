import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class RefundRequestScreen extends ConsumerStatefulWidget {
  static const routeName = '/refund-request';

  const RefundRequestScreen({super.key});

  @override
  ConsumerState<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends ConsumerState<RefundRequestScreen> {
  String _selectedReason = 'dano';
  final _commentController = TextEditingController(text: 'El paquete llegó golpeado y un hilo de la gasa venía rozado.');
  bool _preferVoucher = false;

  final List<Map<String, String>> _reasons = [
    {'id': 'dano', 'label': 'Producto con daño en el transporte'},
    {'id': 'diferente', 'label': 'No coincide con la descripción o medidas'},
    {'id': 'demora', 'label': 'Llegó fuera del tiempo acordado'},
    {'id': 'otro', 'label': 'Otro motivo personal'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await ApiClient().post('/pedidos/devolucion', data: {
        'pedidoId': 'c3a8e9e2-51c0-4e5a-8b83-a74586940d91',
        'motivo': _selectedReason,
        'comentario': _commentController.text.trim(),
      });
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud DEV-2026-089 radicada exitosamente con recogida gratuita.'),
          backgroundColor: NexusColors.greenProtection,
          duration: Duration(seconds: 3),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Solicitud de Devolución',
        subtitle: 'Garantía Artesanal 100% Protegida',
        voiceExplanation:
            'Formulario de solicitud de devolución. Si tu pieza presentó algún inconveniente o daño en transporte, puedes solicitar la recogida gratuita a tu domicilio y reembolso total.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const VoiceAssistCard(
                title: 'Protección para ti y el artesano',
                subtitle: 'Fondo de seguro Nexus Cultural',
                textToRead:
                    'Las devoluciones por daño en transporte son cubiertas por el fondo de garantía solidario, protegiendo tanto tu compra como el pago del artesano.',
              ),

              const SizedBox(height: 18),
              const Text(
                'Motivo de la Solicitud:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 8),

              ..._reasons.map((r) {
                final isSelected = _selectedReason == r['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? NexusColors.surfaceHighlight : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? NexusColors.primary : NexusColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: r['id']!,
                    groupValue: _selectedReason,
                    activeColor: NexusColors.primary,
                    title: Text(r['label']!, style: const TextStyle(fontSize: 15)),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReason = val);
                    },
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Text(
                'Describe lo sucedido:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Explica con tus palabras o pulsa para adjuntar nota de voz...',
                ),
              ),

              const SizedBox(height: 16),
              // Voice note record simulation button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nota de voz adjuntada a tu solicitud.'),
                      backgroundColor: NexusColors.primary,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: NexusColors.primary, width: 2),
                ),
                icon: const Icon(Icons.mic, color: NexusColors.primary),
                label: const Text(
                  'Tocar para Grabar Nota de Voz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.primary),
                ),
              ),

              const SizedBox(height: 16),
              // Voucher bonus checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NexusColors.greenProtectionContainer,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.greenProtection.withOpacity(0.3)),
                ),
                child: CheckboxListTile(
                  value: _preferVoucher,
                  activeColor: NexusColors.greenDark,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Prefiero Bono Solidario Nexus con 10% adicional de valor para futuras compras.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                  ),
                  onChanged: (val) => setState(() => _preferVoucher = val ?? false),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.send, size: 22),
                label: const Text(
                  'Radicar Solicitud de Devolución',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
