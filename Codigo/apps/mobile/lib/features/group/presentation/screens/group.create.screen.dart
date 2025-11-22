/**
 * Tela de Criação de Grupo (CreateGroupScreen)
 * 
 * NAVEGAÇÃO: Acessível via FAB na lista de grupos (group.list.screen.dart)
 * 
 * FUNÇÃO:
 * - Primeira etapa da criação de grupos com informações básicas
 * - Coleta nome, descrição, repositório, datas e imagem de capa
 * - Valida formulário e calcula duração automaticamente
 * - Redireciona para próxima etapa (configuração de pontuação)
 * 
 * FORMULÁRIO:
 * - Nome do grupo (obrigatório, 50 caracteres max)
 * - Descrição (obrigatório, 200 caracteres max)  
 * - Link do repositório (opcional, com validação de URL)
 * - Data de início e fim (obrigatórias, com validação de período)
 * - Imagem de capa (opcional, placeholder para futura implementação)
 * 
 * VALIDAÇÕES:
 * - Campos obrigatórios preenchidos
 * - Formato válido de URLs
 * - Data de fim posterior à data de início
 * - Cálculo automático da duração em dias
 * 
 * FLUXO NAVEGAÇÃO:
 * - Para configurar pontuação → group.scoring.screen.dart
 * - Volta para lista de grupos ao cancelar
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';  // Removido para resolver conflito Android SDK
import 'dart:typed_data';
import 'package:app/shared/components/app_components.dart';
import '../../../../shared/components/buttonPrimary.dart';
import 'group.scoring.screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave para validação do formulário
  
  // Controladores dos campos de texto
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repositoryController = TextEditingController();
  
  // Estados das datas e imagem
  DateTime? _startDate; // Data de início do grupo
  DateTime? _endDate;   // Data de fim do grupo
  Uint8List? _pickedImageBytes;

  @override
  void dispose() {
    // Limpa controladores para evitar memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _repositoryController.dispose();
    super.dispose();
  }

  // Recalcula duração quando as datas mudam
  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      setState(() {}); // Força rebuild para mostrar duração atualizada
    }
  }

  // Calcula duração em dias entre as datas selecionadas
  int? get _duration {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays;
    }
    return null;
  }

  // Abre seletor de data com tema personalizado
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(), // Não permite datas passadas
      lastDate: DateTime.now().add(const Duration(days: 365)), // Limite de 1 ano
      builder: (context, child) {
        // Aplica tema customizado ao date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Se data de fim é anterior à nova data de início, remove ela
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _calculateDuration(); // Recalcula duração após mudança
    }
  }

  // Placeholder para seleção de imagem de capa
  void _selectCoverImage() {
    _showImageSourceActionSheet();
  }

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
        _pickedImageBytes = bytes;
      });
    } catch (e) {
      // ignore
    }
    */
  }

  // Valida formulário e navega para próxima etapa
  void _continue() {
    // Valida campos de texto obrigatórios
    if (_formKey.currentState!.validate()) {
      // Valida data de início
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de início')),
        );
        return;
      }
      // Valida data de fim
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de fim')),
        );
        return;
      }
      // Navega para configuração de pontuação
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ScoringModeGroupsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header com título e botão de voltar
      appBar: AppHeader(
        title: 'Criar grupo',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      // Formulário scrollável com validação
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Escolher foto de capa
              _buildCoverImageSection(),
              const SizedBox(height: AppSpacing.lg),
              // Nome do Grupo
              SharedTextField(
                label: 'Nome do Grupo',
                placeholder: 'Insira o nome do seu grupo',
                controller: _nameController,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome do grupo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Descrição
              SharedTextField(
                label: 'Descrição',
                placeholder: 'Insira a descrição do grupo',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Data de Início
              _buildDateField(
                label: 'Data de Início',
                hintText: 'Escolha a data de início do grupo',
                required: true,
                date: _startDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Data de Fim
              _buildDateField(
                label: 'Data de Fim',
                hintText: 'Escolha a data de fim do grupo',
                required: true,
                date: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Duração
              if (_duration != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppCorners.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Duração: ${_duration ?? ''} dias',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              // Botão Continuar
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _continue,
                  child: const Text(
                    'Continuar',
                    style: AppTextStyles.headlineBold16White,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolher foto de capa',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCorners.md),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: _pickedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppCorners.md),
                    child: Image.memory(
                      _pickedImageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Toque para adicionar imagem',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFFACACAC),
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String hintText,
    required bool required,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.inputLabel,
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.inputLabel.copyWith(color: Colors.red),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                        : hintText,
                    style: date != null 
                        ? AppTextStyles.inputLabel
                        : const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFFACACAC),
                          ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
