import 'package:flutter/material.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/admin_service.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';
import '../../models/administrador_request.dart';
import '../../../discovery/presentation/screens/home_screen_admin.dart';

class AdminRegistrationScreen extends StatefulWidget {
  static const routeName = '/register-admin';

  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminService = AdminService();

  String _selectedNivel = 'SUPER_ADMIN';
  bool _isSaving = false;

  final List<AdminLevel> _niveles = [
    AdminLevel.superAdmin,
    AdminLevel.moderador,
    AdminLevel.soporte,
    AdminLevel.gestorCultural,
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final req = AdministradorRequest(
      nombreCompleto: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      nivelAcceso: _selectedNivel,
    );

    try {
      await _adminService.registrarAdministrador(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Administrador "${req.nombreCompleto}" registrado exitosamente con nivel $_selectedNivel.'),
            backgroundColor: NexusColors.greenProtection,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar administrador: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Registro de Administrador',
        subtitle: 'Credenciales del Ecosistema Ancestral',
        voiceExplanation:
            'Formulario para vincular un nuevo administrador institucional. Ingresa el nombre completo, el correo electrónico y selecciona el nivel jerárquico de acceso.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const VoiceAssistCard(
                  title: 'Alta de Administrador Institucional',
                  subtitle: 'Seguridad y Gobernanza Nexus Cultural',
                  textToRead:
                      'Completa los datos para habilitar un nuevo operador en la consola administrativa según su rol designado.',
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    border: Border.all(color: NexusColors.borderLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.badge_outlined, color: NexusColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Datos de Identidad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campo: Nombre Completo
                      TextFormField(
                        controller: _nombreController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          hintText: 'Ej. María Clemencia Valenzuela',
                          prefixIcon: const Icon(Icons.person_outline, color: NexusColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el nombre completo';
                          }
                          if (value.trim().split(' ').length < 2) {
                            return 'Ingresa al menos nombre y apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo: Correo Electrónico
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico Institucional',
                          hintText: 'usuario@nexuscultural.com',
                          prefixIcon: const Icon(Icons.mail_outline, color: NexusColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el correo electrónico';
                          }
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value.trim())) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sección: Selector de Rol / Nivel de Acceso
                const Text(
                  'Selecciona el Nivel Jerárquico de Acceso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Define las atribuciones operativas dentro del panel administrativo:',
                  style: TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                ),
                const SizedBox(height: 14),

                ..._niveles.map((nivel) {
                  final isSelected = _selectedNivel == nivel.code;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedNivel = nivel.code);
                    },
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? nivel.color.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                        border: Border.all(
                          color: isSelected ? nivel.color : NexusColors.borderLight,
                          width: isSelected ? 2.0 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: nivel.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(nivel.icon, color: nivel.color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nivel.label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? nivel.color : NexusColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getNivelDescripcion(nivel.code),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: NexusColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: nivel.code,
                            groupValue: _selectedNivel,
                            activeColor: nivel.color,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedNivel = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Botón Guardar / Registrar
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Registrando en el servidor...' : 'Registrar Administrador',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNivelDescripcion(String code) {
    switch (code) {
      case 'SUPER_ADMIN':
        return 'Acceso total: gestión de equipo, moderación, soporte y curaduría.';
      case 'MODERADOR_CONTENIDO':
        return 'Evaluación, aprobación y suspensión de obras del catálogo artesanal.';
      case 'SOPORTE':
        return 'Atención por chat en vivo y mediación con talleres y compradores.';
      case 'GESTOR_CULTURAL':
        return 'Curaduría ancestral, técnicas sagradas y sellos de origen oficial.';
      default:
        return 'Permisos administrativos específicos.';
    }
  }
}
