import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/order_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class ShippingScreen extends ConsumerStatefulWidget {
  static const routeName = '/shipping';

  const ShippingScreen({super.key});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'María Camila Rosero');
  final _phoneController = TextEditingController(text: '+57 312 456 7890');
  final _cityController = TextEditingController(text: 'Bogotá D.C.');
  final _addressController = TextEditingController(text: 'Carrera 7 # 115 - 45, Torre B, Apto 402');
  final _notesController = TextEditingController(text: 'Por favor dejar en recepción 24 horas. Producto frágil.');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(shippingFormProvider.notifier).state = ShippingAddressModel(
        fullName: _nameController.text,
        phone: _phoneController.text,
        department: 'Cundinamarca',
        city: _cityController.text,
        address: _addressController.text,
        deliveryNotes: _notesController.text,
      );
      context.push('/checkout-summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Datos de Entrega',
        subtitle: 'Paso 1 de 3 en Pago',
        voiceExplanation:
            'Indica tu dirección en Colombia para la transportadora artesanal protegida. El paquete irá debidamente embalado con protección contra golpes y sello de origen.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const VoiceAssistCard(
                  title: 'Asistencia de dirección',
                  subtitle: 'Entrega asegurada en toda Colombia',
                  textToRead:
                      'Escribe con claridad tu nombre, número de celular, ciudad y dirección con número de apartamento si aplica.',
                ),

                const SizedBox(height: 18),
                const Text(
                  'Nombre completo de quien recibe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: NexusColors.primary),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el nombre de quien recibe.' : null,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Teléfono de contacto para la entrega',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone, color: NexusColors.primary),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa un celular de contacto.' : null,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Ciudad o Municipio',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cityController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city, color: NexusColors.primary),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la ciudad.' : null,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Dirección exacta (Calle, Carrera, Apto, Casa)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.home, color: NexusColors.primary),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu dirección completa.' : null,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Indicaciones para la entrega (Opcional)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Ej: Dejar en portería, casa con portón verde...',
                  ),
                ),

                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.primary,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 24),
                  label: const Text(
                    'Continuar al Resumen de Compra',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
