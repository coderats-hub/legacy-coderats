package dev.coderats.backend.checkins.domain;

import java.time.Instant;
import java.util.Objects;

import dev.coderats.backend.shared.domain.Clock;
import dev.coderats.backend.users.domain.UserId;

public class Like {
    private final LikeId id;
    private final CheckinId checkinId;
    private final UserId userId;
    private final Instant createdAt;

    private Like(LikeId id, CheckinId checkinId, UserId userId, Instant createdAt) {
        this.id = Objects.requireNonNull(id);
        this.checkinId = Objects.requireNonNull(checkinId);
        this.userId = Objects.requireNonNull(userId);
        this.createdAt = Objects.requireNonNull(createdAt);
    }
    
    public static Like create(CheckinId checkinId, UserId userId, Clock clock) {
        return new Like(LikeId.newId(), checkinId, userId, clock.now());
    }
    
    public static Like reconstitute(LikeId id, CheckinId checkinId, UserId userId, Instant createdAt) {
        return new Like(id, checkinId, userId, createdAt);
    }
    
    // Getters
    public LikeId id() { return id; }
    public CheckinId checkinId() { return checkinId; }
    public UserId userId() { return userId; }
    public Instant createdAt() { return createdAt; }
}