import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:coderats/shared/components/components.dart';
import 'package:coderats/domain/group/group_participant.dart';
import 'package:coderats/repositories/group.repository.dart';
import 'package:coderats/services/group/group_remote_service.dart';
import 'package:coderats/services/http_client.dart';
import 'package:coderats/services/connectivity_service.dart';
import 'package:coderats/services/user/user_remote_service.dart';
import 'package:coderats/core/session_manager.dart';

class GroupEditScreen extends StatefulWidget {
  final String groupId;
  final String initialName;
  final String? initialDescription;
  final String? imageUrl;
  final List<GroupParticipant> participants;

  const GroupEditScreen({
    super.key,
    required this.groupId,
    required this.initialName,
    this.initialDescription,
    this.imageUrl,
    this.participants = const [],
  });

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  Uint8List? _pickedImageBytes;
  late List<GroupParticipant> _participants;
  final Set<String> _removedIds = {};
  bool _saving = false;

  late final GroupRepository _groupRepo;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
    _participants = List<GroupParticipant>.from(widget.participants);

    final session = SessionManager.instance;
    final http = HttpClient(session);
    _groupRepo = GroupRepository(
      remote: GroupRemoteService(http),
      local: null,
      net: ConnectivityService(),
      session: session,
      userRemote: UserRemoteService(http),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final source = await ImageSourceModal.show(context);
    if (source == null) return;

    try {
      final params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.image,
        mimeTypesFilter: ['image/*'],
      );
      final path = await FlutterFileDialog.pickFile(params: params);
      if (path == null) return;
      final bytes = await File(path).readAsBytes();
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

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _groupRepo.updateGroup(
        widget.groupId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        image: _pickedImageBytes != null ? base64Encode(_pickedImageBytes!) : null,
        participantsRemove: _removedIds.toList(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar grupo: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmRemove(String participantId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Remover participante?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Você tem certeza que deseja remover este participante do grupo? Ele pode voltar a entrar depois com o código.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remover', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _removedIds.add(participantId);
        _participants.removeWhere((p) => p.id == participantId);
      });
    }
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
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : Text('OK', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: GestureDetector(
                  onTap: _selectImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 120,
                      color: AppColors.accent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          if (_pickedImageBytes != null)
                            Image.memory(_pickedImageBytes!, fit: BoxFit.cover, width: double.infinity)
                          else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                            Image.network(widget.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                          else
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF9A24DD), Color(0xFF5A1A9A)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
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
                                hintText: 'Descrição do grupo',
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
                    const SizedBox(height: AppSpacing.sm),

                    if (_participants.isEmpty)
                      Text('Nenhum participante listado.', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary))
                    else
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: _participants.map((p) {
                          final removed = _removedIds.contains(p.id);
                          return _ParticipantChip(
                            name: p.name,
                            imageUrl: p.image,
                            role: p.role ?? '',
                            removed: removed,
                            onRemove: () => _confirmRemove(p.id),
                          );
                        }).toList(),
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

class _ParticipantChip extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String role;
  final bool removed;
  final VoidCallback onRemove;

  const _ParticipantChip({
    required this.name,
    required this.imageUrl,
    required this.role,
    required this.removed,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: removed ? AppColors.border : AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppCorners.md),
        border: Border.all(color: removed ? AppColors.error : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white))
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
              Text(role, style: AppTextStyles.inputHint.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.remove_circle, color: removed ? AppColors.error : AppColors.textSecondary, size: 20),
          )
        ],
      ),
    );
  }
}
