package dev.coderats.backend.checkins.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId;

public class Comment {
    private final CommentId id;
    private final CheckinId checkinId;
    private final UserId userId;
    private String content;
    private final Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;
    
    private Comment(CommentId id, CheckinId checkinId, UserId userId, String content, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        this.id = Objects.requireNonNull(id);
        this.checkinId = Objects.requireNonNull(checkinId);
        this.userId = Objects.requireNonNull(userId);
        this.content = Objects.requireNonNull(content);
        this.createdAt = Objects.requireNonNull(createdAt);
        this.updatedAt = Objects.requireNonNull(updatedAt);
        this.deletedAt = deletedAt;
    }
    
    public static Comment create(CheckinId checkinId, UserId userId, String content, Clock clock) {
        final Instant now = clock.now();
        return new Comment(CommentId.newId(), checkinId, userId, content, now, now, null);
    }
    
    public static Comment reconstitute(CommentId id, CheckinId checkinId, UserId userId, String content, Instant createdAt, Instant updatedAt, Instant deletedAt) {
        return new Comment(id, checkinId, userId, content, createdAt, updatedAt, deletedAt);
    }
    
    public void updateContent(String newContent, Clock clock) {
        this.content = newContent;
        this.updatedAt = clock.now();
    }
    
    public void markDeleted(Clock clock) {
        this.deletedAt = clock.now();
        this.updatedAt = clock.now();
    }
    
    // Getters
    public CommentId id() { return id; }
    public CheckinId checkinId() { return checkinId; }
    public UserId userId() { return userId; }
    public String content() { return content; }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public Optional<Instant> deletedAt() { return Optional.ofNullable(deletedAt); }
}