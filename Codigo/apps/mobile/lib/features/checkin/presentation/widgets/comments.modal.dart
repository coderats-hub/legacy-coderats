/**
 * MODAL DE COMENTÁRIOS - FUTURO
 * 
 * Modal reutilizável para exibir e gerenciar comentários em check-ins.
 * Atualmente não está sendo utilizado, mas será implementado futuramente.
 * 
 * Funcionalidades planejadas:
 * - Lista scrollável de comentários existentes
 * - Campo de entrada para novos comentários
 * - Avatares e timestamps dos autores
 * - Opção de deletar comentários próprios
 * - Animações de entrada/saída
 * - Layout responsivo que se adapta ao teclado
 * - Altura dinâmica baseada no número de comentários
 * 
 * Características técnicas:
 * - Usa BackdropFilter para efeito blur
 * - AnimationController para transições suaves
 * - ScrollController para auto-scroll ao adicionar comentários
 * - Keyboard-aware layout com viewInsets
 * - Integração completa com tema da aplicação
 * 
 * Onde será usado:
 * - Check-ins individuais (botão de comentários)
 * - Posts de atividades dos usuários
 * - Interação social entre membros do grupo
 */

/* NÃO ESTAMOS UTILIZANDO ESSE ARQUIVO NO MOMENTO, POIS AS MODAIS SERÃO IMPLEMENTADAS FUTURAMENTE

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';

// Modal de comentários com animações e layout responsivo
class CommentsModal extends StatefulWidget {
  final String title;                     // Título do modal (ex: "Comentários")
  final List<CommentItem> comments;       // Lista inicial de comentários
  final VoidCallback? onClose;            // Callback ao fechar modal

  const CommentsModal({super.key, required this.title, this.comments = const [], this.onClose});

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final TextEditingController _inputCtrl;
  late List<CommentItem> _comments;
  final ScrollController _listScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _inputCtrl = TextEditingController();
    _comments = List.from(widget.comments);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _listScrollCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height;

    // Layout tuning: compute a modal height that grows with the number of comments
    // but caps at a fraction of the screen to enable scrolling when there are many.
    const double headerHeight = 56; // header + divider area
    const double inputAreaHeight = 72; // approximate height for the input + safe area
    const double itemApproxHeight = 84; // estimated height per comment row
    final int count = _comments.length;
    final double desiredCommentsArea = (count * itemApproxHeight).toDouble();
    final double totalDesired = headerHeight + desiredCommentsArea + inputAreaHeight + 48; // extra paddings
  final double maxModalHeight = height * 0.92;
  final double minModalHeight = height * 0.28;

  // available height on screen after accounting for keyboard (viewInsets.bottom)
  final double systemBottom = MediaQuery.of(context).padding.bottom;
  // leave a small safety margin (48px) so the modal doesn't touch the screen edge
  final double maxAvailableHeight = math.max((height - bottom - systemBottom - 48), minModalHeight);

  // ensure containerHeight doesn't exceed the available height (keyboard-aware)
  final double containerHeight = totalDesired.clamp(minModalHeight, maxModalHeight);
  final double finalContainerHeight = math.min(containerHeight, maxAvailableHeight);

    // Height available for the comments ListView inside the modal
  final double commentsListHeight = (finalContainerHeight - headerHeight - inputAreaHeight - 32).clamp(80.0, finalContainerHeight);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppCorners.lg)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                // painel com altura dinâmica (cresce com número de comentários, até um limite)
                height: finalContainerHeight,
                color: AppColors.surface.withOpacity(0.98),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      // Header: título centralizado, botão fechar no canto direito
                      SizedBox(
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(child: Text(widget.title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700))),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  widget.onClose?.call();
                                },
                                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.border),

                      const SizedBox(height: AppSpacing.md),

                              // comentários (lista)
                              if (_comments.isEmpty)
                                Expanded(
                                  child: Center(child: Text('Ainda não há comentários', style: AppTextStyles.subtitle)),
                                )
                              else
                                // Constrain the comments area height so that when there are many comments
                                // the ListView scrolls inside the modal instead of expanding it beyond the max.
                                SizedBox(
                                  height: commentsListHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                                    child: ListView.separated(
                                      controller: _listScrollCtrl,
                                      itemCount: _comments.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                                      itemBuilder: (context, index) {
                                        final c = _comments[index];
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // avatar
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: AppColors.surface.withOpacity(0.12),
                                              child: const Icon(Icons.person, size: 18, color: Colors.white),
                                            ),
                                            const SizedBox(width: AppSpacing.md),

                                            // conteúdo principal
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Text(c.author, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                                            const SizedBox(width: AppSpacing.xs),
                                                            Text(c.timeAgo, style: AppTextStyles.inputHint.copyWith(fontSize: 12)),
                                                          ],
                                                        ),
                                                      ),
                                                      // deixa o ícone de delete alinhado ao topo da linha via Column abaixo
                                                    ],
                                                  ),
                                                  const SizedBox(height: AppSpacing.xs),
                                                  Text(
                                                    c.text,
                                                    // descrição menor e mais discreta
                                                    style: AppTextStyles.inputHint.copyWith(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // delete pequeno alinhado ao topo
                                            if (c.canDelete)
                                              Padding(
                                                padding: const EdgeInsets.only(left: AppSpacing.sm, top: 2),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary, size: 18),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),

                      const SizedBox(height: AppSpacing.md),

                      // input fixo na base do modal (compacto, estilo da referência)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Transform.translate(
                          offset: const Offset(0, -14), // puxa o input/botão 14px para cima
                          child: SafeArea(
                            top: false,
                            bottom: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(AppCorners.md),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _inputCtrl,
                                            maxLines: 1,
                                            style: AppTextStyles.inputLabel.copyWith(fontSize: 14),
                                            decoration: InputDecoration(
                                              isCollapsed: true,
                                              hintText: 'Escreva um comentário...',
                                              hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onSubmitted: (_) => _handleSend(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _handleSend,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppCorners.sm)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      elevation: 0,
                                    ),
                                    child: Text('Enviar', style: AppTextStyles.button.copyWith(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final newComment = CommentItem(author: 'Você', timeAgo: 'agora', text: text, canDelete: true);
    setState(() {
      _comments.add(newComment);
      _inputCtrl.clear();
    });

    // auto-scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listScrollCtrl.hasClients) return;
      final pos = _listScrollCtrl.position.maxScrollExtent;
      _listScrollCtrl.animateTo(
        pos + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

class CommentItem {
  final String author;
  final String timeAgo;
  final String text;
  final bool canDelete;
  const CommentItem({required this.author, required this.timeAgo, required this.text, this.canDelete = false});
}
*/
