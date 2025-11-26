/**
 * TELA DE CRIAÇÃO DE CHECK-IN
 * 
 * Esta tela permite ao usuário criar um novo check-in/atividade.
 * Funcionalidades principais:
 * - Upload de imagem da atividade
 * - Campo obrigatório de título
 * - Campo opcional de descrição
 * - Seleção de commits relacionados do GitHub
 * - Validação de campos obrigatórios
 * - Submissão da atividade
 * 
 * Estados da tela:
 * - Carregamento de commits
 * - Validação de formulário
 * - Feedback de sucesso/erro
 * - Contagem de commits selecionados
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';  // Removido para resolver conflito Android SDK
import 'dart:typed_data';
import '../widgets/shared_widgets.dart';

// Tela para criar um novo check-in de atividade
class CommitCheckinScreen extends StatefulWidget {
  const CommitCheckinScreen({super.key});

  @override
  State<CommitCheckinScreen> createState() => _CommitCheckinScreenState();
}

// Estado da tela de criação de check-in
class _CommitCheckinScreenState extends State<CommitCheckinScreen> {
  // Controladores dos campos de texto
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Lista mockada de commits disponíveis (futuramente virá da API do GitHub)
  final List<CommitItem> _commits = [
    CommitItem(title: 'Título do commit aqui', isSelected: false),
    CommitItem(title: 'Título do commit', isSelected: false),
    CommitItem(title: 'Exemplo de commit já utilizado', isSelected: false, isUsed: true),
    CommitItem(title: 'Título do commit', isSelected: false),
  ];
  
 // Variáveis de estado da tela
  int _selectedCommitsCount = 0; // Contador de commits selecionados
  Uint8List? _pickedImageBytes;
  bool _showTitleError = false; // Controla exibição do erro de título 
  
  @override
  void initState() {
    super.initState();
    // Listener para atualizar o botão quando o título muda
    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCommit(int index) {
    if (_commits[index].isUsed) return;
    
    setState(() {
      _commits[index].isSelected = !_commits[index].isSelected;
      _selectedCommitsCount = _commits.where((commit) => commit.isSelected).length;
    });
  }

  // Seleção de imagem usando modal compartilhado
  void _selectImage() async {
    final source = await ImageSourceModal.show(context);
    
    if (source == null) return;
    
    // Image picker functionality disabled - only UI works
    /*
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          
          // Seção de upload de imagem
          _buildImageUploadSection(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Campo de título
          _buildTitleField(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Campo de descrição
          _buildDescriptionField(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Seção de seleção de commits
          _buildCommitsSection(),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // Botão de envio
          _buildSubmitButton(),
          
          const SizedBox(height: AppSpacing.xxxl),
        ],
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
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Título',
                style: AppTextStyles.inputLabel,
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),
            if (_showTitleError) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Título é obrigatório',
                style: AppTextStyles.inputHint.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SharedTextField(
          controller: _titleController,
          placeholder: 'Insira o título da sua atividade',
          label: null,
          enabled: true,
          onChanged: (value) {
            if (_showTitleError && value.isNotEmpty) {
              setState(() {
                _showTitleError = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: AppSpacing.sm),
        SharedTextField(
          controller: _descriptionController,
          placeholder: 'Insira uma descrição para sua atividade',
          label: null,
          maxLines: 5,
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildCommitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecionar commits',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_selectedCommitsCount == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Selecione pelo menos 1 commit',
                  style: AppTextStyles.inputHint.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        // Lista de commits
        Column(
          children: _commits.asMap().entries.map((entry) {
            int index = entry.key;
            CommitItem commit = entry.value;
            return _buildCommitItem(commit, index);
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Botão carregar mais
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Implementar carregar mais commits
            },
            child: Text(
              'Carregar mais +',
              style: AppTextStyles.inputHint.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitItem(CommitItem commit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: commit.isUsed 
          ? AppColors.surface.withOpacity(0.5)
          : AppColors.surface,
        borderRadius: BorderRadius.circular(AppCorners.sm),
        border: Border.all(
          color: commit.isSelected 
            ? AppColors.accent
            : AppColors.border.withOpacity(0.2),
          width: commit.isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppCorners.sm),
          splashColor: AppColors.accent.withOpacity(0.1),
          highlightColor: AppColors.accent.withOpacity(0.05),
          onTap: () => _toggleCommit(index),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            title: Text(
              commit.title,
              style: AppTextStyles.inputLabel.copyWith(
                color: commit.isUsed ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: commit.isUsed 
              ? const Icon(
                  Icons.check_box,
                  color: AppColors.textSecondary,
                  size: 24,
                )
              : Checkbox(
                  value: commit.isSelected,
                  onChanged: (value) => _toggleCommit(index),
                  activeColor: AppColors.accent,
                  side: BorderSide(
                    color: AppColors.border.withOpacity(0.5),
                    width: 1,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _titleController.text.isNotEmpty && _selectedCommitsCount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: AppButton(
          text: 'Fazer Check-in',
          onPressed: _submitCheckin, // Sempre permite clicar para mostrar validações
        ),
      ),
    );
  }

  void _submitCheckin() {
    if (_titleController.text.isEmpty) {
      setState(() {
        _showTitleError = true;
      });
      return;
    }

    if (_selectedCommitsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione pelo menos um commit'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Implementar envio do checkin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Check-in criado com sucesso!'),
        backgroundColor: AppColors.accent,
      ),
    );

    // Voltar para a tela anterior
    Navigator.of(context).pop();
  }
}

// ======== MODELS ========

// Modelo para representar um commit do GitHub
class CommitItem {
  final String title;    // Título/mensagem do commit
  bool isSelected;       // Se está selecionado para o check-in
  final bool isUsed;     // Se já foi usado em outro check-in

  CommitItem({
    required this.title,
    this.isSelected = false, // Por padrão não selecionado
    this.isUsed = false,     // Por padrão não usado
  });
}