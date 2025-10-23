package dev.coderats.backend.checkins.app.port;
import java.util.Optional;
import dev.coderats.backend.checkins.domain.Comment;
import dev.coderats.backend.checkins.domain.CommentId;
public interface CommentRepository {
    void save(Comment comment);
    Optional<Comment> findById(CommentId commentId);
}