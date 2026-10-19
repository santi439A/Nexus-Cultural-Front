import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/articulo_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../services/catalogo_service.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/nexus_bottom_nav.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

import '../../../authentication/controllers/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _catalogoService = CatalogoService();

  List<ArticuloModel> _articulos = [];
  bool _isLoading = true;
  String? _error;

  List<String> _categorias = ['ESTATUAS', 'CERAMICA', 'TEJIDOS', 'JOYERIA', 'BISUTERIA', 'MADERA'];
  String? _categoriaSeleccionada;
  bool _cartInitialized = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Carga la lista dinámica de categorías (enum Grupo) desde el backend
  Future<void> _cargarCategorias() async {
    try {
      final cats = await _catalogoService.obtenerCategorias();
      if (mounted && cats.isNotEmpty) {
        setState(() {
          _categorias = cats;
        });
      }
    } catch (_) {
      // Mantiene el fallback local de categorías ancestrales
    }
  }

  Map<String, dynamic> _getCategoryMetadata(String cat) {
    switch (cat.toUpperCase()) {
      case 'TEJIDOS':
        return {'label': 'Tejidos', 'sub': 'La Guajira', 'icon': Icons.texture};
      case 'CERAMICA':
        return {'label': 'Cerámica', 'sub': 'La Chamba', 'icon': Icons.grain};
      case 'JOYERIA':
        return {'label': 'Joyería', 'sub': 'Mompox', 'icon': Icons.diamond};
      case 'ESTATUAS':
        return {'label': 'Escultura', 'sub': 'San Agustín', 'icon': Icons.account_balance_outlined};
      case 'BISUTERIA':
        return {'label': 'Bisutería', 'sub': 'Chaquiras', 'icon': Icons.auto_awesome};
      case 'MADERA':
        return {'label': 'Madera', 'sub': 'Talla de Pasto', 'icon': Icons.park_outlined};
      default:
        return {'label': cat, 'sub': 'Ancestral', 'icon': Icons.category_outlined};
    }
  }

  /// Carga el catálogo desde el servidor
  Future<void> _cargarCatalogo({String? grupo, String? busqueda}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<ArticuloModel> resultados;
      if (busqueda != null && busqueda.isNotEmpty) {
        resultados = await _catalogoService.buscarCatalogo(busqueda);
      } else {
        resultados = await _catalogoService.obtenerCatalogo(grupo: grupo);
      }

      if (resultados.isEmpty) {
        resultados = sampleProducts.map((p) => ArticuloModel(
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
      }

      if (mounted) {
        setState(() {
          _articulos = resultados;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final fallback = sampleProducts.map((p) => ArticuloModel(
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
        setState(() {
          _articulos = fallback;
          _isLoading = false;
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
    if (email == null || email.isEmpty) return 'Comprador';
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
                'Salir',
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

  void _navegarADetalle(ArticuloModel articulo) {
    context.push('/product-detail', extra: articulo);
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

    String userName = 'Usuario';
    AuthController? authCtrl;
    bool isArtisan = false;
    try {
      authCtrl = p.Provider.of<AuthController>(context, listen: true);
      userName = _getUserDisplayName(authCtrl.currentUserEmail);
      final userRoleState = ref.watch(userRoleProvider);
      isArtisan = authCtrl.isArtisan || userRoleState == UserRole.artisan;
      if (authCtrl.isAdmin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/home-admin');
          }
        });
      }
      final userId = authCtrl.currentUserId;
      if (!_cartInitialized && userId != null && userId.isNotEmpty) {
        _cartInitialized = true;
        Future.microtask(() {
          ref.read(cartProvider.notifier).cargarCarritoDesdeServidor(userId);
        });
      }
    } catch (_) {}

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Stack(
          children: [
            NexusAppBar(
              title: 'Nexus Cultural',
              subtitle: isArtisan ? 'Panel Artesano & Catálogo' : 'Artesanías Ancestrales...',
              showBack: false,
              voiceExplanation: isArtisan
                  ? 'Panel de artesano. Puedes publicar tus creaciones con el botón más, revisar Mi Catálogo o explorar y comprar obras de otros artesanos.'
                  : 'Bienvenido al Catálogo Principal de Nexus Cultural. Desliza para explorar obras únicas hechas a mano por maestros artesanos colombianos.',
            ),
            Positioned(
              left: 12,
              top: 38,
              width: 50,
              height: 50,
              child: _buildProfilePopupMenu(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NexusBottomNav(
        currentIndex: 0,
        cartCount: cartCount,
        ordersBadge: 1,
        isArtisan: isArtisan,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
              _cargarCatalogo();
              break;
            case 1:
              if (isArtisan) {
                context.push('/artisan-dashboard');
              } else {
                context.push('/filters');
              }
              break;
            case 2:
              if (isArtisan) {
                context.push('/create-product');
              }
              break;
            case 3:
              context.push('/cart');
              break;
            case 4:
              context.push('/order-tracking');
              break;
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _cargarCatalogo(),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            children: [
              // Contextual Tag M07

              // Banner de bienvenida
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isArtisan ? const Color(0xFF5C2C16) : NexusColors.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(NexusAccessibility.borderRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          isArtisan ? Icons.handyman_outlined : Icons.person,
                          color: isArtisan ? NexusColors.primary : Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isArtisan ? 'Panel Artesano' : 'Bienvenido de nuevo',
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              if (isArtisan) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: NexusColors.goldAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'CREADOR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            isArtisan ? '¡Buen día, Maestro $userName!' : '¡Buen día, $userName!',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Barra de búsqueda
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 17),
                      onSubmitted: (query) {
                        _cargarCatalogo(busqueda: query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar mochilas, vasijas, h...',
                        prefixIcon: const Icon(Icons.search,
                            color: NexusColors.primary, size: 28),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              NexusAccessibility.borderRadius),
                          borderSide:
                              const BorderSide(color: NexusColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      context.push('/filters');
                    },
                    tooltip: 'Filtrar por regiones de Colombia',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(NexusAccessibility.minTouchTarget,
                          NexusAccessibility.minTouchTarget),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            NexusAccessibility.borderRadius),
                        side: const BorderSide(
                            color: NexusColors.border, width: 1.5),
                      ),
                    ),
                    icon: const Icon(Icons.tune,
                        color: NexusColors.primary, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const VoiceAssistCard(
                title: 'Escuchar novedades del día',
                subtitle: 'Resumen cultural en audio',
                textToRead:
                    'Destacamos esta semana la tejeduría en hilo de algodón silvestre del pueblo Wayúu en la Alta Guajira y vasijas ceremoniales de La Chamba Tolima.',
              ),

              const SizedBox(height: 18),
              // Banner destacado
              if (_articulos.isNotEmpty)
                _FeaturedCraftBanner(
                  articulo: _articulos[0],
                  onTap: () => _navegarADetalle(_articulos[0]),
                ),

              const SizedBox(height: 24),
              // Categorías Ancestrales (Cargadas dinámicamente desde el enum del backend)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorías Ancestrales',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: NexusColors.textPrimary,
                    ),
                  ),
                  if (_categoriaSeleccionada != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _categoriaSeleccionada = null);
                        _cargarCatalogo();
                      },
                      child: const Text(
                        'Limpiar filtro',
                        style: TextStyle(
                          color: NexusColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final cat = _categorias[index];
                    final meta = _getCategoryMetadata(cat);
                    final isSelected = _categoriaSeleccionada == cat;
                    return _CategoryChip(
                      icon: meta['icon'] as IconData,
                      label: meta['label'] as String,
                      sub: meta['sub'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        if (_categoriaSeleccionada == cat) {
                          setState(() => _categoriaSeleccionada = null);
                          _cargarCatalogo();
                        } else {
                          setState(() => _categoriaSeleccionada = cat);
                          _cargarCatalogo(grupo: cat);
                        }
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              // Encabezado del catálogo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categoriaSeleccionada != null
                        ? 'Obras: ${_getCategoryMetadata(_categoriaSeleccionada!)['label']}'
                        : 'Obras de Maestros',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: NexusColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _categoriaSeleccionada = null);
                      _cargarCatalogo();
                    },
                    child: Text(
                      'Ver todas (${_articulos.length})',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: NexusColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Renderizado condicional
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: NexusColors.primary),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(_error!, style: const TextStyle(color: NexusColors.error)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _cargarCatalogo(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (_articulos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Center(
                    child: Text(
                      'No se encontraron artículos disponibles.',
                      style: TextStyle(fontSize: 16, color: NexusColors.textSecondary),
                    ),
                  ),
                )
              else
                ..._articulos.map((articulo) => _ProductCard(
                      articulo: articulo,
                      onTap: () => _navegarADetalle(articulo),
                      onAddToCart: () {
                        final product = articulo.toProductModel();
                        final currentUserId = authCtrl?.currentUserId;
                        ref.read(cartProvider.notifier).addItem(product, 1, currentUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${articulo.titulo}" agregada al carrito.'),
                            backgroundColor: NexusColors.greenProtection,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCraftBanner extends StatelessWidget {
  final ArticuloModel articulo;
  final VoidCallback onTap;

  const _FeaturedCraftBanner({required this.articulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagen = articulo.imagenes.isNotEmpty ? articulo.imagenes[0] : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(color: NexusColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    imagen,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: NexusColors.surfaceContainer,
                      child: const Center(
                          child: Icon(Icons.image,
                              size: 60, color: NexusColors.primary)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: NexusColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Destacado de la Semana',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          articulo.titulo,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${articulo.precioEfectivo.toInt()} ${articulo.moneda}',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: NexusColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Categoría: ${articulo.grupo}',
                    style: const TextStyle(
                        fontSize: 15, color: NexusColors.textSecondary),
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

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.sub,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? NexusColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? NexusColors.primary : NexusColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? NexusColors.primary : NexusColors.textPrimary,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ArticuloModel articulo;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.articulo,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = articulo.imagenes.isNotEmpty ? articulo.imagenes[0] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
        border: Border.all(color: NexusColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap, // Hace que al tocar cualquier parte del item abra la pantalla de detalle
        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagen,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
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
                        Row(
                          children: [
                            const Icon(Icons.label,
                                size: 16, color: NexusColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              articulo.grupo,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: NexusColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          articulo.titulo,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stock disponible: ${articulo.stock}',
                          style: const TextStyle(
                              fontSize: 14, color: NexusColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${articulo.precioEfectivo.toInt()} ${articulo.moneda}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap, // Botón "Ver Historia" abre la pantalla de detalle con la descripción
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(
                            color: NexusColors.primary, width: 1.5),
                      ),
                      icon: const Icon(Icons.visibility, size: 20),
                      label:
                          const Text('Ver Historia', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexusColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      label: const Text('Comprar', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}