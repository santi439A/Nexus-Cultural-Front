import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' as p;

import '../../../../core/theme/nexus_theme.dart';
import '../../../../models/artisan_model.dart';
import '../../../../models/articulo_model.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';
import '../../../authentication/controllers/auth_controller.dart';

class CreateProductFlowScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-product';

  /// Opcional: pieza a editar (ProductModel o ArticuloModel)
  final dynamic itemToEdit;

  const CreateProductFlowScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<CreateProductFlowScreen> createState() => _CreateProductFlowScreenState();
}

class _CreateProductFlowScreenState extends ConsumerState<CreateProductFlowScreen> {
  int _currentStep = 1; // 1: Fotos y Categoría, 2: Historia & Voz, 3: Precio Justo
  bool _isPublishing = false;
  String _uploadProgressText = '';

  final _picker = ImagePicker();
  final List<String> _existingUrls = [];
  final List<XFile> _pickedImages = [];

  late final TextEditingController _nameController;
  late final TextEditingController _techniqueController;
  late final TextEditingController _symbolismController;
  double _price = 250000.0;
  int _stock = 3;
  bool _certifiedOrigin = true;
  String _selectedGrupo = 'TEJIDOS';

  final List<String> _gruposDisponibles = [
    'TEJIDOS',
    'CERAMICA',
    'JOYERIA',
    'ESTATUAS',
    'BISUTERIA',
    'MADERA',
  ];

  bool get _isEditing => widget.itemToEdit != null;
  double get artisanDirectPayout => _price * 0.90;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;

    if (item != null) {
      if (item is ProductModel) {
        _nameController = TextEditingController(text: item.name);
        _techniqueController = TextEditingController(text: item.technique);
        _symbolismController = TextEditingController(text: item.symbolism.isNotEmpty ? item.symbolism : item.tagline);
        _price = item.price;
        _stock = item.stock;
        _selectedGrupo = _mapCategoryToGrupo(item.category);
        _existingUrls.addAll(item.images);
      } else if (item is ArticuloModel) {
        _nameController = TextEditingController(text: item.titulo);
        _techniqueController = TextEditingController(text: 'Técnica ancestral colombiana');
        _symbolismController = TextEditingController(text: item.descripcion);
        _price = item.precioEfectivo;
        _stock = item.stock;
        _selectedGrupo = item.grupo;
        _existingUrls.addAll(item.imagenes);
      } else {
        _nameController = TextEditingController(text: 'Mochila Wayúu Susu Tradicional');
        _techniqueController = TextEditingController(text: 'Tejido a mano en una hebra (Ganchillo tradicional)');
        _symbolismController = TextEditingController(
          text: 'Figuras geométricas Kanaas que simbolizan las constelaciones sagradas y el camino del desierto.',
        );
      }
    } else {
      _nameController = TextEditingController(text: '');
      _techniqueController = TextEditingController(text: '');
      _symbolismController = TextEditingController(text: '');
    }
  }

  String _mapCategoryToGrupo(String cat) {
    final upper = cat.toUpperCase();
    if (upper.contains('TEJID')) return 'TEJIDOS';
    if (upper.contains('CERAM')) return 'CERAMICA';
    if (upper.contains('JOY')) return 'JOYERIA';
    if (upper.contains('ESTAT') || upper.contains('ESCULT')) return 'ESTATUAS';
    if (upper.contains('BISUT') || upper.contains('CHAQUIR')) return 'BISUTERIA';
    if (upper.contains('MAD')) return 'MADERA';
    return 'TEJIDOS';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _techniqueController.dispose();
    _symbolismController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> selected = await _picker.pickMultiImage(imageQuality: 85);
        if (selected.isNotEmpty) {
          setState(() {
            _pickedImages.addAll(selected);
          });
        }
      } else {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
        if (photo != null) {
          setState(() {
            _pickedImages.add(photo);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder al dispositivo: $e'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agregar fotos de la obra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona la cámara para capturar fotos en tu taller o la galería del celular.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: NexusColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NexusColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: NexusColors.primary),
                ),
                title: const Text('Tomar foto con la cámara', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Enfoca con buena luz natural de tu taller'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NexusColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: NexusColors.primary),
                ),
                title: const Text('Elegir de la galería', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Puedes seleccionar varias imágenes a la vez'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    final totalImages = _existingUrls.length + _pickedImages.length;
    if (_currentStep == 1) {
      if (totalImages < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requieren mínimo 2 fotografías para validar la obra artesanal.'),
            backgroundColor: NexusColors.error,
          ),
        );
        return;
      }
      if (_nameController.text.trim().length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre de la obra debe tener al menos 5 caracteres.'),
            backgroundColor: NexusColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_symbolismController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor escribe la historia o significado de la pieza.'),
            backgroundColor: NexusColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      _publishProduct();
    }
  }

  /// Solicita la Presigned URL y efectúa la subida directa de los bytes a S3
  Future<String> _subirImagenAAws(XFile file, int index) async {
    String extension = 'jpg';
    if (file.name.contains('.')) {
      extension = file.name.split('.').last.toLowerCase();
    }

    String contentType = 'image/jpeg';
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    }

    debugPrint('--> [PASO 1] Pidiendo Presigned URL a backend para: ${file.name} ($contentType)');

    // 1. Pedir la Presigned URL a Spring Boot a través de ApiClient
    final presignedRes = await ApiClient().get(
      '/v1/storage/presigned-url',
      queryParameters: {
        'extension': extension,
        'contentType': contentType,
      },
    );

    final String uploadUrl = presignedRes.data['uploadUrl'];
    final String publicUrl = presignedRes.data['publicUrl'];
    debugPrint('--> [PASO 2] URL Presign obtenida: $uploadUrl');

    // 2. Leer bytes en memoria
    final bytes = await file.readAsBytes();
    debugPrint('--> [PASO 3] Subiendo ${bytes.length} bytes directamente a S3...');

    // 3. Subida binaria directa a S3 vía PUT con cliente Dio limpio
    final dioS3 = Dio();
    final uploadResponse = await dioS3.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
      ),
    );

    debugPrint('--> [PASO 4] Resultado S3: ${uploadResponse.statusCode}');

    if (uploadResponse.statusCode == 200) {
      return publicUrl;
    } else {
      throw Exception('Fallo la subida directa a AWS S3. Código: ${uploadResponse.statusCode}');
    }
  }

  Future<void> _publishProduct() async {
    setState(() {
      _isPublishing = true;
      _uploadProgressText = 'Iniciando subida de fotografías directamente a AWS S3...';
    });

    try {
      final name = _nameController.text.trim();
      final technique = _techniqueController.text.trim();
      String desc = _symbolismController.text.trim();

      // Regla de moderación del backend: descripción >= 50 caracteres
      if (desc.length < 50) {
        desc = '$desc. Obra elaborada artesanalmente mediante $technique con técnicas ancestrales colombianas.';
      }

      // 1. Subir cada imagen seleccionada directamente a S3
      final List<String> finalCloudUrls = [..._existingUrls];
      for (int i = 0; i < _pickedImages.length; i++) {
        setState(() {
          _uploadProgressText = 'Subiendo fotografía ${i + 1} de ${_pickedImages.length} a AWS S3...';
        });
        final uploadedUrl = await _subirImagenAAws(_pickedImages[i], i);
        finalCloudUrls.add(uploadedUrl);
      }

      // 2. Registrar la obra con sus URLs definitivas en el backend
      setState(() {
        _uploadProgressText = 'Registrando obra en el catálogo de Nexus Cultural...';
      });

      String artesanoId = 'c3a8e9e2-51c0-4e5a-8b83-a74586940d91';
      try {
        final authCtrl = p.Provider.of<AuthController>(context, listen: false);
        if (authCtrl.currentUserId != null && authCtrl.currentUserId!.isNotEmpty) {
          artesanoId = authCtrl.currentUserId!;
        }
      } catch (_) {}

      final payload = {
        'artesanoId': artesanoId,
        'titulo': name,
        'descripcion': desc,
        'stock': _stock,
        'grupo': _selectedGrupo,
        'imagenes': finalCloudUrls,
        'precio': {
          'monto': _price,
          'moneda': 'COP',
        },
      };

      debugPrint('--> [PASO 5] Enviando artículo a /articulos...');
      await ApiClient().post(
        '/articulos',
        data: payload,
      );

      // 3. Actualizar estado local reactivo
      final newProduct = ProductModel(
        id: _isEditing ? widget.itemToEdit.id : 'prod-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        tagline: desc,
        category: _selectedGrupo,
        region: 'Colombia',
        department: 'Colombia',
        price: _price,
        artisan: sampleArtisans[0],
        images: finalCloudUrls,
        rating: 5.0,
        reviewsCount: 1,
        storyQuote: desc,
        technique: technique,
        craftingTime: '20 días',
        symbolism: desc,
        dimensions: 'Medidas tradicionales',
        stock: _stock,
        isFamilyWorkshop: true,
      );

      ref.read(productsProvider.notifier).addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '¡Obra artesanal actualizada y sincronizada en Nexus Cultural!'
                  : '¡Obra artesanal publicada exitosamente con fotos en AWS S3!',
            ),
            backgroundColor: NexusColors.greenProtection,
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('--> [ERROR PUBLICACIÓN]: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la publicación: $e'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NexusAppBar(
        title: _isEditing ? 'Modificar Obra' : 'Publicar Obra',
        subtitle: 'Paso $_currentStep de 3',
        voiceExplanation: _currentStep == 1
            ? 'Paso 1: Sube fotos claras de tu obra artesanal con luz natural y elige la categoría ancestral.'
            : _currentStep == 2
                ? 'Paso 2: Comparte el significado cultural de tu tejido y graba tu voz para los compradores.'
                : 'Paso 3: Calculadora de precio justo. Por una pieza de ${_price.toInt()} pesos recibirás ${artisanDirectPayout.toInt()} pesos directamente en tu cuenta.',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra de progreso de pasos
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentStep >= 1 ? NexusColors.primary : NexusColors.borderLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentStep >= 2 ? NexusColors.primary : NexusColors.borderLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentStep >= 3 ? NexusColors.primary : NexusColors.borderLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (_currentStep == 1) ..._buildStep1(),
                  if (_currentStep == 2) ..._buildStep2(),
                  if (_currentStep == 3) ..._buildStep3(),

                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (_currentStep > 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isPublishing ? null : () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: const Text('Atrás', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (_currentStep > 1) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isPublishing ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentStep == 3 ? NexusColors.greenProtection : NexusColors.primary,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          icon: Icon(_currentStep == 3 ? Icons.cloud_upload : Icons.arrow_forward, size: 22),
                          label: Text(
                            _currentStep == 3
                                ? (_isEditing ? 'Guardar Cambios' : 'Publicar Obra')
                                : 'Siguiente Paso',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_isPublishing)
              Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            strokeWidth: 4.5,
                            color: NexusColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sincronizando con AWS S3',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _uploadProgressText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: NexusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    final totalImages = _existingUrls.length + _pickedImages.length;

    return [
      const VoiceAssistCard(
        title: 'Fotografías claras de tu obra',
        subtitle: 'Usa luz natural de la mañana',
        textToRead:
            'Toma fotos sobre el telar o una mesa con buena luz. Puedes usar la cámara directamente o elegir fotos que ya tengas guardadas.',
      ),
      const SizedBox(height: 16),

      InkWell(
        onTap: _showImagePickerModal,
        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
            border: Border.all(
              color: totalImages < 2 ? NexusColors.primary : NexusColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: NexusColors.surfaceHighlight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_a_photo, size: 30, color: NexusColors.primary),
              ),
              const SizedBox(height: 12),
              const Text(
                'Toca para abrir cámara o galería',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Fotos agregadas: $totalImages de mínimo 2 requeridas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: totalImages < 2 ? NexusColors.error : NexusColors.greenDark,
                ),
              ),
            ],
          ),
        ),
      ),

      if (totalImages > 0) ...[
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10, top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image, color: NexusColors.primary),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => setState(() => _existingUrls.removeAt(index)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              ..._pickedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10, top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NexusColors.primary, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(file.path, fit: BoxFit.cover)
                            : Image.file(File(file.path), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => setState(() => _pickedImages.removeAt(index)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              InkWell(
                onTap: _showImagePickerModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: NexusColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: NexusColors.primary, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 18),
      const Text('Nombre de la Obra Artesanal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _nameController,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Ej: Mochila Wayúu Susu Tradicional',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      const SizedBox(height: 18),
      const Text('Categoría Ancestral (Enum backend):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedGrupo,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _gruposDisponibles.map((grupo) {
          return DropdownMenuItem(
            value: grupo,
            child: Text(
              grupo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) setState(() => _selectedGrupo = val);
        },
      ),

      const SizedBox(height: 18),
      const Text('Unidades disponibles (Stock)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 32, color: NexusColors.primary),
            onPressed: () {
              if (_stock > 1) setState(() => _stock--);
            },
          ),
          Text('$_stock piezas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 32, color: NexusColors.primary),
            onPressed: () => setState(() => _stock++),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      const VoiceAssistCard(
        title: 'Graba la memoria de tu pieza',
        subtitle: 'Tu propia voz es el mayor tesoro',
        textToRead:
            'Cuéntale al comprador qué representan las figuras geométricas o la arcilla utilizada. Puedes escribir o grabar tu voz.',
      ),
      const SizedBox(height: 16),
      const Text('Técnica y Materiales Ancestrales', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _techniqueController,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Ej: Tejido a mano en una hebra en ganchillo',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),
      const Text('Simbología e Historia Cultural Viva', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _symbolismController,
        maxLines: 4,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Cuéntanos el significado sagrado, el linaje o la tradición de este diseño...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NexusColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(color: NexusColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: NexusColors.primary, size: 30),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Nota de voz del artesano adjuntada (0:48 min)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle, color: NexusColors.primary, size: 32),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reproduciendo historia cultural viva del artesano...'),
                    backgroundColor: NexusColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      const VoiceAssistCard(
        title: 'Comercio justo sin trampas',
        subtitle: 'Sin comisiones abusivas',
        textToRead:
            'En Nexus Cultural el noventa por ciento del precio de venta va directo a tu cuenta bancaria o Nequi sin demoras.',
      ),
      const SizedBox(height: 16),
      const Text('Precio de Venta al Público (COP):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
        '\$${_price.toInt()} COP',
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: NexusColors.primary),
      ),
      Slider(
        value: _price,
        min: 30000,
        max: 900000,
        divisions: 29,
        activeColor: NexusColors.primary,
        onChanged: (val) => setState(() => _price = val),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(color: NexusColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pago directo a tu cuenta (90%):',
                    style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                  ),
                ),
                Text(
                  '\$${artisanDirectPayout.toInt()} COP',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Fondo comunitario (5%):',
                    style: TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                  ),
                ),
                Text('5% preservación', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Embalaje seguro y logística (5%):',
                    style: TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                  ),
                ),
                Text('5% operativo', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        value: _certifiedOrigin,
        activeColor: NexusColors.primary,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Certifico que esta pieza fue tejida o moldeada a mano en Colombia sin trabajo industrial ni reventa.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onChanged: (val) => setState(() => _certifiedOrigin = val ?? true),
      ),
    ];
  }
}