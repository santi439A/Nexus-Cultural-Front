import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile-setup';

  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _workshopNameController = TextEditingController(text: 'Taller Familiar Doña María');
  final _bioController = TextEditingController(
    text: 'Maestra tejedora del Clan Pushaina con más de 38 años de tradición en telar y algodón silvestre.',
  );
  String _selectedDepartment = 'La Guajira';
  final List<String> _selectedTechniques = ['Tejido en Telar', 'Cestería Ancestral'];

  final List<String> _departments = [
    'La Guajira',
    'Tolima',
    'Córdoba',
    'Boyacá',
    'Nariño',
    'Santander',
    'Chocó',
    'Amazonas',
  ];

  final List<String> _availableTechniques = [
    'Tejido en Telar',
    'Barro Negro Bruñido',
    'Cestería Ancestral',
    'Talla en Madera',
    'Filigrana',
    'Caña Flecha',
  ];

  @override
  void dispose() {
    _workshopNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Perfil de Taller',
        subtitle: 'Identidad y Saber Ancestral',
        voiceExplanation:
            'Configura los datos de tu taller artesanal. Indica tu departamento de origen, las técnicas ancestrales que dominas y cuéntale a los compradores sobre tu tradición familiar.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner M05

              const VoiceAssistCard(
                title: 'Lectura en voz alta',
                subtitle: 'Pulsa para escuchar instrucciones',
                textToRead:
                    'Tu perfil permite a los compradores conocer la vereda o resguardo donde elaboras tus piezas y asegura que cada obra tenga tu nombre y sello de autenticidad.',
              ),

              const SizedBox(height: 16),
              // Workshop Avatar Image Selection
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: NexusColors.surfaceHighlight,
                        shape: BoxShape.circle,
                        border: Border.all(color: NexusColors.primary, width: 3),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 64, color: NexusColors.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: NexusColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              // Workshop Name
              const Text(
                'Nombre de tu taller o artesano',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _workshopNameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ej: Taller Ancestral Doña María',
                ),
              ),

              const SizedBox(height: 18),
              // Department Selector
              const Text(
                'Departamento de Origen en Colombia',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(),
                items: _departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept, style: const TextStyle(fontSize: 17)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDepartment = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),
              // Ancestral Techniques Chips
              const Text(
                'Técnicas Ancestrales Dominadas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTechniques.map((tech) {
                  final isSelected = _selectedTechniques.contains(tech);
                  return FilterChip(
                    label: Text(
                      tech,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : NexusColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: NexusColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? NexusColors.primary : NexusColors.border,
                      width: 1.5,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTechniques.add(tech);
                        } else {
                          _selectedTechniques.remove(tech);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),
              // Cultural Story / Bio
              const Text(
                'Historia de tu Tradición Familiar',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Describe quién te enseñó el oficio y cuántas generaciones llevan en tu familia...',
                ),
              ),

              const SizedBox(height: 28),
              // Save and enter button
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.check, size: 26),
                label: const Text(
                  'Guardar Perfil y Entrar a Nexus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
