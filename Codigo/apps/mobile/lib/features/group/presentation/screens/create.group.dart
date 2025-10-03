import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/components/textfield.dart';
import '../../../../shared/components/buttonPrimary.dart';
import 'scoring.group.dart';

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
  String? _coverImagePath;

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

  void _selectCoverImage() {
    // TODO: Implementar seleção de imagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de upload será implementada')),
    );
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione as datas de início e fim')),
        );
        return;
      }
      
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        titleSpacing: 8,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Criar grupo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Escolher foto de capa
              _buildCoverImageSection(colors, textTheme),
              const SizedBox(height: 24),
              
              // Nome do Grupo
              AppTextField(
                label: 'Nome do Grupo',
                hintText: 'Insira o nome do seu grupo',
                required: true,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome do grupo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Descrição
              AppTextField(
                label: 'Descrição',
                hintText: 'Insira a descrição do grupo',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              
              // Adicionar repositório
              AppTextField(
                label: 'Adicionar repositório',
                hintText: 'Adicionar link do repositório do grupo',
                controller: _repositoryController,
                icon: Icons.code,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              
              // Data de Início
              _buildDateField(
                label: 'Data de Início',
                hintText: 'Escolha a data de início do grupo',
                required: true,
                date: _startDate,
                onTap: () => _selectDate(context, true),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: 20),
              
              // Data de Fim
              _buildDateField(
                label: 'Data de Fim',
                hintText: 'Escolha a data de fim do grupo',
                required: true,
                date: _endDate,
                onTap: () => _selectDate(context, false),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: 20),
              
              // Duração
              if (_duration != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: colors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Duração: $_duration dias',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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

  Widget _buildCoverImageSection(ColorScheme colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolher foto de capa',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectCoverImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: _coverImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _coverImagePath!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: colors.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque para adicionar imagem',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
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
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: textTheme.bodyMedium?.copyWith(color: colors.error),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                        : hintText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: date != null ? colors.onSurface : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: colors.onSurfaceVariant,
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
