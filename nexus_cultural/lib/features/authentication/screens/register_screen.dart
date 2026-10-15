import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/comprador_request.dart';
import '../models/artesano_request.dart';
import '../models/administrador_request.dart';
import '../../../config/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controladores Generales
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  // Controladores de Ubicación (Comprador y Artesano)
  final _departamentoController = TextEditingController();
  final _municipioController = TextEditingController();
  final _direccionController = TextEditingController();

  // Controladores Artesano
  final _anosExperienciaController = TextEditingController(text: '1');
  final _reconocimientoInputController = TextEditingController();
  final List<String> _reconocimientosList = [];

  // Controlador Administrador
  String _selectedNivelAcceso = 'GESTOR_CULTURAL';
  final List<String> _nivelesAcceso = [
    'GESTOR_CULTURAL',
    'MODERADOR_CONTENIDO',
    'SOPORTE',
    'SUPER_ADMIN',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<AuthController>().clearErrorMessage();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _departamentoController.dispose();
    _municipioController.dispose();
    _direccionController.dispose();
    _anosExperienciaController.dispose();
    _reconocimientoInputController.dispose();
    super.dispose();
  }

  void _agregarReconocimiento() {
    final text = _reconocimientoInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _reconocimientosList.add(text);
        _reconocimientoInputController.clear();
      });
    }
  }

  void _eliminarReconocimiento(int index) {
    setState(() {
      _reconocimientosList.removeAt(index);
    });
  }

  void _onSubmitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    bool success = false;
    final tabIndex = _tabController.index;

    if (tabIndex == 0) {
      // Registrar Comprador
      final request = CompradorRequest(
        nombreCompleto: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        departamento: _departamentoController.text.trim(),
        municipio: _municipioController.text.trim(),
        direccion: _direccionController.text.trim(),
      );
      success = await authController.registrarComprador(request);
    } else if (tabIndex == 1) {
      // Registrar Artesano
      final anos = int.tryParse(_anosExperienciaController.text.trim()) ?? 0;
      final request = ArtesanoRequest(
        nombreCompleto: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        anosExperiencia: anos,
        reconocimientos: List.from(_reconocimientosList),
        departamento: _departamentoController.text.trim(),
        municipio: _municipioController.text.trim(),
        direccion: _direccionController.text.trim(),
      );
      success = await authController.registrarArtesano(request);
    } else {
      // Registrar Administrador
      final request = AdministradorRequest(
        nombreCompleto: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        nivelAcceso: _selectedNivelAcceso,
      );
      success = await authController.registrarAdministrador(request);
    }

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(authController.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 28),
            SizedBox(width: 10),
            Text('¡Registro Exitoso!'),
          ],
        ),
        content: Text(
          context.read<AuthController>().successMessage ??
              'Tu cuenta ha sido creada exitosamente. Ahora puedes solicitar tu código OTP para ingresar.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Ir a Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final currentRoleName = _tabController.index == 0
        ? 'Comprador'
        : _tabController.index == 1
            ? 'Artesano'
            : 'Administrador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector de Rol con Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Comprador'),
                      Tab(text: 'Artesano'),
                      Tab(text: 'Admin'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Subtítulo contextual
                Text(
                  'Registro como $currentRoleName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _tabController.index == 0
                      ? 'Adquiere artesanías únicas y apoya a creadores locales.'
                      : _tabController.index == 1
                          ? 'Muestra tu talento, trayectoria y comercializa tus piezas.'
                          : 'Gestión y moderación de la comunidad cultural.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Error Banner
                if (authController.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authController.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campos Comunes
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo *',
                    hintText: 'Ej. María Pérez Gómez',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
                    if (value.trim().length < 3) return 'Debe tener al menos 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico *',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Campos Específicos para Comprador y Artesano (Ubicación)
                if (_tabController.index == 0 || _tabController.index == 1) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _departamentoController,
                          decoration: const InputDecoration(
                            labelText: 'Departamento *',
                            hintText: 'Ej. Quindío',
                            prefixIcon: Icon(Icons.map_outlined, color: AppColors.primary),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _municipioController,
                          decoration: const InputDecoration(
                            labelText: 'Municipio *',
                            hintText: 'Ej. Armenia',
                            prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      hintText: 'Ej. Calle 10 # 14-25',
                      prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'La dirección es obligatoria' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // Campos Específicos para Artesano (Trayectoria Cultural)
                if (_tabController.index == 1) ...[
                  TextFormField(
                    controller: _anosExperienciaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Años de Experiencia *',
                      hintText: 'Ej. 5',
                      prefixIcon: Icon(Icons.history_edu_outlined, color: AppColors.primary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Indica los años de experiencia';
                      final num = int.tryParse(value.trim());
                      if (num == null || num < 0) return 'Debe ser un número mayor o igual a 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Reconocimientos
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _reconocimientoInputController,
                          decoration: const InputDecoration(
                            labelText: 'Reconocimiento / Premio',
                            hintText: 'Ej. Medalla a la Maestría Artesanal',
                            prefixIcon: Icon(Icons.emoji_events_outlined, color: AppColors.accentGold),
                          ),
                          onFieldSubmitted: (_) => _agregarReconocimiento(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _agregarReconocimiento,
                      ),
                    ],
                  ),
                  if (_reconocimientosList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: List.generate(_reconocimientosList.length, (index) {
                        return Chip(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          label: Text(_reconocimientosList[index], style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _eliminarReconocimiento(index),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 14),
                ],

                // Campos Específicos para Administrador
                if (_tabController.index == 2) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedNivelAcceso,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Acceso *',
                      prefixIcon: Icon(Icons.shield_outlined, color: AppColors.primary),
                    ),
                    items: _nivelesAcceso.map((nivel) {
                      return DropdownMenuItem(
                        value: nivel,
                        child: Text(nivel),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedNivelAcceso = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 16),

                // Botón de Enviar Registro
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _onSubmitRegister,
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text('Registrar como $currentRoleName', style: const TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 24),

                // Link a Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}