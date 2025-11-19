import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tutorial_screen.dart';
import '../../providers/storage_provider.dart';
import '../../providers/pet_provider.dart';

class NamingScreen extends ConsumerStatefulWidget {
  const NamingScreen({super.key});

  @override
  ConsumerState<NamingScreen> createState() => _NamingScreenState();
}

class _NamingScreenState extends ConsumerState<NamingScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _suggestedNames = [
    '모모',
    '루루',
    '코코',
    '나비',
    '하루',
    '별이',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirmName() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      // Save pet name
      final storage = ref.read(storageProvider);
      storage.savePetName(name);

      // Create pet
      ref.read(petProvider.notifier).createPet(name);

      // Navigate to tutorial
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TutorialScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Text(
                      '🐱',
                      style: TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '이 친구의 이름을\n지어주세요',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '친구의 이름을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    if (value.trim().length > 10) {
                      return '이름은 10자 이내로 입력해주세요';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '추천 이름',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedNames.map((name) {
                  return InkWell(
                    onTap: () {
                      _nameController.text = name;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4E7CE).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFB4E7CE),
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmName,
                  child: const Text('확인'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
