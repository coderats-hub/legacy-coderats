import 'package:app/shared/components/components.dart';
import 'package:app/views/group/screens/group.scoring.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:convert';
import 'dart:typed_data';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _pickedImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      setState(() {});
    }
  }

  int? get _duration {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays;
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now()) 
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate 
          ? DateTime.now() 
          : (_startDate ?? DateTime.now()),
      lastDate: isStartDate
          ? (_endDate ?? DateTime.now().add(const Duration(days: 365)))
          : DateTime.now().add(const Duration(days: 365)), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary, // Garante cor correta no calendário
              onPrimary: Colors.white,
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
          // Se a data de fim for menor que a de início, limpa a data de fim
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
          // Se a data de início for maior que a de fim, limpa a data de início
          if (_startDate != null && _startDate!.isAfter(picked)) {
            _startDate = null;
          }
        }
      });
      _calculateDuration();
    }
  }

  // Seleção de imagem de capa usando modal compartilhado
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

  // --- AQUI ESTÁ A CORREÇÃO PRINCIPAL ---
  void _continue() {
    if (_formKey.currentState!.validate()) {
      // 1. Validações manuais de data
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de início'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de fim'), backgroundColor: Colors.red),
        );
        return;
      }

      // 2. Navegação Passando Dados
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScoringModeGroupsScreen(
            // Passando os dados do formulário para a próxima tela
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty 
                ? _descriptionController.text.trim() 
                : null,
            startDate: _startDate!,
            endDate: _endDate!,
            image: _pickedImageBytes != null ? base64Encode(_pickedImageBytes!) : null, 
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Criar grupo',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImageSection(),
              const SizedBox(height: AppSpacing.lg),
              
              SharedTextField(
                label: 'Nome do Grupo',
                placeholder: 'Insira o nome do seu grupo',
                controller: _nameController,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome do grupo é obrigatório';
                  }
                  if (value.length < 3) {
                    return 'O nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              SharedTextField(
                label: 'Descrição',
                placeholder: 'Insira a descrição do grupo',
                controller: _descriptionController,
                maxLines: 3,
                required: false, // Descrição opcional
              ),
              const SizedBox(height: AppSpacing.lg),
              
              _buildDateField(
                label: 'Data de Início',
                hintText: 'Escolha a data de início',
                required: true,
                date: _startDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              _buildDateField(
                label: 'Data de Fim',
                hintText: 'Escolha a data de fim',
                required: true,
                date: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: AppSpacing.lg),
              
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
        const Text(
          'Escolher foto de capa',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _selectImage,
          child: Container(
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
