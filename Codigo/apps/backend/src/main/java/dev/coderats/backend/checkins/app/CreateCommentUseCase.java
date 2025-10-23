package dev.coderats.backend.checkins.app;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dev.coderats.backend.checkins.app.command.CreateCommentCommand;
import dev.coderats.backend.checkins.app.port.CommentRepository;
import dev.coderats.backend.checkins.domain.Comment;
import dev.coderats.backend.shared.domain.Clock;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CreateCommentUseCase {
    private final CommentRepository commentRepository;
    private final Clock clock;
    
    @Transactional
    public Comment execute(CreateCommentCommand command) {
        Comment comment = Comment.create(command.checkinId(), command.authorId(), command.content(), clock);
        commentRepository.save(comment);
        return comment;
    }
}