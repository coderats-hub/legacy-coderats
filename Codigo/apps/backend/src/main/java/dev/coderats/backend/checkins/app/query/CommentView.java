package dev.coderats.backend.checkins.app.query;
import java.time.Instant;
public record CommentView(String id, String content, AuthorView author, Instant createdAt) {}