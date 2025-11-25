import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

import '../../data/checkin.repository.dart';
import '../widgets/shared_widgets.dart';

class CommitCheckinScreen extends StatefulWidget {
  final String? groupId;
  const CommitCheckinScreen({super.key, this.groupId});

  @override
  State<CommitCheckinScreen> createState() => _CommitCheckinScreenState();
}

class _CommitCheckinScreenState extends State<CommitCheckinScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = CheckinRepository();

  Uint8List? _pickedImageBytes;
  bool _showTitleError = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  void _selectImage() async {
    final source = await ImageSourceModal.show(context);
    if (source == null) return;
    // Upload de imagem desabilitado; apenas UI.
  }

  Future<void> _submitCheckin() async {
    final groupId = widget.groupId ?? dotenv.env['DEFAULT_GROUP_ID'];
    if (groupId == null || groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Defina DEFAULT_GROUP_ID no .env ou passe o groupId para criar check-in.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.createCheckin(
        groupId: groupId,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in criado com sucesso!'),
          backgroundColor: AppColors.accent,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar check-in: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SharedTheme.buildDarkTheme(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeader(
          title: 'Code Rats',
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _buildImageUploadSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildTitleField(),
                const SizedBox(height: AppSpacing.lg),
                _buildDescriptionField(),
                const SizedBox(height: AppSpacing.xxl),
                _buildSubmitButton(),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCorners.md),
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: _pickedImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppCorners.md),
                child: Image.memory(
                  _pickedImageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Adicione uma foto a sua atividade',
                    style: AppTextStyles.inputHint,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('T\u00edtulo', style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Digite o t\u00edtulo do check-in',
            hintStyle: AppTextStyles.inputHint,
            errorText: _showTitleError ? 'Campo obrigat\u00f3rio' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descri\u00e7\u00e3o', style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Conte o que voc\u00ea fez',
            hintStyle: AppTextStyles.inputHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: AppButton(
          text: _isSubmitting ? 'Enviando...' : 'Fazer Check-in',
          onPressed: _handleSubmit,
        ),
      ),
    );
  }
  
  void _handleSubmit() {
    if (_isSubmitting || _titleController.text.isEmpty) {
      setState(() => _showTitleError = _titleController.text.isEmpty);
      return;
    }
    _submitCheckin();
  }
}
