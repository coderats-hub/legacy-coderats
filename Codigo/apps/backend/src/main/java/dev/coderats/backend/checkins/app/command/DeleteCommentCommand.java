package dev.coderats.backend.checkins.app.command;
import dev.coderats.backend.checkins.domain.CommentId;
import dev.coderats.backend.users.domain.UserId;
public record DeleteCommentCommand(CommentId commentId, UserId deleterId) {}