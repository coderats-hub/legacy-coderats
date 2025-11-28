import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:file_selector/file_selector.dart';

class GroupEditScreen extends StatefulWidget {
  final String initialName;
  final String? initialDescription;
  final String? imageUrl;

  const GroupEditScreen({super.key, required this.initialName, this.initialDescription, this.imageUrl});

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final TextEditingController _nameCtrl;  
  late final TextEditingController _descCtrl;   
  Uint8List? _pickedImageBytes;               

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }


  // Seleção de imagem usando modal compartilhado
  void _selectImage() async {
    final source = await ImageSourceModal.show(context);
    if (source == null) return;
    
    try {
      final typeGroup = const XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
        mimeTypes: ['image/*'],
      );
      if (source == 'camera') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abrindo seletor do sistema para escolher/tirar foto'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _save() {
    // TODO: Integrar com API para persistir alterações
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Text('Cancelar', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                    ),
                    const Spacer(),
                    Text('Editar grupo', style: AppTextStyles.title.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _save,
                      child: Text('OK', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: GestureDetector(
                  onTap: _selectImage, // Abre seletor de imagem
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 120,
                      color: AppColors.accent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          // Fundo: gradiente padrão ou imagem selecionada
                          _pickedImageBytes == null
                              ? Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF9A24DD), Color(0xFF5A1A9A)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                )
                              : Image.memory(_pickedImageBytes!, fit: BoxFit.cover, width: double.infinity),
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white70, width: 1.6),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de edição do nome
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              style: AppTextStyles.inputLabel.copyWith(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Nome do grupo',
                                hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _nameCtrl.clear(),
                            icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Campo de edição da descrição (multilinha)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border.withOpacity(0.9)),
                            ),
                            child: TextField(
                              controller: _descCtrl,
                              maxLines: 4,
                              style: AppTextStyles.inputLabel.copyWith(color: AppColors.textPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet.',
                                hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 13),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: IconButton(
                              onPressed: () => _descCtrl.clear(),
                              icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text('Participantes', style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.md),

                    // Lista horizontal de avatares dos membros
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          child: const Center(child: Icon(Icons.person, color: Colors.black)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          child: const Center(child: Icon(Icons.person, color: Colors.black)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Botão para remover participantes
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface.withOpacity(0.6)),
                          child: IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
