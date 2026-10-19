import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/articulo_model.dart';
import '../../../../services/catalogo_service.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/nexus_artisan_bottom_nav.dart';
import '../../../../shared/widgets/voice_assist_card.dart';
import '../../../authentication/controllers/auth_controller.dart';

class HomeScreenArtisan extends ConsumerStatefulWidget {
  static const routeName = '/home-artisan';

  const HomeScreenArtisan({super.key});

  @override
  ConsumerState<HomeScreenArtisan> createState() => _HomeScreenArtisanState();
}

class _HomeScreenArtisanState extends ConsumerState<HomeScreenArtisan> {
  final _scrollController = ScrollController();
  final _catalogoService = CatalogoService();

  List<ArticuloModel> _misArticulos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarMisObras();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarMisObras() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      final currentUserId = authCtrl.currentUserId;

      final catalogoCompleto = await _catalogoService.obtenerCatalogo();

      final articulosPropios = currentUserId != null && currentUserId.isNotEmpty
          ? catalogoCompleto.where((a) => a.artesanoId == currentUserId).toList()
          : <ArticuloModel>[];

      if (mounted) {
        setState(() {
          _misArticulos = articulosPropios;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _misArticulos = [];
          _isLoading = false;
          _error = 'No fue posible sincronizar las obras de tu taller.';
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
    if (email == null || email.isEmpty) return 'Maestro Artesano';
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
        } else if (value == 'my_catalog') {
          context.push('/artisan-dashboard');
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
                'Modificar perfil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: NexusColors.textPrimary,
                ),
              ),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: NexusColors.error,
                ),
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
    String userName = 'Maestro Artesano';
    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: true);
      userName = _getUserDisplayName(authCtrl.currentUserEmail);
    } catch (_) {}

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Stack(
          children: [
            const NexusAppBar(
              title: 'Nexus Cultural',
              subtitle: 'Panel de Control del Artesano',
              showBack: false,
              voiceExplanation:
                  'Bienvenido a tu taller digital. Gestiona tus obras, revisa tus pedidos y publica nuevas creaciones ancestrales.',
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
      bottomNavigationBar: NexusArtisanBottomNav(
        currentIndex: 0,
        ordersBadge: 0,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              _cargarMisObras();
              break;
            case 1:
              context.push('/artisan-dashboard');
              break;
            case 2:
              context.push('/create-product');
              break;
            case 3:
              context.push('/sales-metrics'); // Pantalla de estadísticas ya existente
              break;
            case 4:
              context.push('/order-tracking');
              break;
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarMisObras,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: NexusColors.primaryContainer,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: NexusColors.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.palette_outlined, color: NexusColors.primary, size: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Taller Artesanal',
                            style: TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                      tooltip: 'Perfil',
                      onPressed: () => context.push('/profile-setup'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const VoiceAssistCard(
                title: 'Espacio de Creación',
                subtitle: 'Consejos para el taller',
                textToRead:
                    'Mantén el inventario de tus piezas actualizado y documenta el significado cultural de tus técnicas para que tus compradores valoren tu historia.',
              ),

              const SizedBox(height: 20),

              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                  color: NexusColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.add_photo_alternate_outlined,
                      label: 'Publicar\nNueva Obra',
                      color: NexusColors.primary,
                      onTap: () => context.push('/create-product'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Mi Catálogo\ny Stock',
                      color: NexusColors.surfaceContainer,
                      textColor: NexusColors.textPrimary,
                      iconColor: NexusColors.primary,
                      onTap: () => context.push('/artisan-dashboard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Ventas por\nDespachar',
                      color: NexusColors.surfaceContainer,
                      textColor: NexusColors.textPrimary,
                      iconColor: NexusColors.primary,
                      onTap: () => context.push('/order-tracking'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Obras en Exhibición',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: NexusColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_misArticulos.length} pieza(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NexusColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: NexusColors.primary),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(_error!, style: const TextStyle(color: NexusColors.error)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _cargarMisObras,
                        child: const Text('Reintentar sincronización'),
                      ),
                    ],
                  ),
                )
              else if (_misArticulos.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NexusColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 54, color: NexusColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'Aún no tienes obras publicadas',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Comienza a exhibir tus creaciones artesanales a compradores de todo el país.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: NexusColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/create-product'),
                        icon: const Icon(Icons.add),
                        label: const Text('Publicar primera obra'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NexusColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._misArticulos.map((articulo) => _ArtisanItemCard(
                      articulo: articulo,
                      onTap: () => context.push('/product-detail', extra: articulo),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhiteText = textColor == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWhiteText ? Colors.transparent : NexusColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: iconColor ?? Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtisanItemCard extends StatelessWidget {
  final ArticuloModel articulo;
  final VoidCallback onTap;

  const _ArtisanItemCard({
    required this.articulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = articulo.imagenes.isNotEmpty ? articulo.imagenes[0] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexusColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              imagen,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: NexusColors.surfaceContainer,
                child: const Icon(Icons.image, color: NexusColors.primary),
              ),
            ),
          ),
        ),
        title: Text(
          articulo.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Categoría: ${articulo.grupo}'),
            Text(
              'Stock: ${articulo.stock} unidad(es) · \$${articulo.precioEfectivo.toInt()} ${articulo.moneda}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: NexusColors.primary),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: NexusColors.textSecondary),
      ),
    );
  }
}