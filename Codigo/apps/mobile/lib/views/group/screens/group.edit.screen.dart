/**
 * TELA DE EDIÇÃO DE GRUPO
 * 
 * Permite editar informações básicas de um grupo existente.
 * Acessível via menu de 3 pontos nos detalhes do grupo.
 * 
 * Funcionalidades:
 * - Editar nome e descrição do grupo
 * - Alterar imagem de capa (galeria ou câmera)
 * - Visualizar participantes atuais
 * - Remover participantes (botão delete)
 * 
 * Navegação:
 * - Vem de: GroupDetailPage (menu > Editar)
 * - Volta para: tela anterior após salvar
 */

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';  // Removido para resolver conflito Android SDK
// import 'package:cross_file/cross_file.dart';  // Removido - não disponível
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:app/group/widgets/banner.group.dart';

// Tela para editar informações de grupo existente
class GroupEditScreen extends StatefulWidget {
  final String initialName;
  final String? initialDescription;
  final String? imageUrl;

  const GroupEditScreen({super.key, required this.initialName, this.initialDescription, this.imageUrl});

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final TextEditingController _nameCtrl;    // Controlador do campo nome
  late final TextEditingController _descCtrl;    // Controlador do campo descrição
  // XFile? _pickedImage;                          // Arquivo de imagem selecionado - XFile não disponível
  Uint8List? _pickedImageBytes;                 // Bytes da imagem para preview

  @override
  void initState() {
    super.initState();
    // Inicializa campos com valores atuais do grupo
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _pickImage() {
    _showImageSourceActionSheet();
  }

  // Modal para escolher fonte da imagem (galeria ou câmera)
  Future<void> _showImageSourceActionSheet() async {
    // Image picker temporarily disabled to resolve Android SDK conflict
    /*
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
    */
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () => Navigator.of(ctx).pop('gallery'), // ImageSource.gallery
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () => Navigator.of(ctx).pop('camera'), // ImageSource.camera
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    
    // Image picker functionality disabled - only UI works
    /*
    try {
      final file = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1280);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = file;
        _pickedImageBytes = bytes;
      });
    } catch (e) {
    }
    */
  }

  // Salva alterações e volta para tela anterior
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
              // Header (Cancelar | Título | OK)
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

              // Banner editável com ícone de câmera
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: GestureDetector(
                  onTap: _pickImage, // Abre seletor de imagem
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
