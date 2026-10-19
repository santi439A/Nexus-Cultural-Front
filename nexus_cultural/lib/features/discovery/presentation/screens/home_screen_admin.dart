import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/articulo_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../services/catalogo_service.dart';
import '../../../../services/admin_service.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/nexus_admin_bottom_nav.dart';
import '../../../../shared/widgets/voice_assist_card.dart';
import '../../../authentication/controllers/auth_controller.dart';
import '../../../authentication/models/admin_model.dart';



/// Enum que representa los 4 niveles de acceso del Administrador definidos en el backend
enum AdminLevel {
  superAdmin('SUPER_ADMIN', 'Super Administrador', Icons.admin_panel_settings, NexusColors.primary),
  moderador('MODERADOR_CONTENIDO', 'Moderador de Contenido', Icons.verified_user_outlined, NexusColors.goldAccent),
  soporte('SOPORTE', 'Soporte y Atención', Icons.headset_mic_outlined, NexusColors.greenProtection),
  gestorCultural('GESTOR_CULTURAL', 'Gestor Cultural', Icons.account_balance_outlined, Color(0xFF6B4226));

  final String code;
  final String label;
  final IconData icon;
  final Color color;

  const AdminLevel(this.code, this.label, this.icon, this.color);

  static AdminLevel fromCode(String? code) {
    switch (code?.toUpperCase()) {
      case 'MODERADOR_CONTENIDO':
        return AdminLevel.moderador;
      case 'SOPORTE':
        return AdminLevel.soporte;
      case 'GESTOR_CULTURAL':
        return AdminLevel.gestorCultural;
      case 'SUPER_ADMIN':
      default:
        return AdminLevel.superAdmin;
    }
  }

  bool canManageAdmins() => this == AdminLevel.superAdmin;
  bool canChangeAccessLevel() => this == AdminLevel.superAdmin;
  bool canModerateContent() => this == AdminLevel.superAdmin || this == AdminLevel.moderador;
  bool canAccessSupport() => this == AdminLevel.superAdmin || this == AdminLevel.soporte;
  bool canManageCulturalHeritage() => this == AdminLevel.superAdmin || this == AdminLevel.gestorCultural;
}

class HomeScreenAdmin extends ConsumerStatefulWidget {
  static const routeName = '/home-admin';

  const HomeScreenAdmin({super.key});

  @override
  ConsumerState<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends ConsumerState<HomeScreenAdmin> {
  int _selectedTabIndex = 0;
  final _catalogoService = CatalogoService();
  final _adminService = AdminService();
  final _scrollController = ScrollController();

  List<ArticuloModel> _articulos = [];
  bool _isLoadingArticulos = true;

  // Lista de Administradores
  List<AdminModel> _administradores = [];
  bool _isLoadingAdmins = true;

  static final List<AdminModel> _fallbackAdministradores = [
    AdminModel(
      id: 'admin-001',
      nombreCompleto: 'Carlos Manuel Mendoza',
      email: 'carlos.mendoza@nexuscultural.com',
      nivelAcceso: 'SUPER_ADMIN',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
    ),
    AdminModel(
      id: 'admin-002',
      nombreCompleto: 'Laura Restrepo',
      email: 'laura.moderacion@nexuscultural.com',
      nivelAcceso: 'MODERADOR_CONTENIDO',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AdminModel(
      id: 'admin-003',
      nombreCompleto: 'Andrés Camargo',
      email: 'andres.soporte@nexuscultural.com',
      nivelAcceso: 'SOPORTE',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 20)),
    ),
    AdminModel(
      id: 'admin-004',
      nombreCompleto: 'Esperanza Palacios',
      email: 'esperanza.cultura@nexuscultural.com',
      nivelAcceso: 'GESTOR_CULTURAL',
      fechaRegistro: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // Datos para el módulo de Soporte
  int _selectedChatIndex = 0;
  final TextEditingController _chatInputController = TextEditingController();
  final List<Map<String, dynamic>> _ticketsSoporte = [
    {
      'id': 'TICK-101',
      'usuario': 'Doña María Pushaina',
      'rol': 'Artesana Wayúu',
      'asunto': 'Acreditación y desembolso por venta de Mochila Susu',
      'estado': 'ABIERTO',
      'mensajes': [
        {'emisor': 'usuario', 'texto': 'Buenas tardes, recibí la notificación de compra de mi mochila y deseo saber en qué fecha se acredita.', 'hora': '10:15 AM'},
        {'emisor': 'admin', 'texto': 'Buen día Doña María, un saludo cordial. Las acreditaciones bancarias se procesan dentro de las próximas 24 horas hábiles.', 'hora': '10:20 AM'},
      ]
    },
    {
      'id': 'TICK-102',
      'usuario': 'Carlos Gómez',
      'rol': 'Comprador',
      'asunto': 'Seguimiento de envío de Vasija Ceremonial La Chamba',
      'estado': 'EN_CURSO',
      'mensajes': [
        {'emisor': 'usuario', 'texto': 'Hola, quiero saber el número de guía para la vasija enviada desde el Tolima.', 'hora': '09:00 AM'},
        {'emisor': 'admin', 'texto': 'Hola Carlos, la guía fue despachada por Servientrega: #COL-88921. Llegará en 2 días.', 'hora': '09:12 AM'},
      ]
    },
    {
      'id': 'TICK-103',
      'usuario': 'Alonso Silva',
      'rol': 'Maestro Artesano',
      'asunto': 'Solicitud de verificación de Sello de Denominación de Origen',
      'estado': 'RESUELTO',
      'mensajes': [
        {'emisor': 'usuario', 'texto': 'Adjunto mis certificados de taller para solicitar el sello oficial del Ministerio.', 'hora': 'Ayer'},
        {'emisor': 'admin', 'texto': 'Documentación validada por la curaduría cultural. Sello otorgado exitosamente.', 'hora': 'Ayer'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
    _cargarAdministradores();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  Future<void> _cargarArticulos() async {
    setState(() => _isLoadingArticulos = true);
    try {
      final list = await _catalogoService.obtenerCatalogo();
      if (mounted) {
        setState(() {
          _articulos = list.isNotEmpty
              ? list
              : sampleProducts.map((p) => ArticuloModel(
                    id: p.id,
                    artesanoId: p.artisan.id,
                    titulo: p.name,
                    descripcion: p.tagline,
                    montoPrecio: p.price,
                    moneda: 'COP',
                    stock: p.stock,
                    estado: 'ACTIVO',
                    grupo: p.category.toUpperCase(),
                    imagenes: p.images,
                  )).toList();
          _isLoadingArticulos = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _articulos = sampleProducts.map((p) => ArticuloModel(
                id: p.id,
                artesanoId: p.artisan.id,
                titulo: p.name,
                descripcion: p.tagline,
                montoPrecio: p.price,
                moneda: 'COP',
                stock: p.stock,
                estado: 'ACTIVO',
                grupo: p.category.toUpperCase(),
                imagenes: p.images,
              )).toList();
          _isLoadingArticulos = false;
        });
      }
    }
  }

  Future<void> _cargarAdministradores() async {
    setState(() => _isLoadingAdmins = true);
    try {
      final list = await _adminService.obtenerAdministradores();
      if (mounted) {
        setState(() {
          _administradores = list.isNotEmpty ? list : List.from(_fallbackAdministradores);
          _isLoadingAdmins = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _administradores = List.from(_fallbackAdministradores);
          _isLoadingAdmins = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {

    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      await authCtrl.logout();
    } catch (_) {}
    if (context.mounted) {
      context.go('/welcome');
    }
  }

  String _getUserDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'Administrador';
    final namePart = email.split('@').first;
    final words = namePart.split(RegExp(r'[._-]'));
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _buildProfilePopupMenu({required Widget child}) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          context.push('/profile-setup');
        } else if (value == 'buyer_view') {
          context.push('/home');
        } else if (value == 'artisan_view') {
          context.push('/home-artisan');
        } else if (value == 'logout') {
          _handleLogout(context);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext ctx) => [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: NexusColors.primary),
              SizedBox(width: 10),
              Text(
                'Perfil de Administrador',
                style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'buyer_view',
          child: Row(
            children: [
              Icon(Icons.storefront_outlined, color: NexusColors.primary),
              SizedBox(width: 10),
              Text('Ver Catálogo (Comprador)'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'artisan_view',
          child: Row(
            children: [
              Icon(Icons.handyman_outlined, color: NexusColors.primary),
              SizedBox(width: 10),
              Text('Ver Taller (Artesano)'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: NexusColors.error),
              SizedBox(width: 10),
              Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.error),
              ),
            ],
          ),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = p.Provider.of<AuthController>(context);
    final userEmail = authCtrl.currentUserEmail ?? 'admin@nexuscultural.com';
    final userName = _getUserDisplayName(userEmail);
    final currentNivelStr = authCtrl.currentAdminNivelAcceso;
    final currentLevel = AdminLevel.fromCode(currentNivelStr);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Stack(
          children: [
            const NexusAppBar(
              title: 'Nexus Cultural',
              subtitle: 'Consola Administrativa Ancestral',
              showBack: false,
              voiceExplanation:
                  'Consola administrativa de Nexus Cultural. Administra roles, modera publicaciones, atiende soporte y curaduría cultural según tu nivel de acceso.',
            ),
            Positioned(
              left: 12,
              top: 38,
              width: 50,
              height: 50,
              child: _buildProfilePopupMenu(
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NexusAdminBottomNav(
        currentIndex: _selectedTabIndex,
        pendingModerationCount: _articulos.where((a) => a.estado != 'ACTIVO').length,
        activeSupportCount: _ticketsSoporte.where((t) => t['estado'] != 'RESUELTO').length,
        onTabSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
      ),
      body: SafeArea(
        child: _buildCurrentTabContent(currentLevel, userName, userEmail),
      ),
    );
  }

  Widget _buildCurrentTabContent(AdminLevel level, String userName, String userEmail) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInicioDashboard(level, userName, userEmail);
      case 1:
        return level.canModerateContent()
            ? _buildModeracionView()
            : _buildRestrictedAccessView(
                title: 'Moderación de Contenido',
                requiredRole: 'MODERADOR_CONTENIDO o SUPER_ADMIN',
                description: 'Solo los moderadores de contenido y el Super Administrador pueden evaluar, aprobar o suspender obras artesanales publicadas.',
              );
      case 2:
        return level.canAccessSupport()
            ? _buildSoporteView()
            : _buildRestrictedAccessView(
                title: 'Módulo de Soporte y Chat',
                requiredRole: 'SOPORTE o SUPER_ADMIN',
                description: 'Solo los especialistas de soporte y el Super Administrador están autorizados para atender consultas, reclamos y mediación con artesanos y compradores.',
              );
      case 3:
        return level.canManageCulturalHeritage()
            ? _buildGestorCulturalView()
            : _buildRestrictedAccessView(
                title: 'Gestor Cultural y Patrimonio',
                requiredRole: 'GESTOR_CULTURAL o SUPER_ADMIN',
                description: 'Solo el Gestor Cultural y el Super Administrador tienen autorización para emitir sellos de origen ancestral y administrar la curaduría cultural.',
              );
      case 4:
        return level.canManageAdmins()
            ? _buildEquipoAdminView(level)
            : _buildRestrictedAccessView(
                title: 'Gestión de Administradores',
                requiredRole: 'SUPER_ADMIN',
                description: 'El registro de administradores y el cambio de niveles de acceso está reservado exclusivamente para la jerarquía SUPER_ADMIN.',
              );
      default:
        return _buildInicioDashboard(level, userName, userEmail);
    }
  }

  // =========================================================================
  // TAB 0: INICIO / DASHBOARD GENERAL
  // =========================================================================
  Widget _buildInicioDashboard(AdminLevel level, String userName, String userEmail) {
    final authCtrl = p.Provider.of<AuthController>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _cargarArticulos(),
          _cargarAdministradores(),
        ]);
      },
      child: ListView(

        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A1A0C), Color(0xFF8A3B18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: NexusColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(level.icon, color: level.color, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Panel Administrativo',
                                style: TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: level.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  level.code,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '¡Bienvenido, $userName!',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            level.label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: NexusColors.borderLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, color: NexusColors.goldAccent, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Simular nivel para pruebas:',
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: level.code,
                          dropdownColor: const Color(0xFF2E150C),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          items: const [
                            DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('SUPER_ADMIN')),
                            DropdownMenuItem(value: 'MODERADOR_CONTENIDO', child: Text('MODERADOR')),
                            DropdownMenuItem(value: 'SOPORTE', child: Text('SOPORTE')),
                            DropdownMenuItem(value: 'GESTOR_CULTURAL', child: Text('GESTOR CULT.')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              authCtrl.setSimulatedNivelAcceso(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const VoiceAssistCard(
            title: 'Resumen de operaciones del sistema',
            subtitle: 'Centro de control Nexus Cultural',
            textToRead:
                'Consola de administración activa. Tienes acceso a los módulos habilitados según tu nivel de acceso asignado.',
          ),

          const SizedBox(height: 18),
          const Text(
            'Métricas del Ecosistema',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: NexusColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Obras en Catálogo',
                  value: '${_articulos.length}',
                  icon: Icons.inventory_2_outlined,
                  color: NexusColors.primary,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Pend. Moderación',
                  value: '${_articulos.where((a) => a.estado != 'ACTIVO').length}',
                  icon: Icons.pending_actions_outlined,
                  color: NexusColors.goldAccent,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Tickets Soporte',
                  value: '${_ticketsSoporte.where((t) => t['estado'] != 'RESUELTO').length}',
                  icon: Icons.chat_bubble_outline,
                  color: NexusColors.greenProtection,
                  onTap: () => setState(() => _selectedTabIndex = 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Administradores',
                  value: '${_administradores.length}',
                  icon: Icons.security_outlined,
                  color: const Color(0xFF6B4226),
                  onTap: () => setState(() => _selectedTabIndex = 4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Text(
            'Módulos y Permisos del Sistema',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: NexusColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _buildModuleActionCard(
            title: 'Moderación de Contenido',
            subtitle: 'Revisión y aprobación de publicaciones artesanales',
            icon: Icons.verified_user_outlined,
            allowed: level.canModerateContent(),
            requiredRoleText: 'MODERADOR_CONTENIDO o SUPER_ADMIN',
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          const SizedBox(height: 10),
          _buildModuleActionCard(
            title: 'Soporte y Atención por Chat',
            subtitle: 'Centro de chat en vivo con compradores y talleres artesanos',
            icon: Icons.headset_mic_outlined,
            allowed: level.canAccessSupport(),
            requiredRoleText: 'SOPORTE o SUPER_ADMIN',
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
          const SizedBox(height: 10),
          _buildModuleActionCard(
            title: 'Gestor Cultural Ancestral',
            subtitle: 'Curaduría de técnicas sagradas y sellos de origen',
            icon: Icons.account_balance_outlined,
            allowed: level.canManageCulturalHeritage(),
            requiredRoleText: 'GESTOR_CULTURAL o SUPER_ADMIN',
            onTap: () => setState(() => _selectedTabIndex = 3),
          ),
          const SizedBox(height: 10),
          _buildModuleActionCard(
            title: 'Gestión de Administradores',
            subtitle: 'Registro de administradores y cambio de nivel de acceso',
            icon: Icons.admin_panel_settings_outlined,
            allowed: level.canManageAdmins(),
            requiredRoleText: 'SUPER_ADMIN (Exclusivo)',
            onTap: () => setState(() => _selectedTabIndex = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NexusColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool allowed,
    required String requiredRoleText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: allowed ? Colors.white : const Color(0xFFFBF4F1),
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(
            color: allowed ? NexusColors.borderLight : NexusColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: allowed ? NexusColors.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: allowed ? NexusColors.primary : Colors.grey[600],
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: allowed ? NexusColors.textPrimary : Colors.grey[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: allowed ? NexusColors.greenProtectionContainer : Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          allowed ? 'AUTORIZADO' : 'BLOQUEADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: allowed ? NexusColors.greenDark : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    allowed ? subtitle : 'Requiere nivel: $requiredRoleText',
                    style: TextStyle(
                      fontSize: 13,
                      color: allowed ? NexusColors.textSecondary : NexusColors.error,
                      fontWeight: allowed ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              allowed ? Icons.arrow_forward_ios : Icons.lock_outline,
              size: 16,
              color: allowed ? NexusColors.primary : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // PANTALLA DE ACCESO RESTRINGIDO
  // =========================================================================
  Widget _buildRestrictedAccessView({
    required String title,
    required String requiredRole,
    required String description,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: NexusColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: NexusColors.error.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.lock_person_outlined, size: 48, color: NexusColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Acceso Restringido: $title',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: NexusColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NexusColors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NIVEL REQUERIDO: $requiredRole',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: NexusColors.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: NexusColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTabIndex = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primary,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                ),
              ),
              icon: const Icon(Icons.dashboard, color: Colors.white),
              label: const Text('Volver al Inicio', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 1: MODERACIÓN DE CONTENIDO
  // =========================================================================
  Widget _buildModeracionView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: NexusColors.goldAccent, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bandeja de Moderación',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                    ),
                    Text(
                      'Supervisión y control de autenticidad en catálogo',
                      style: TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _cargarArticulos,
                icon: const Icon(Icons.refresh, color: NexusColors.primary),
                tooltip: 'Actualizar lista',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: NexusColors.borderLight),
        Expanded(
          child: _isLoadingArticulos
              ? const Center(child: CircularProgressIndicator(color: NexusColors.primary))
              : _articulos.isEmpty
                  ? const Center(child: Text('No hay publicaciones pendientes de moderación'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _articulos.length,
                      itemBuilder: (context, index) {
                        final art = _articulos[index];
                        final isActivo = art.estado == 'ACTIVO';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                            border: Border.all(
                              color: isActivo ? NexusColors.borderLight : NexusColors.goldAccent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: art.imagenes.isNotEmpty
                                          ? Image.network(
                                              art.imagenes[0],
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 64,
                                                height: 64,
                                                color: NexusColors.surfaceDim,
                                                child: const Icon(Icons.palette_outlined),
                                              ),
                                            )
                                          : Container(
                                              width: 64,
                                              height: 64,
                                              color: NexusColors.surfaceDim,
                                              child: const Icon(Icons.palette_outlined),
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            art.titulo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: NexusColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Categoría: ${art.grupo} · Stock: ${art.stock}',
                                            style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${art.montoPrecio.toStringAsFixed(0)} ${art.moneda}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: NexusColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActivo
                                            ? NexusColors.greenProtectionContainer
                                            : NexusColors.errorContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        art.estado,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isActivo ? NexusColors.greenDark : NexusColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  art.descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _articulos[index] = art.copyWith(
                                              estado: isActivo ? 'SUSPENDIDO' : 'ACTIVO',
                                            );
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isActivo
                                                    ? 'Obra suspendida preventivamente del catálogo.'
                                                    : 'Obra aprobada y reactivada en catálogo.',
                                              ),
                                              backgroundColor: isActivo ? NexusColors.error : NexusColors.greenProtection,
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isActivo ? NexusColors.error : NexusColors.greenProtection,
                                          side: BorderSide(
                                            color: isActivo ? NexusColors.error : NexusColors.greenProtection,
                                          ),
                                        ),
                                        icon: Icon(isActivo ? Icons.pause_circle_outline : Icons.check_circle_outline, size: 18),
                                        label: Text(isActivo ? 'Inactivar' : 'Aprobar'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Sello de Autenticidad Ancestral Verificado asignado a esta obra.'),
                                              backgroundColor: NexusColors.goldAccent,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: NexusColors.goldAccent,
                                        ),
                                        icon: const Icon(Icons.verified, size: 18, color: Colors.white),
                                        label: const Text('Verificar Sello', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 2: SOPORTE Y CHAT EN VIVO
  // =========================================================================
  Widget _buildSoporteView() {
    final ticket = _ticketsSoporte[_selectedChatIndex];
    final List mensajes = ticket['mensajes'] as List;

    return Column(
      children: [
        Container(
          height: 68,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _ticketsSoporte.length,
            itemBuilder: (context, idx) {
              final t = _ticketsSoporte[idx];
              final isSel = idx == _selectedChatIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('${t['id']} · ${t['usuario']}'),
                  selected: isSel,
                  selectedColor: NexusColors.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : NexusColors.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedChatIndex = idx);
                  },
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: NexusColors.borderLight),

        Container(
          padding: const EdgeInsets.all(12),
          color: NexusColors.surfaceDim,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: NexusColors.primary,
                child: Text(
                  ticket['usuario'].toString().substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket['usuario']} (${ticket['rol']})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                    ),
                    Text(
                      ticket['asunto'],
                      style: const TextStyle(fontSize: 12, color: NexusColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ticket['estado'] == 'RESUELTO' ? NexusColors.greenProtectionContainer : NexusColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket['estado'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ticket['estado'] == 'RESUELTO' ? NexusColors.greenDark : NexusColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mensajes.length,
            itemBuilder: (context, i) {
              final m = mensajes[i];
              final isAdmin = m['emisor'] == 'admin';

              return Align(
                alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAdmin ? NexusColors.primaryContainer : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAdmin ? NexusColors.primary : NexusColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['texto'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isAdmin ? Colors.white : NexusColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['hora'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isAdmin ? Colors.white70 : NexusColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  decoration: InputDecoration(
                    hintText: 'Escribe una respuesta como soporte...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: NexusColors.borderLight),
                    ),
                  ),
                  onSubmitted: (_) => _enviarMensajeChat(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _enviarMensajeChat,
                style: IconButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                ),
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _enviarMensajeChat() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final list = _ticketsSoporte[_selectedChatIndex]['mensajes'] as List;
      list.add({
        'emisor': 'admin',
        'texto': text,
        'hora': 'Justo ahora',
      });
      _chatInputController.clear();
    });
  }

  // =========================================================================
  // TAB 3: GESTOR CULTURAL Y PATRIMONIO
  // =========================================================================
  Widget _buildGestorCulturalView() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B4226),
            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          ),
          child: const Row(
            children: [
              Icon(Icons.account_balance, color: NexusColors.goldAccent, size: 36),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Curaduría y Patrimonio Cultural',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Salvaguardia de saberes ancestrales y autenticidad territorial colombiana',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        const Text(
          'Sellos de Origen y Tradición Ancestral',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
        ),
        const SizedBox(height: 10),

        _buildHeritageCard(
          title: 'Tejeduría Wayúu Kanaas',
          territory: 'Uribia, La Guajira',
          technique: 'Ganchillo silvestre en 1 hebra con simbología sagrada',
          verified: true,
        ),
        const SizedBox(height: 10),
        _buildHeritageCard(
          title: 'Cerámica Negra Bruñida de La Chamba',
          territory: 'Guamo, Tolima',
          technique: 'Cocción con piedra de río y humo de leña abierta',
          verified: true,
        ),
        const SizedBox(height: 10),
        _buildHeritageCard(
          title: 'Barniz de Pasto (Mopa-Mopa)',
          territory: 'San Juan de Pasto, Nariño',
          technique: 'Resina vegetal silvestre y laminado manual Patrimonio UNESCO',
          verified: false,
        ),

        const SizedBox(height: 20),
        const Text(
          'Crónicas Culturales Destacadas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
            border: Border.all(color: NexusColors.borderLight, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories, color: NexusColors.primary, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Relato Ancestral Activo en Portada',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '“El tejido no es una labor comercial, es el rezo diario que une a la mujer Wayúu con las estrellas del desierto.”',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: NexusColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Crónica cultural actualizada para difusión en la app.'),
                      backgroundColor: NexusColors.greenProtection,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: NexusColors.primary),
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: const Text('Editar Crónica de la Semana', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeritageCard({
    required String title,
    required String territory,
    required String technique,
    required bool verified,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
        border: Border.all(color: NexusColors.borderLight, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.verified : Icons.hourglass_top,
            color: verified ? NexusColors.greenProtection : NexusColors.goldAccent,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                ),
                Text(
                  territory,
                  style: const TextStyle(fontSize: 12, color: NexusColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  technique,
                  style: const TextStyle(fontSize: 12, color: NexusColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: EQUIPO / GESTIÓN DE ADMINISTRADORES (ESTRUCTURA DE TARJETAS MODERACIÓN)
  // =========================================================================
  Widget _buildEquipoAdminView(AdminLevel level) {
    return RefreshIndicator(
      onRefresh: _cargarAdministradores,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        children: [
          // Botón superior: Agregar Administrador
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push('/register-admin');
              if (result == true) {
                await _cargarAdministradores();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.goldAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
              ),
            ),
            icon: const Icon(Icons.person_add, size: 20, color: Colors.white),
            label: const Text(
              'Agregar Administrador',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Administradores Registrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NexusColors.textPrimary,
                ),
              ),
              Text(
                '${_administradores.length} activos',
                style: const TextStyle(
                  fontSize: 13,
                  color: NexusColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_isLoadingAdmins)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: CircularProgressIndicator(color: NexusColors.primary),
              ),
            )
          else if (_administradores.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No hay administradores registrados.',
                  style: TextStyle(color: NexusColors.textSecondary),
                ),
              ),
            )
          else
            ..._administradores.asMap().entries.map((entry) {
              final index = entry.key;
              final admin = entry.value;
              final adminLevel = AdminLevel.fromCode(admin.nivelAcceso);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila superior: Avatar, Info y Badge de Nivel
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: adminLevel.color.withValues(alpha: 0.15),
                            child: Icon(adminLevel.icon, color: adminLevel.color, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin.nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: NexusColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  admin.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: NexusColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registrado: ${admin.fechaRegistro.day}/${admin.fechaRegistro.month}/${admin.fechaRegistro.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: NexusColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: adminLevel.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              adminLevel.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: adminLevel.color,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'ID: ${admin.id} · Nivel de Seguridad: ${admin.nivelAcceso}',
                        style: const TextStyle(fontSize: 12, color: NexusColors.textSecondary),
                      ),

                      const SizedBox(height: 14),

                      // Fila inferior: Botones Modificar y Eliminar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _mostrarDialogoCambiarNivel(admin),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NexusColors.primary,
                                side: const BorderSide(color: NexusColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text(
                                'Modificar Nivel',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmarEliminarAdmin(index, admin),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NexusColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                              label: const Text(
                                'Eliminar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // Confirmación y eliminación de un administrador
  void _confirmarEliminarAdmin(int index, AdminModel admin) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de revocar los permisos y eliminar al administrador "${admin.nombreCompleto}"?',
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      try {
                        await _adminService.eliminarAdministrador(admin.id);
                        if (mounted) {
                          setState(() {
                            _administradores.removeWhere((a) => a.id == admin.id);
                          });
                        }
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Administrador "${admin.nombreCompleto}" eliminado de la base de datos.'),
                              backgroundColor: NexusColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isDeleting = false);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        // Si falla la API en modo offline, eliminar localmente con feedback
                        if (mounted) {
                          setState(() {
                            _administradores.removeWhere((a) => a.id == admin.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Administrador "${admin.nombreCompleto}" eliminado.'),
                              backgroundColor: NexusColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: NexusColors.error),
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }


  // =========================================================================
  // DIÁLOGO: CAMBIAR NIVEL DE ACCESO
  // =========================================================================
  void _mostrarDialogoCambiarNivel(AdminModel admin) {
    String nuevoNivel = admin.nivelAcceso;
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz, color: NexusColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cambiar Nivel de Acceso',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administrador: ${admin.nombreCompleto}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Correo: ${admin.email}',
                    style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecciona el nuevo nivel:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: nuevoNivel,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('SUPER_ADMIN')),
                      DropdownMenuItem(value: 'MODERADOR_CONTENIDO', child: Text('MODERADOR_CONTENIDO')),
                      DropdownMenuItem(value: 'SOPORTE', child: Text('SOPORTE')),
                      DropdownMenuItem(value: 'GESTOR_CULTURAL', child: Text('GESTOR_CULTURAL')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => nuevoNivel = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          final authCtrl = p.Provider.of<AuthController>(context, listen: false);
                          setDialogState(() => isUpdating = true);
                          bool ok = false;
                          try {
                            ok = await _adminService.cambiarNivelAcceso(id: admin.id, nivelAcceso: nuevoNivel);
                            await authCtrl.cambiarNivelAccesoAdmin(admin.id, nuevoNivel);
                          } catch (_) {
                            ok = true; // Fallback local en pruebas
                          }

                          setDialogState(() => isUpdating = false);
                          if (dialogCtx.mounted) Navigator.pop(dialogCtx);



                          if (mounted) {
                            setState(() {
                              final idx = _administradores.indexWhere((a) => a.id == admin.id);
                              if (idx != -1) {
                                _administradores[idx] = admin.copyWith(nivelAcceso: nuevoNivel);
                              }
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Nivel de acceso actualizado con éxito a $nuevoNivel en el servidor.'
                                      : 'Nivel actualizado a $nuevoNivel.',
                                ),
                                backgroundColor: NexusColors.greenProtection,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: NexusColors.primary),
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Actualizar Nivel', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}