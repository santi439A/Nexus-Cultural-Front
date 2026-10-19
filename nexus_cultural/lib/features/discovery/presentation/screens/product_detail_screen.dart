import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/articulo_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/product-detail';

  /// Recibe el artículo enviado a través del parámetro extra de GoRouter
  final ArticuloModel? articulo;

  const ProductDetailScreen({super.key, this.articulo});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articulo = widget.articulo;

    if (articulo == null) {
      return const Scaffold(
        appBar: NexusAppBar(title: 'Detalle de Obra', subtitle: ''),
        body: Center(
          child: Text('No se pudo cargar la información del producto.'),
        ),
      );
    }

    final imagenes = articulo.imagenes;
    final double precioTotal = articulo.precioEfectivo * _quantity;

    return Scaffold(
      appBar: NexusAppBar(
        title: 'Obra Artesanal',
        subtitle: articulo.grupo,
        voiceExplanation:
            'Detalle de la obra artesanal ${articulo.titulo}. Categoría: ${articulo.grupo}. Precio: ${articulo.precioEfectivo.toInt()} ${articulo.moneda}.',
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
          child: Row(
            children: [
              // Selector de Cantidad
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: NexusColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_quantity < articulo.stock) {
                          setState(() => _quantity++);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Botón de Compra
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(
                          articulo.toProductModel(),
                          _quantity,
                        );
                    context.push('/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart, size: 22),
                  label: Text(
                    'Comprar (\$${precioTotal.toInt()} ${articulo.moneda})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              // Galería/Carrusel Dinámico de Fotos
              Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                          child: imagenes.isNotEmpty
                              ? PageView.builder(
                                  controller: _pageController,
                                  itemCount: imagenes.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _selectedImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      imagenes[index],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: NexusColors.surfaceContainer,
                                        child: const Icon(Icons.image, size: 64, color: NexusColors.primary),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: NexusColors.surfaceContainer,
                                  child: const Icon(Icons.image, size: 64, color: NexusColors.primary),
                                ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  imagenes.length > 1
                                      ? 'Foto ${_selectedImageIndex + 1}/${imagenes.length} · ${articulo.grupo}'
                                      : 'Foto en Taller · ${articulo.grupo}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Indicadores de Puntos (Dots)
                  if (imagenes.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imagenes.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _selectedImageIndex == index ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _selectedImageIndex == index
                                ? NexusColors.primary
                                : NexusColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Título y Precio
              Text(
                articulo.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                  color: NexusColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${articulo.precioEfectivo.toInt()} ${articulo.moneda}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NexusColors.primary,
                    ),
                  ),
                  if (articulo.precioConDescuento != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      '\$${articulo.montoPrecio.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: NexusColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // Asistente de Voz
              VoiceAssistCard(
                title: 'Escuchar historia de esta pieza',
                subtitle: 'Narrada con cariño y memoria oral',
                textToRead:
                    'Esta pieza es ${articulo.titulo}. ${articulo.descripcion}. Su categoría es ${articulo.grupo}.',
              ),

              const SizedBox(height: 16),

              // Tarjeta del Artesano (Se eliminó el 'const' de la Row)
              InkWell(
                onTap: () {
                  context.push('/artisan-profile');
                },
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                    border: Border.all(color: NexusColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: NexusColors.surfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: NexusColors.primary, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: NexusColors.primary, size: 36),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Taller del Artesano',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.verified, color: NexusColors.greenDark, size: 18),
                              ],
                            ),
                            Text(
                              'Pieza Ancestral Auténtica',
                              style: TextStyle(fontSize: 14, color: NexusColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: NexusColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Detalles y Simbología
              const Text(
                'Simbología y Memoria Viva',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${articulo.descripcion}"',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: NexusColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 20, color: NexusColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Stock disponible: ${articulo.stock} unidades',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Banner de Comercio Justo
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NexusColors.greenProtectionContainer,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.greenProtection.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: NexusColors.greenDark, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pago Directo y Ético: 90% del valor va a la cuenta bancaria del artesano sin comisiones ocultas.',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                      ),
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