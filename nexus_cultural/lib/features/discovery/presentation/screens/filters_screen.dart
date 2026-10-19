import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  static const routeName = '/filters';

  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  String _selectedRegion = 'La Guajira';
  double _maxPrice = 300000;
  bool _verifiedOnly = true;
  bool _nativeLanguageOnly = false;

  final List<String> _regions = [
    'Todas las Regiones',
    'La Guajira (Caribe Wayúu)',
    'Tolima (La Chamba)',
    'Córdoba (Pueblo Zenú)',
    'Boyacá (Ráquira)',
    'Nariño (Barniz de Pasto)',
    'Santander (Barichara)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Filtros y Regiones',
        subtitle: 'Búsqueda por Saber Ancestral',
        voiceExplanation:
            'Pantalla de filtros de búsqueda. Puedes elegir el departamento de Colombia, el rango de precio justo y buscar artesanos que hablen lenguas originarias.',
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: NexusColors.borderLight)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.primary,
              minimumSize: const Size(double.infinity, 56),
            ),
            icon: const Icon(Icons.check, size: 24),
            label: const Text('Aplicar Filtros y Explorar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [

            const Text('Región o Territorio Ancestral:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._regions.map((reg) {
              final isSelected = _selectedRegion == reg;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected ? NexusColors.surfaceHighlight : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? NexusColors.primary : NexusColors.border),
                ),
                child: RadioListTile<String>(
                  value: reg,
                  groupValue: _selectedRegion,
                  activeColor: NexusColors.primary,
                  title: Text(reg, style: const TextStyle(fontSize: 15)),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRegion = val);
                  },
                ),
              );
            }),

            const SizedBox(height: 18),
            Text(
              'Precio Máximo: \$${_maxPrice.toInt()} COP',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _maxPrice,
              min: 50000,
              max: 600000,
              divisions: 11,
              activeColor: NexusColors.primary,
              onChanged: (v) => setState(() => _maxPrice = v),
            ),

            const SizedBox(height: 12),
            SwitchListTile(
              value: _verifiedOnly,
              activeColor: NexusColors.primary,
              title: const Text('Solo maestros artesanos con certificado de origen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onChanged: (v) => setState(() => _verifiedOnly = v),
            ),
            SwitchListTile(
              value: _nativeLanguageOnly,
              activeColor: NexusColors.primary,
              title: const Text('Talleres que hablan lengua nativa (Wayuunaiki, etc.)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onChanged: (v) => setState(() => _nativeLanguageOnly = v),
            ),
          ],
        ),
      ),
    );
  }
}
