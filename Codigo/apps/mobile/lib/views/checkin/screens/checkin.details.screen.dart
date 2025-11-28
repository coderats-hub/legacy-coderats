import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/core/session_manager.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

import '../../../repositories/checkin.repository.dart';
import '../../../repositories/github_commits.repository.dart';
import '../../../domain/checkin/github_commit.dart';
import '../widgets/shared_widgets.dart';

class CommitCheckinScreen extends StatefulWidget {
  final String? groupId;
  final String? groupName;
  
  const CommitCheckinScreen({super.key, this.groupId, this.groupName});

  @override
  State<CommitCheckinScreen> createState() => _CommitCheckinScreenState();
}

class _CommitCheckinScreenState extends State<CommitCheckinScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = CheckinRepository();
  final _githubCommitsRepository = GithubCommitsRepository();
  final SessionManager _session = SessionManager.instance;

  Uint8List? _pickedImageBytes;
  bool _showTitleError = false;
  bool _isSubmitting = false;
  bool _showCommitSelectionError = false;

  List<GithubCommit> _commits = [];
  final Map<String, GithubCommit> _selectedCommits = {};
  bool _isLoadingCommits = false;
  String? _commitErrorMessage;
  int _commitPage = 1;
  final int _commitPageSize = 5;
  final int _commitLookbackHours = 24;
  bool _hasMoreCommits = true;
  String? _groupRepository;

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
    _loadCommits();
  }

  void _selectImage() async {
    final source = await ImageSourceModal.show(context);
    if (source == null) return;
    // Upload de imagem desabilitado; apenas UI.
  }

  Future<String?> _ensureGroupRepository(String groupId) async {
    if (_groupRepository != null && _groupRepository!.isNotEmpty) {
      return _groupRepository;
    }
    final repo = await _githubCommitsRepository.fetchGroupRepository(groupId);
    if (repo != null && repo.isNotEmpty) {
      if (mounted) {
        setState(() {
          _groupRepository = repo;
        });
      } else {
        _groupRepository = repo;
      }
    }
    return _groupRepository;
  }

  Future<void> _loadCommits({bool loadMore = false}) async {
    if (_isLoadingCommits) return;
    final groupId = widget.groupId ?? dotenv.env['DEFAULT_GROUP_ID'];
    if (groupId == null || groupId.isEmpty) {
      if (mounted) {
        setState(() {
          _commits = [];
          _hasMoreCommits = false;
          _commitErrorMessage =
              'Defina DEFAULT_GROUP_ID no .env ou passe um groupId para carregar commits.';
        });
      }
      return;
    }
    final nextPage = loadMore ? _commitPage + 1 : 1;

    if (mounted) {
      setState(() {
        _isLoadingCommits = true;
        _commitErrorMessage = null;
        if (!loadMore) {
          _commits = [];
          _hasMoreCommits = true;
        }
      });
    }

    try {
      final repoUrl = await _ensureGroupRepository(groupId);
      if (repoUrl == null || repoUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _commitErrorMessage =
                'Grupo não possui repositório configurado. Atualize o cadastro do grupo e tente novamente.';
            _isLoadingCommits = false;
            _hasMoreCommits = false;
          });
        }
        return;
      }

      final githubUsername = _session.currentUser?.githubUser;
      final items = await _githubCommitsRepository.fetchCommits(
        groupId: groupId,
        page: nextPage,
        size: _commitPageSize,
        hours: _commitLookbackHours,
        repoUrl: repoUrl,
        githubUsername: githubUsername,
      );
      if (!mounted) return;
      setState(() {
        _commitPage = nextPage;
        if (loadMore) {
          _commits = [..._commits, ...items];
        } else {
          _commits = items;
          _selectedCommits.removeWhere(
            (sha, _) => !_commits.any((c) => c.sha == sha),
          );
        }
        _hasMoreCommits = items.length == _commitPageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _commitErrorMessage = 'Não foi possível carregar commits: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingCommits = false);
    }
  }

  void _toggleCommitSelection(GithubCommit commit) {
    setState(() {
      if (_selectedCommits.containsKey(commit.sha)) {
        _selectedCommits.remove(commit.sha);
      } else {
        _selectedCommits[commit.sha] = commit;
        if (_titleController.text.isEmpty && commit.message.isNotEmpty) {
          _titleController.text = commit.message;
        }
      }
      _showCommitSelectionError = _selectedCommits.isEmpty;
    });
  }

  String _buildCommitSummary() {
    if (_selectedCommits.isEmpty) return '';
    final buffer = StringBuffer('Commits selecionados:');
    for (final commit in _selectedCommits.values) {
      final repo = commit.repository.isNotEmpty ? commit.repository : 'repositório';
      final shortSha =
          commit.sha.length > 7 ? commit.sha.substring(0, 7) : commit.sha;
      buffer.writeln();
      buffer.write('- ${commit.message.isNotEmpty ? commit.message : 'Commit sem mensagem'}');
      buffer.write(' • $repo ($shortSha)');
    }
    return buffer.toString().trim();
  }

  String _composeDescription(String commitSummary) {
    final pieces = <String>[];
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      pieces.add(description);
    }
    if (commitSummary.isNotEmpty) {
      pieces.add(commitSummary);
    }
    return pieces.join('\n\n');
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

    if (_selectedCommits.isEmpty) {
      setState(() => _showCommitSelectionError = true);
      return;
    }

    final commitSummary = _buildCommitSummary();
    final composedDescription = _composeDescription(commitSummary);

    setState(() => _isSubmitting = true);

    try {
      await _repository.createCheckin(
        groupId: groupId,
        title: _titleController.text,
        description: composedDescription.isNotEmpty ? composedDescription : null,
        summaryAi: commitSummary.isNotEmpty ? commitSummary : null,
        commits: _selectedCommits.values.toList(),
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
        appBar: AppHeader(
          title: widget.groupName ?? 'Code Rats',
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
                const SizedBox(height: AppSpacing.lg),
                _buildCommitSelector(),
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

  Widget _buildCommitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Selecionar commits', style: AppTextStyles.inputLabel),
            ),
            if (_showCommitSelectionError)
              Text(
                'Selecione pelo menos 1 commit',
                style: AppTextStyles.inputHint.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isLoadingCommits && _commits.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_commitErrorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Não foi possível carregar os commits recentes.',
                  style: AppTextStyles.inputLabel.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Verifique sua conexão e tente novamente.',
                  style: AppTextStyles.inputHint,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    onPressed: _isLoadingCommits ? null : () => _loadCommits(),
                    child: const Text('Tentar novamente'),
                  ),
                ),
              ],
            ),
          )
        else if (_commits.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum commit recente encontrado.',
                  style: AppTextStyles.inputHint,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Faça um novo push no GitHub e toque em "Carregar mais +" para atualizar.',
                  style: AppTextStyles.inputHint.copyWith(fontSize: 14),
                ),
              ],
            ),
          )
        else
          Column(
            children: _commits.map(_buildCommitCard).toList(),
          ),
        if (_hasMoreCommits && _commits.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              onPressed: _isLoadingCommits ? null : () => _loadCommits(loadMore: true),
              child: _isLoadingCommits
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Carregar mais +'),
            ),
          ),
      ],
    );
  }

  Widget _buildCommitCard(GithubCommit commit) {
    final isSelected = _selectedCommits.containsKey(commit.sha);
    final dateText = _formatCommitDate(commit.committedAt);

    return GestureDetector(
      onTap: () => _toggleCommitSelection(commit),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCorners.md),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commit.message.isNotEmpty ? commit.message : 'Commit sem mensagem',
                    style: AppTextStyles.inputLabel,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    commit.repository,
                    style: AppTextStyles.inputHint.copyWith(fontSize: 14),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateText,
                      style: AppTextStyles.inputHint.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleCommitSelection(commit),
              activeColor: AppColors.accent,
              side: const BorderSide(color: AppColors.border),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCommitDate(DateTime? date) {
    if (date == null) return '';
    String two(int value) => value.toString().padLeft(2, '0');
    final local = date.toLocal();
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
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
    if (_isSubmitting) {
      return;
    }
    final missingTitle = _titleController.text.isEmpty;
    final missingCommits = _selectedCommits.isEmpty;
    if (missingTitle || missingCommits) {
      setState(() {
        _showTitleError = missingTitle;
        _showCommitSelectionError = missingCommits;
      });
      return;
    }
    _submitCheckin();
  }
}
