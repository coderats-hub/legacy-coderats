package dev.coderats.backend.checkins.app;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.command.DeleteCommentCommand;
import dev.coderats.backend.checkins.app.port.CommentRepository;
import dev.coderats.backend.checkins.domain.Comment;
import dev.coderats.backend.shared.domain.Clock;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeleteCommentUseCase {
    private final CommentRepository commentRepository;
    private final Clock clock;
    
    @Transactional
    public void execute(DeleteCommentCommand command) {
        Comment comment = commentRepository.findById(command.commentId())
            .orElseThrow(() -> new RuntimeException("Comentário não encontrado.")); // TODO: Exceção 404
        
        // Regra de Negócio: Apenas o autor pode deletar (Forbidden 403)
        if (!comment.userId().equals(command.deleterId())) {
            throw new RuntimeException("Acesso negado: Você não é o autor."); // TODO: Exceção 403
        }
        
        comment.markDeleted(clock);
        commentRepository.save(comment);
    }
}