import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:app/shared/components/app_components.dart';
import '../../../../shared/components/buttonPrimary.dart';
import 'group.scoring.screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repositoryController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _repositoryController.dispose();
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
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
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
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _calculateDuration();
    }
  }

  // Image upload removed: placeholder only

  void _continue() {
    if (_formKey.currentState!.validate()) {
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de fim')),
        );
        return;
      }
      // Define a data de início como agora
      _startDate = DateTime.now();
      // Navegar para a tela de método avaliativo
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
              // Escolher foto de capa
              _buildCoverImageSection(),
              const SizedBox(height: AppSpacing.lg),
              // Nome do Grupo
              SharedTextField(
                label: 'Nome do Grupo',
                placeholder: 'Insira o nome do seu grupo',
                controller: _nameController,
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
              // Adicionar repositório
              SharedTextField(
                label: 'Adicionar repositório',
                placeholder: 'Adicionar link do repositório do grupo',
                controller: _repositoryController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Data de início removida: será sempre a data atual
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
                        style: AppTextStyles.subtitle.copyWith(
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
              AppButtonPrimary(
                type: AppButtonPrimaryType.secondary,
                text: 'Continuar',
                onPressed: _continue,
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
          style: AppTextStyles.subtitle.copyWith(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Upload de imagem desativado',
                style: AppTextStyles.inputHint,
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
                    style: AppTextStyles.inputLabel.copyWith(
                      color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
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
