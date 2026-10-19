import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../models/artesano_request.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class ArtisanRegistrationFlow extends ConsumerStatefulWidget {
  static const routeName = '/register-artisan';

  const ArtisanRegistrationFlow({super.key});

  @override
  ConsumerState<ArtisanRegistrationFlow> createState() =>
      _ArtisanRegistrationFlowState();
}

class _ArtisanRegistrationFlowState
    extends ConsumerState<ArtisanRegistrationFlow> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isRegistering = false;

  // Paso 1
  final _step1Key = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _acceptTerms = false;

  // Paso 2
  final _step2Key = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _departmentController = TextEditingController();
  final _municipalityController = TextEditingController();

  // Paso 3
  final _step3Key = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _recognitionsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _departmentController.dispose();
    _municipalityController.dispose();
    _addressController.dispose();
    _recognitionsController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 1) {
      if (!(_step1Key.currentState?.validate() ?? false)) return;
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar los términos de Comercio Justo.'),
            backgroundColor: NexusColors.error,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (!(_step2Key.currentState?.validate() ?? false)) return;
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    if (!(_step3Key.currentState?.validate() ?? false)) return;

    setState(() => _isRegistering = true);
    final email = _emailController.text.trim();

    // Parsear reconocimientos separados por comas
    final reconocimientosList = _recognitionsController.text
        .trim()
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    final req = ArtesanoRequest(
      nombreCompleto: _nameController.text.trim(),
      email: email,
      anosExperiencia:
          int.tryParse(_experienceController.text.trim()) ?? 0,
      reconocimientos: reconocimientosList,
      departamento: _departmentController.text.trim(),
      municipio: _municipalityController.text.trim(),
      direccion: _addressController.text.trim(),
    );

    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      final registered = await authCtrl.registrarArtesano(req);

      if (registered) {
        await authCtrl.solicitarOtp(email);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.successMessage ??
                'Registro exitoso. Te enviamos el código OTP.'),
            backgroundColor: NexusColors.greenProtection,
          ),
        );
        context.push('/sms-otp', extra: email);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar. Intenta de nuevo.'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NexusAppBar(
        title: 'Registro Artesano',
        subtitle: 'Paso $_currentStep de $_totalSteps',
        voiceExplanation: _currentStep == 1
            ? 'Paso 1: Escribe tu nombre completo y tu correo electrónico.'
            : _currentStep == 2
                ? 'Paso 2: Indica tus años de experiencia y tu ubicación geográfica.'
                : 'Paso 3: Escribe tu dirección y tus reconocimientos artesanales.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de progreso
              _buildProgressBar(),
              const SizedBox(height: 18),

              // Contenido del paso actual
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),

              const SizedBox(height: 28),
              // Botones de navegación
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: List.generate(_totalSteps, (index) {
            final stepNum = index + 1;
            final isCompleted = stepNum < _currentStep;
            final isCurrent = stepNum == _currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 6 : 0),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? NexusColors.primary
                            : NexusColors.borderLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepNum == 1
                          ? 'Datos Básicos'
                          : stepNum == 2
                              ? 'Experiencia'
                              : 'Ubicación',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? NexusColors.primary
                            : NexusColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NexusColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_add, size: 20, color: NexusColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '[PASO 1 · DATOS BÁSICOS] Tu nombre y correo electrónico para crear tu cuenta.',
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
          const SizedBox(height: 12),
          const VoiceAssistCard(
            title: 'Registro seguro y sencillo',
            subtitle: 'Sin contraseñas difíciles',
            textToRead:
                'Escribe tu nombre completo como aparece en tu documento y un correo electrónico válido. Te enviaremos un código de verificación.',
          ),
          const SizedBox(height: 18),

          // Campo 1: Nombre Completo
          const Text(
            'Nombre Completo',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: María Rosa Candamil',
              prefixIcon: Icon(Icons.person, color: NexusColors.primary),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres.';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),
          // Campo 2: Email
          const Text(
            'Correo Electrónico',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: maria@correo.com',
              prefixIcon: Icon(Icons.email, color: NexusColors.primary),
              helperText: 'Te enviaremos un código de verificación.',
              helperStyle:
                  TextStyle(fontSize: 14, color: NexusColors.textSecondary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El correo electrónico es obligatorio.';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Ingresa un correo válido.';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          // Términos
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(NexusAccessibility.borderRadius),
              border: Border.all(color: NexusColors.border),
            ),
            child: CheckboxListTile(
              value: _acceptTerms,
              activeColor: NexusColors.primary,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Acepto los términos de Comercio Justo y Protección de Fondos de Nexus Cultural.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.textPrimary),
              ),
              onChanged: (val) {
                setState(() {
                  _acceptTerms = val ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NexusColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.front_hand, size: 20, color: NexusColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '[PASO 2 · EXPERIENCIA] Cuéntanos sobre tu trayectoria como artesano.',
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
          const SizedBox(height: 12),
          const VoiceAssistCard(
            title: 'Tu experiencia es valiosa',
            subtitle: 'Cuéntanos de tu oficio',
            textToRead:
                'Indica cuántos años llevas practicando tu oficio y en qué departamento y municipio se ubica tu taller.',
          ),
          const SizedBox(height: 18),

          // Campo 1: Años de experiencia
          const Text(
            'Años de Experiencia Artesanal',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: 25',
              prefixIcon: Icon(Icons.workspace_premium, color: NexusColors.primary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Indica tus años de experiencia.';
              }
              if (int.tryParse(val.trim()) == null) {
                return 'Ingresa un número válido.';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),
          // Campo 2: Departamento
          const Text(
            'Departamento',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _departmentController,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: La Guajira',
              prefixIcon: Icon(Icons.map, color: NexusColors.primary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El departamento es obligatorio.';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),
          // Campo 3: Municipio
          const Text(
            'Municipio',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _municipalityController,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: Uribia',
              prefixIcon: Icon(Icons.location_city, color: NexusColors.primary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El municipio es obligatorio.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NexusColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, size: 20, color: NexusColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '[PASO 3 · DIRECCIÓN Y LOGROS] Completa tu dirección y reconocimientos.',
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
          const SizedBox(height: 12),
          const VoiceAssistCard(
            title: 'Último paso',
            subtitle: 'Estás casi listo',
            textToRead:
                'Escribe tu dirección completa y los reconocimientos que hayas recibido separados por comas. Luego pulsa Registrarse.',
          ),
          const SizedBox(height: 18),

          // Campo 1: Dirección
          const Text(
            'Dirección del Taller',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            style: const TextStyle(fontSize: 18, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: Taller Ancestral Comunitario',
              prefixIcon: Icon(Icons.home, color: NexusColors.primary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'La dirección es obligatoria.';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),
          // Campo 2: Reconocimientos
          const Text(
            'Reconocimientos (separados por comas)',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _recognitionsController,
            maxLines: 2,
            style: const TextStyle(fontSize: 17, color: NexusColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: Maestro Artesano de Colombia, Premio Regional 2024',
              prefixIcon: Icon(Icons.emoji_events, color: NexusColors.primary),
              helperText: 'Puedes dejar vacío si no tienes reconocimientos.',
              helperStyle:
                  TextStyle(fontSize: 14, color: NexusColors.textSecondary),
            ),
          ),

          const SizedBox(height: 20),
          // Resumen de datos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NexusColors.surfaceHighlight,
              borderRadius:
                  BorderRadius.circular(NexusAccessibility.borderRadius),
              border: Border.all(color: NexusColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de tu registro:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NexusColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _summaryRow(Icons.person, 'Nombre', _nameController.text),
                _summaryRow(Icons.email, 'Email', _emailController.text),
                _summaryRow(Icons.workspace_premium, 'Experiencia',
                    '${_experienceController.text} años'),
                _summaryRow(
                    Icons.map, 'Departamento', _departmentController.text),
                _summaryRow(Icons.location_city, 'Municipio',
                    _municipalityController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: NexusColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: NexusColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                  fontSize: 14, color: NexusColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _back,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: NexusColors.border, width: 1.5),
              ),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Atrás',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        if (_currentStep > 1) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isRegistering ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == _totalSteps
                  ? NexusColors.greenProtection
                  : NexusColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(NexusAccessibility.borderRadius),
              ),
            ),
            icon: _isRegistering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _currentStep == _totalSteps
                        ? Icons.check_circle
                        : Icons.arrow_forward,
                    size: 22,
                  ),
            label: Text(
              _currentStep == _totalSteps
                  ? (_isRegistering ? 'Registrando...' : 'Registrarse')
                  : 'Siguiente',
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
