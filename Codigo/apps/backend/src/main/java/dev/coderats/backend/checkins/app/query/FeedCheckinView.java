package dev.coderats.backend.checkins.app.query;

import java.time.Instant;
import java.util.List;

public record FeedCheckinView(
    String id,
    String title,
    String description,
    String image,
    String summaryAi,
    int points,
    Instant createdAt,
    AuthorView author,
    List<CommitView> commits,
    int likesCount,
    boolean likedByMe, 
    List<CommentView> comments
) {}