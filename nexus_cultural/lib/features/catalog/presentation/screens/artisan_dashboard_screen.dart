import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/artisan_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../services/catalogo_service.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/nexus_bottom_nav.dart';
import '../../../../shared/widgets/voice_assist_card.dart';
import '../../../authentication/controllers/auth_controller.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/artisan-dashboard';

  const ArtisanDashboardScreen({super.key});

  @override
  ConsumerState<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends ConsumerState<ArtisanDashboardScreen> {
  final CatalogoService _catalogoService = CatalogoService();
  bool _isLoading = true;
  List<ProductModel> _artisanProducts = [];

  @override
  void initState() {
    super.initState();
    _cargarProductosDelArtesano();
  }

  Future<void> _cargarProductosDelArtesano() async {
    setState(() => _isLoading = true);

    String? currentUserId;
    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      currentUserId = authCtrl.currentUserId;
    } catch (_) {}

    List<ProductModel> misProductos = [];

    // 1. Intentar cargar directamente del backend por ID de artesano
    if (currentUserId != null && currentUserId.isNotEmpty) {
      try {
        final articulosServer = await _catalogoService.obtenerPorArtesano(currentUserId);
        if (articulosServer.isNotEmpty) {
          misProductos = articulosServer.map((a) => a.toProductModel()).toList();
        }
      } catch (_) {
        // Fallback a filtrado de lista local
      }
    }

    // 2. Si el endpoint no retornó o no hay backend, filtrar de la lista global de productos
    if (misProductos.isEmpty) {
      final allProducts = ref.read(productsProvider);
      if (currentUserId != null && currentUserId.isNotEmpty) {
        misProductos = allProducts.where((p) => p.artisan.id == currentUserId).toList();
      }
    }

    // 3. Fallback demostrativo si es la primera vez que ingresa con el usuario de prueba
    if (misProductos.isEmpty) {
      final allProducts = ref.read(productsProvider);
      // Muestra las obras del taller predeterminado de muestra
      misProductos = allProducts.where((p) => p.artisan.id == 'art-maria-pushaina').toList();
    }

    if (mounted) {
      setState(() {
        _artisanProducts = misProductos;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    String workshopName = 'Taller Artesanal';
    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      workshopName = 'Taller de ${_getUserDisplayName(authCtrl.currentUserEmail)}';
    } catch (_) {}

    return Scaffold(
      appBar: NexusAppBar(
        title: 'Mi Catálogo e Inventario',
        subtitle: workshopName,
        voiceExplanation:
            'Panel de control de tu taller artesanal. Aquí encuentras exclusivamente tus obras publicadas para revisarlas, editarlas o controlar tu stock.',
      ),
      bottomNavigationBar: NexusBottomNav(
        currentIndex: 1,
        isArtisan: true,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              // Regresar a la pantalla de inicio (casita)
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
              break;
            case 1:
              // Ya estamos en Mi Catálogo
              _cargarProductosDelArtesano();
              break;
            case 2:
              // Botón circular (+) para publicar
              context.push('/create-product');
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
          onRefresh: _cargarProductosDelArtesano,
          child: ListView(
            padding: const EdgeInsets.all(18.0),
            children: [
              const VoiceAssistCard(
                title: 'Consejo Nexus para ti',
                subtitle: 'Las historias en voz multiplican las ventas',
                textToRead:
                    'Las obras con historia narrada por ti contando el significado del diseño conectan con compradores de todo el país y valoran tu oficio.',
              ),

              const SizedBox(height: 16),
              // Encabezado de sección (sin botón rectangular redundante)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis Productos',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay'),
                      ),
                      Text(
                        '${_artisanProducts.length} obras en tu taller',
                        style: const TextStyle(color: NexusColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Métricas de ventas
              InkWell(
                onTap: () {
                  context.push('/sales-metrics');
                },
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    border: Border.all(color: NexusColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up, color: NexusColors.greenDark, size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingresos del Mes: \$2.450.000 COP',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                            ),
                            Text('9 piezas vendidas con pago directo 100% al día', style: TextStyle(color: NexusColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: NexusColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Tus Obras Activas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator(color: NexusColors.primary)),
                )
              else if (_artisanProducts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    border: Border.all(color: NexusColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: NexusColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 14),
                      const Text(
                        'Aún no has publicado obras',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Usa el botón circular (+) de la barra inferior para cargar tus creaciones y empezar a vender en todo el país.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: NexusColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                )
              else
                ..._artisanProducts.map((prod) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              prod.images.isNotEmpty ? prod.images[0] : '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
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
                                Text(
                                  prod.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                                ),
                                Text(
                                  'Precio: \$${prod.price.toInt()} COP',
                                  style: const TextStyle(color: NexusColors.primary, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Stock disponible: ${prod.stock} piezas',
                                  style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: NexusColors.primary),
                            tooltip: 'Editar detalles de esta obra',
                            onPressed: () {
                              context.push('/create-product', extra: prod);
                            },
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
